//
//  _ASTransaction.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/15.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "ASAssert.h"
#import "_ASDisplayLayer.h"
#import "_ASAsyncTransactionGroup.h"

// 最大并行数
static long __ASDisplayLayerMaxConcurrentDisplayCount = 8;

@interface _ASTransactionDispalyQueue : NSOperationQueue
+ (id)sharedInstance;
@end

@implementation _ASTransactionDispalyQueue
+ (id)sharedInstance
{
    static _ASTransactionDispalyQueue * _displayQueue = nil;
    dispatch_once_t lock;
    dispatch_once(&lock, ^(void){
        if (!_displayQueue){
            _displayQueue = [[_ASTransactionDispalyQueue alloc] init];
            [_displayQueue setMaxConcurrentOperationCount:__ASDisplayLayerMaxConcurrentDisplayCount];
        }
    });
    return _displayQueue;
}

@end

@implementation _ASDisplayLayer
{
    dispatch_group_t _group;
    NSMutableArray * _operations;
}

#pragma mark - lifecycle
- (id)initWithCallbackQueue:(dispatch_queue_t)callBackQueue completionBlock:(async_layer_completion_block_t)completionBlock
{
    self = [self init];
    if (self){
        if (callBackQueue == NULL){
            callBackQueue = dispatch_get_main_queue();
        }
        _callbackQueue = callBackQueue;
        _completionBlcok = [completionBlock copy];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self){
        _callbackQueue = dispatch_get_main_queue();
        _completionBlcok = NULL;
        _state = ASAsyncDisplayLayerStateOpen;
    }
    return self;
}
- (void)dealloc
{
    ASDisplayNodeAssert(_state != ASAsyncDisplayLayerStateOpen, @"Uncommitted ASAsyncTransactions are not allowed");
}
#pragma mark - override method
- (void)display
{
    [self _performBlockWithAsyncDelegate:^(id<_ASDisplayLayerDelegate> asyncDelegate) {
        [asyncDelegate displayAsyncLayer:self asynchronously:YES];
    }];
}
#pragma mark - ASTransaction Manager
- (void)addOperationWithBlock:(async_operation_display_block_t)block completion:(async_operation_completion_block_t)completion
{
    ASDisplayNodeAssertMainThread();
    ASDisplayNodeAssert(_state == ASAsyncDisplayLayerStateOpen, @"You can only add operations to open transactions");
    [self _ensureTransactionData];
    // 添加dispatch_group为了线程同步。
    async_operation_display_block_t displayBlock = (id)^{
        id<NSObject> value = nil;
        if (block){
           value = block();
        }
        dispatch_group_leave(_group);
        return value;
    };
    _ASAsyncDispalyOperation * operation = [[_ASAsyncDispalyOperation alloc] initWithOperationDispalyBlock:displayBlock andCompletionBlock:completion];
    [_operations addObject:operation];
    dispatch_group_enter(_group);
    [[_ASTransactionDispalyQueue sharedInstance] addOperation:operation];
    [[_ASAsyncTransactionGroup mainTransactionGroup] addTransactionLayer:self];
}

- (void)addOperation:(_ASAsyncDispalyOperation *)operation
{
    [self addOperationWithBlock:[operation.displayBlock copy] completion:[operation.completionBlock copy]];
}

- (void)cancel
{
    ASDisplayNodeAssertMainThread();
    ASDisplayNodeAssert(_state != ASAsyncDisplayLayerStateOpen, @"You can only cancel a committed or already-canceled transaction");
    _state = ASAsyncDisplayLayerStateCanceled;
}

- (void)commit
{
    ASDisplayNodeAssertMainThread();
    ASDisplayNodeAssert(_state == ASAsyncDisplayLayerStateOpen, @"You cannot double-commit a transaction");
    _state = ASAsyncDisplayLayerStateCommitted;
    if ([_operations count] == 0){
        // transaction已开，但是operation为空，直接同步运行completionBlock
        if (_completionBlcok){
            _completionBlcok(self, NO);
        }
    }
    else{
        ASDisplayNodeAssert(_group != NULL, @"If there are operations, dispatch group should have been created");
        
        dispatch_group_notify(_group, _callbackQueue, ^{
            ASDisplayNodeAssertMainThread();
            [self completeTransaction];
        });
    }
}

- (void)completeTransaction
{
    if (_state != ASAsyncDisplayLayerStateComplete) {
        BOOL isCanceled = (_state == ASAsyncDisplayLayerStateCanceled);
        for (_ASAsyncDispalyOperation * operation in _operations) {
            [operation callAndReleaseCompletionBlock:isCanceled];
        }
        _state = ASAsyncDisplayLayerStateComplete;
        
        if (_completionBlcok) {
            _completionBlcok(self, isCanceled);
        }
    }
}

/**
 *  这个函数是一些node里调用recursivelyEnsureDisplay而调到。原来的注释是说防止两次提交transaction。
 *  仅在需要在runloop的一个周期中强制完成绘制过程的情况下。（个人理解是一个transaction可能包含多个operation，而这些operation添加的时机并不一定在主线程的一个runloop内，这样相当于把一个transaction的commit绘制，放在了两个runloop中）。
 */
- (void)waitUntilComplete
{
    ASDisplayNodeAssertMainThread();
    if (_state != ASAsyncDisplayLayerStateComplete) {
        if (_group) {
            ASDisplayNodeAssertTrue(_callbackQueue == dispatch_get_main_queue());
            dispatch_group_wait(_group, DISPATCH_TIME_FOREVER);
            
            if (_state == ASAsyncDisplayLayerStateOpen) {
                [_ASAsyncTransactionGroup commit];
                ASDisplayNodeAssert(_state != ASAsyncDisplayLayerStateOpen, @"Layer should not be open after committing group");
            }
            [self completeTransaction];
        }
    }
}

#pragma mark - Helper Methods
- (void)_ensureTransactionData
{
    // 懒加载成员变量
    if (_group == NULL) {
        _group = dispatch_group_create();
    }
    if (_operations == nil) {
        _operations = [[NSMutableArray alloc] init];
    }
}

- (void)_performBlockWithAsyncDelegate:(void(^)(id<_ASDisplayLayerDelegate> asyncDelegate))block
{
    id<_ASDisplayLayerDelegate> __attribute__((objc_precise_lifetime)) strongAsyncDelegate;
    {
        // TODO:加锁
        //ASDN::MutexLocker l(_asyncDelegateLock);
        strongAsyncDelegate = _asyncDelegate;
    }
    block(strongAsyncDelegate);
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"<_ASAsyncTransaction: %p - _state = %lu, _group = %@, _operations = %@>", self, (unsigned long)_state, _group, _operations];
}

@end
