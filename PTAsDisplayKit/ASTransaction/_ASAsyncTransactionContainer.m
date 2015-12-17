//
//  _ASAsyncTransactionContainer.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/15.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//


#import "_ASAsyncTransaction.h"
#import "_ASAsyncTransactionContainer.h"
#import "_ASAsyncTransactionGroup.h"

@implementation CALayer (ASAsyncTransactionContainerTransactions)
@dynamic asyncdisplaykit_asyncLayerTransactions;
@dynamic asyncdisplaykit_currentAsyncLayerTransaction;

// 主要用于测试
- (void)asyncdisplaykit_asyncTransactionContainerWillBeginTransaction:(_ASAsyncTransaction *)transaction {}
- (void)asyncdisplaykit_asyncTransactionContainerDidCompleteTransaction:(_ASAsyncTransaction *)transaction {}
@end

@implementation CALayer (ASDisplayNodeAsyncTransactionContainer)

@dynamic asyncdisplaykit_asyncTransactionContainer;

// 返回container的状态
- (ASAsyncTransactionContainerState)asyncdisplaykit_asyncTransactionContainerState
{
    return ([self.asyncdisplaykit_asyncLayerTransactions count] == 0) ? ASAsyncTransactionContainerStateNoTransactions : ASAsyncTransactionContainerStatePendingTransactions;
}

// 取消transactions
- (void)asyncdisplaykit_cancelAsyncTransactions
{
    // If there was an open transaction, commit and clear the current transaction. Otherwise:
    // (1) The run loop observer will try to commit a canceled transaction which is not allowed
    // (2) We leave the canceled transaction attached to the layer, dooming future operations
    _ASAsyncTransaction *currentTransaction = self.asyncdisplaykit_currentAsyncLayerTransaction;
    [currentTransaction commit];
    self.asyncdisplaykit_currentAsyncLayerTransaction = nil;
    
    for (_ASAsyncTransaction *transaction in [self.asyncdisplaykit_asyncLayerTransactions copy]) {
        [transaction cancel];
    }
}

- (void)asyncdisplaykit_asyncTransactionContainerStateDidChange
{
    id delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(asyncdisplaykit_asyncTransactionContainerStateDidChange)]) {
        [delegate asyncdisplaykit_asyncTransactionContainerStateDidChange];
    }
}

- (_ASAsyncTransaction *)asyncdisplaykit_asyncTransaction
{
    _ASAsyncTransaction *transaction = self.asyncdisplaykit_currentAsyncLayerTransaction;
    if (transaction == nil) {
        NSHashTable *transactions = self.asyncdisplaykit_asyncLayerTransactions;
        if (transactions == nil) {
            transactions = [NSHashTable hashTableWithOptions:NSPointerFunctionsObjectPointerPersonality];
            self.asyncdisplaykit_asyncLayerTransactions = transactions;
        }
        transaction = [[_ASAsyncTransaction alloc] initWithCallbackQueue:dispatch_get_main_queue() completionBlock:^(_ASAsyncTransaction *completedTransaction, BOOL cancelled) {
            [transactions removeObject:completedTransaction];
            [self asyncdisplaykit_asyncTransactionContainerDidCompleteTransaction:completedTransaction];
            if ([transactions count] == 0) {
                [self asyncdisplaykit_asyncTransactionContainerStateDidChange];
            }
        }];
        [transactions addObject:transaction];
        self.asyncdisplaykit_currentAsyncLayerTransaction = transaction;
        [self asyncdisplaykit_asyncTransactionContainerWillBeginTransaction:transaction];
        if ([transactions count] == 1) {
            [self asyncdisplaykit_asyncTransactionContainerStateDidChange];
        }
    }
    [[_ASAsyncTransactionGroup mainTransactionGroup] addTransactionContainer:self];
    return transaction;
}

- (CALayer *)asyncdisplaykit_parentTransactionContainer
{
    CALayer *containerLayer = self;
    while (containerLayer && !containerLayer.asyncdisplaykit_isAsyncTransactionContainer) {
        containerLayer = containerLayer.superlayer;
    }
    return containerLayer;
}

@end

