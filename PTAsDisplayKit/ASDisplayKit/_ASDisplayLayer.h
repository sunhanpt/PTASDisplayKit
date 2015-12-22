//
//  _ASTransaction.h
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/15.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#ifndef _ASTransaction_h
#define _ASTransaction_h
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "_ASAsyncTransactionConfig.h"


@protocol _ASDisplayLayerDelegate;
@class _ASAsyncTransaction;

@interface _ASDisplayLayer : CALayer

/**
 *  异步绘制的Delegate，实现具体绘制过程。
 */
@property (nonatomic, weak) id<_ASDisplayLayerDelegate> asyncDelegate;
/**
 *  是否异步渲染
 */
@property (atomic, assign) BOOL displaysAsynchronously;
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
- (async_operation_display_block_t)displayAsyncLayer:(_ASDisplayLayer *)asyncLayer asynchronously:(BOOL)asynchronously;
/**
 *  取消绘制layer
 *
 *  @param asyncLayer 传入的layer
 */
- (void)cancelDisplayAsyncLayer:(_ASDisplayLayer *)asyncLayer;

@end

#endif /* _ASTransaction_h */
