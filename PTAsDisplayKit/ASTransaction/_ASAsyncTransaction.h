//
//  _ASTransaction.h
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/15.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#ifndef _ASTransaction_h
#define _ASTransaction_h
#import <Foundation/Foundation.h>
#import "_ASAsyncTransactionDispalyOperation.h"

@interface _ASAsyncTransaction : NSObject
/**
 *  completionBlock运行的线程queue
 */
@property (nonatomic, readonly, strong) dispatch_queue_t callbackQueue;
/**
 *  回调completionBlock
 */
@property (nonatomic, readonly, copy) asyncdisplaykit_async_transaction_completion_block_t completionBlcok;
/**
 *  transaction的state
 */
@property (nonatomic, readonly, assign) ASAsyncTransactionState state;
/**
 *  初始化函数
 *
 *  @param callBackQueue   回调的线程queue
 *  @param completionBlock transaction的完成block
 *
 *  @return 返回ASTransaction
 */
- (id)initWithCallBackQueue:(dispatch_queue_t)callBackQueue
            completionBlock:(asyncdisplaykit_async_transaction_completion_block_t)completionBlock;
/**
 *  添加一个operation到transaction并立即运行在并行线程中
 *
 *  @param block      operation的绘制block
 *  @param completion operation的完成block
 */
- (void)addOperationWithBlock:(asyncdisplaykit_async_transaction_operation_block_t)block
                   completion:(asyncdisplaykit_async_transaction_operation_completion_block_t)completion;

/**
 *  取消transaction的操作
 */
- (void)cancel;
/**
 *  提交transaction，开始渲染到屏幕
 */
- (void)commit;
/**
 *  整个transaction完成后执行
 *  必须在main thread执行
 */
- (void)waitUntilComplete;


@end

#endif /* _ASTransaction_h */
