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
#import "_ASAsyncTransactionConfig.h"

@interface _ASAsyncDispalyOperation : NSOperation
/**
 *  绘制block
 */
@property (nonatomic, readonly, copy) async_operation_display_block_t displayBlock;
/**
 *  绘制结束，线程同步时调用的block
 */
@property (nonatomic, readonly, copy) async_operation_completion_block_t displayCompletionBlock;
/**
 *  初始化operation函数
 *
 *  @param displayBlock           绘制block
 *  @param displayCompletionBlock 完成block
 *
 *  @return 返回一个operation
 */
- (id)initWithOperationDispalyBlock:(async_operation_display_block_t)displayBlock andCompletionBlock:(async_operation_completion_block_t)displayCompletionBlock;
// 执行并释放completionBlock
- (void)callAndReleaseCompletionBlock:(BOOL)canceled;

@end

#endif /* ASTransactionDispalyOperation_h */
