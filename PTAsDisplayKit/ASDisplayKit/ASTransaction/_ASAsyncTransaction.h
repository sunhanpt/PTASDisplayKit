//
//  _ASAsyncTransaction.h
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/21.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#ifndef _ASAsyncTransaction_h
#define _ASAsyncTransaction_h

#import <Foundation/Foundation.h>
#import "_ASAsyncDispalyOperation.h"
@interface _ASAsyncTransaction : NSObject

/**
 *  completionBlock运行的线程queue
 */
@property (nonatomic, readonly, strong) dispatch_queue_t callbackQueue;
/**
 *  回调completionBlock
 */
@property (nonatomic, readonly, copy) async_layer_completion_block_t completionBlcok;
/**
 *  layer的state
 */
@property (nonatomic, readonly, assign) ASAsyncTransationState state;
/**
 *  初始化函数
 *
 *  @param callBackQueue   回调的线程queue
 *  @param completionBlock transaction的完成block
 *
 *  @return 返回ASTransaction
 */
- (id)initWithCallbackQueue:(dispatch_queue_t)callBackQueue
            completionBlock:(async_layer_completion_block_t)completionBlock;
/**
 *  添加一个operation到transaction并立即运行在并行线程中
 *
 *  @param block      operation的绘制block
 *  @param completion operation的完成block
 */
- (void)addOperationWithBlock:(async_operation_display_block_t)block
                   completion:(async_operation_completion_block_t)completion;
/**
 *  添加操作operation
 *
 *  @param operation 传入的operation
 */
- (void)addOperation:(_ASAsyncDispalyOperation *)operation;
/**
 *  释放掉所有绘制数据（在layer绘制结束之后执行）
 */
- (void)releaseAllOperations;
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

#endif /* _ASAsyncTransaction_h */
