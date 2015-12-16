//
//  _ASTransaction.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/15.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "_ASAsyncTransaction.h"
#import "ASAssert.h"

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
        }
    });
    return _displayQueue;
}

@end

@implementation _ASAsyncTransaction
{
    dispatch_group_t _group;
    NSMutableArray * _operations;
}

#pragma mark - lifecycle
- (id)initWithCallBackQueue:(dispatch_queue_t)callBackQueue completionBlock:(asyncdisplaykit_async_transaction_completion_block_t)completionBlock
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
- (void)dealloc
{
    ASDisplayNodeAssert(_state != ASAsyncTransactionStateOpen, @"Uncommitted ASAsyncTransactions are not allowed");
}

#pragma mark - ASTransaction Manager
- (void)addOperationWithBlock:(asyncdisplaykit_async_transaction_operation_block_t)block completion:(asyncdisplaykit_async_transaction_operation_completion_block_t)completion
{
    ASDisplayNodeAssertMainThread();
    ASDisplayNodeAssert(_state == ASAsyncTransactionStateOpen, @"You can only add operations to open transactions");
    [self _ensureTransactionData];
    // 添加dispatch_group为了线程同步。
    asyncdisplaykit_async_transaction_operation_block_t displayBlock = (id)^{
        dispatch_group_leave(_group);
        return block();
    };
    _ASAsyncTransactionDispalyOperation * operation = [[_ASAsyncTransactionDispalyOperation alloc] initWithOperationDispalyBlock:displayBlock andCompletionBlock:completion];
    [_operations addObject:operation];
    dispatch_group_enter(_group);
    [[_ASTransactionDispalyQueue sharedInstance] addOperation:operation];
}

- (void)cancel
{
    ASDisplayNodeAssertMainThread();
    ASDisplayNodeAssert(_state != ASAsyncTransactionStateOpen, @"You can only cancel a committed or already-canceled transaction");
    _state = ASAsyncTransactionStateCanceled;
}

- (void)commit
{
    ASDisplayNodeAssertMainThread();
    ASDisplayNodeAssert(_state == ASAsyncTransactionStateOpen, @"You cannot double-commit a transaction");
    _state = ASAsyncTransactionStateCommitted;
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
    if (_state != ASAsyncTransactionStateComplete) {
        BOOL isCanceled = (_state == ASAsyncTransactionStateCanceled);
        for (_ASAsyncTransactionDispalyOperation * operation in _operations) {
            [operation callAndReleaseCompletionBlock:isCanceled];
        }
        _state = ASAsyncTransactionStateComplete;
        
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
    if (_state != ASAsyncTransactionStateComplete) {
        if (_group) {
            ASDisplayNodeAssertTrue(_callbackQueue == dispatch_get_main_queue());
            dispatch_group_wait(_group, DISPATCH_TIME_FOREVER);
            
            if (_state == ASAsyncTransactionStateOpen) {
                //TODO:transactionGroup的提交
                //[_ASAsyncTransactionGroup commit];
                ASDisplayNodeAssert(_state != ASAsyncTransactionStateOpen, @"Transaction should not be open after committing group");
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<_ASAsyncTransaction: %p - _state = %lu, _group = %@, _operations = %@>", self, (unsigned long)_state, _group, _operations];
}

@end