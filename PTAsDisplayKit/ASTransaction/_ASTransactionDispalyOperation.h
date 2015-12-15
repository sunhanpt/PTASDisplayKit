//
//  ASTransactionDispalyOperation.h
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/14.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#ifndef ASTransactionDispalyOperation_h
#define ASTransactionDispalyOperation_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "_ASTransactionConfig.h"

@interface _ASTransactionDispalyOperation : NSOperation
/**
 *  绘制block
 */
@property (nonatomic, readonly, copy) asyncdisplaykit_async_transaction_operation_block_t displayBlock;
/**
 *  绘制结束，线程同步时调用的block
 */
@property (nonatomic, readonly, copy) asyncdisplaykit_async_transaction_operation_completion_block_t displayCompletionBlock;
- (id)initWithOperationDispalyBlock:(asyncdisplaykit_async_transaction_operation_block_t)displayBlock andCompletionBlock:(asyncdisplaykit_async_transaction_operation_completion_block_t)displayCompletionBlock;
- (void)callAndReleaseCompletionBlock:(BOOL)canceled;

@end

#endif /* ASTransactionDispalyOperation_h */
