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
#import "_ASAsyncDispalyOperation.h"

@protocol _ASDisplayLayerDelegate;

@interface _ASDisplayLayer : CALayer
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
@property (nonatomic, readonly, assign) ASAsyncDisplayLayerState state;
/**
 *  异步绘制的Delegate，实现具体绘制过程。
 */
@property (nonatomic, weak) id<_ASDisplayLayerDelegate> asyncDelegate;
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


/**
 *  asDisplayLayer的代理协议：一般在Node中实现
 */
@protocol _ASDisplayLayerDelegate <NSObject>

@optional
/**
 *  绘制函数
 *
 *  @param bounds           绘制范围
 *  @param parameters       绘制参数
 *  @param isCancelledBlock 取消block
 *  @param isRasterizing    是否光栅化
 */
+ (void)drawRect:(CGRect)bounds withParameters:(id<NSObject>)parameters isCancelled:(asdisplaynode_iscancelled_block_t)isCancelledBlock isRasterizing:(BOOL)isRasterizing;
/**
 *  根据参数绘制
 *
 *  @param parameters       绘制参数
 *  @param isCancelledBlock 取消的block
 *
 *  @return 返回一张image
 */
+ (UIImage *)displayWithParameters:(id<NSObject>)parameters isCancelled:(asdisplaynode_iscancelled_block_t)isCancelledBlock;
/**
 *  绘制layer
 *
 *  @param layer 传入layer
 *
 *  @return 返回绘制结果
 */
- (NSObject *)drawParametersForAsyncLayer:(_ASDisplayLayer *)layer;
/**
 *  将要绘制layer
 *
 *  @param layer 传入的layer
 */
- (void)willDisplayAsyncLayer:(_ASDisplayLayer *)layer;
/**
 *  已经绘制layer
 *
 *  @param layer 传入的layer
 */
- (void)didDisplayAsyncLayer:(_ASDisplayLayer *)layer;
/**
 *  绘制layer
 *
 *  @param asyncLayer     传入的layer
 *  @param asynchronously 是否异步的标记
 */
- (void)displayAsyncLayer:(_ASDisplayLayer *)asyncLayer asynchronously:(BOOL)asynchronously;
/**
 *  取消绘制layer
 *
 *  @param asyncLayer 传入的layer
 */
- (void)cancelDisplayAsyncLayer:(_ASDisplayLayer *)asyncLayer;

@end

#endif /* _ASTransaction_h */
