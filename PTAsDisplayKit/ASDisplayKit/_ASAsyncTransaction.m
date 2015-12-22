//
//  _ASAsyncTransaction.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/21.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//


#import "ASAssert.h"
#import "_ASAsyncTransaction.h"
#import "_ASAsyncTransactionGroup.h"

// 最大并行数
static long __ASDisplayLayerMaxConcurrentDisplayCount = 8;

/**
 *  绘制operation的queue
 */
@interface _ASTransactionDispalyQueue : NSOperationQueue

/**
 *  单例函数，获取单例
 *
 *  @return 返回_ASTransactionDispalyQueue的单例
 */
+ (id)sharedInstance;

@end

@implementation _ASTransactionDispalyQueue
+ (id)sharedInstance
{
    static _ASTransactionDispalyQueue * _displayQueue = nil;
    static dispatch_once_t lock;
    dispatch_once(&lock, ^(void){
        if (!_displayQueue){
            _displayQueue = [[_ASTransactionDispalyQueue alloc] init];
            [_displayQueue setMaxConcurrentOperationCount:__ASDisplayLayerMaxConcurrentDisplayCount];
        }
    });
    return _displayQueue;
}

@end


@interface _ASAsyncTransaction()

@end

@implementation _ASAsyncTransaction
{
    /**
     *  group 用于线程同步
     */
    dispatch_group_t _group;
    /**
     *  绘制operation集
     */
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
        _state = ASAsyncTransationStateOpen;
    }
    return self;
}
- (void)dealloc
{
    ASDisplayNodeAssert(_state != ASAsyncTransationStateOpen, @"Uncommitted ASAsyncTransactions are not allowed");
}
#pragma mark - ASTransaction Manager
- (void)addOperationWithBlock:(async_operation_display_block_t)block completion:(async_operation_completion_block_t)completion
{
    ASDisplayNodeAssertMainThread();
    ASDisplayNodeAssert(_state == ASAsyncTransationStateOpen || _state == ASAsyncTransationStateComplete, @"You can only add operations to open transactions");
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
    [[_ASAsyncTransactionGroup mainTransactionGroup] addTransaction:self];
}

- (void)addOperation:(_ASAsyncDispalyOperation *)operation
{
    [self addOperationWithBlock:[operation.displayBlock copy] completion:[operation.completionBlock copy]];
}

- (void)releaseAllOperations
{
    if (_operations){
        [_operations removeAllObjects];
    }
}

- (void)cancel
{
    ASDisplayNodeAssertMainThread();
    ASDisplayNodeAssert(_state != ASAsyncTransationStateOpen, @"You can only cancel a committed or already-canceled transaction");
    _state = ASAsyncTransationStateCanceled;
}

- (void)commit
{
    ASDisplayNodeAssertMainThread();
    ASDisplayNodeAssert(_state == ASAsyncTransationStateOpen || _state == ASAsyncTransationStateComplete, @"You cannot double-commit a transaction");
    _state = ASAsyncTransationStateCommitted;
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
    if (_state != ASAsyncTransationStateComplete) {
        BOOL isCanceled = (_state == ASAsyncTransationStateCanceled);
        for (_ASAsyncDispalyOperation * operation in _operations) {
            [operation callAndReleaseCompletionBlock:isCanceled];
        }
        _state = ASAsyncTransationStateComplete;
        
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
    if (_state != ASAsyncTransationStateComplete) {
        if (_group) {
            ASDisplayNodeAssertTrue(_callbackQueue == dispatch_get_main_queue());
            dispatch_group_wait(_group, DISPATCH_TIME_FOREVER);
            
            if (_state == ASAsyncTransationStateOpen) {
                [_ASAsyncTransactionGroup commit];
                ASDisplayNodeAssert(_state != ASAsyncTransationStateOpen, @"Layer should not be open after committing group");
            }
            [self completeTransaction];
        }
    }
}

#pragma mark - help methodes
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<_ASAsyncTransaction: %p - _state = %lu, _group = %@, _operations = %@>", self, (unsigned long)_state, _group, _operations];
}

@end