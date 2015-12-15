//
//  ASTransactionConfig.h
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/14.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#ifndef ASTransactionConfig_h
#define ASTransactionConfig_h

@class _ASTransaction;

typedef void(^asyncdisplaykit_async_transaction_completion_block_t)(_ASTransaction *completedTransaction, BOOL canceled);
typedef id<NSObject>(^asyncdisplaykit_async_transaction_operation_block_t)(void);
typedef void(^asyncdisplaykit_async_transaction_operation_completion_block_t)(id<NSObject> value, BOOL canceled);
typedef void(^asyncdisplaykit_async_transaction_complete_async_operation_block_t)(id<NSObject> value);
typedef void(^asyncdisplaykit_async_transaction_async_operation_block_t)(asyncdisplaykit_async_transaction_complete_async_operation_block_t completeOperationBlock);

/**
 State is initially ASAsyncTransactionStateOpen.
 Every transaction MUST be committed. It is an error to fail to commit a transaction.
 A committed transaction MAY be canceled. You cannot cancel an open (uncommitted) transaction.
 */
typedef NS_ENUM(NSUInteger, ASAsyncTransactionState) {
    ASAsyncTransactionStateOpen = 0,
    ASAsyncTransactionStateCommitted,
    ASAsyncTransactionStateCanceled,
    ASAsyncTransactionStateComplete
};

#endif /* ASTransactionConfig_h */
