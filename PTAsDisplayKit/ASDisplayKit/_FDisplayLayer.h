//
//  _FDisplayLayer.h
//  PTAsDisplayKit
//
//  Created by 净枫 on 15/12/24.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "_ASAsyncTransactionConfig.h"
#import "ASSentinel.h"


@protocol _FDisplayLayerDelegate ;
@interface _FDisplayLayer : CALayer

/**
 *  是否异步显示，默认为YES
 */
@property (nonatomic , assign) BOOL displaysAsyncChronously ;

/**
 *  暂停同步或者异步绘制 , 这个目前看，在tableview和collectView里面有作用，在其他view里面基本不使用，后期如果不进行tableview和collectView
 *  可以考虑怎么处理这个属性
 */
@property (nonatomic, assign, getter=isDisplaySuspended) BOOL displaySuspended;

/**
 *  layer的异步显示的delegate
 *  discuss 这里的delegate 只是将layer里面的绘制操作回调到node里面去处理，node是更适合对外暴露的
 */
@property (nonatomic, weak) id<_FDisplayLayerDelegate> asyncDelegate;

/**
 *  序列标记：用于取消多余绘制（保证在一个runloop中，仅仅绘制一遍layer）；
 */
@property (nonatomic, strong) ASSentinel * displaySentinel;


/**
 *  取消异步绘制，主要通过代理回调传递出去
 */
- (void)cancelAsyncDisplay;

/**
 *  不通过异步绘制，按照UIKit的方式显示layer
 */
- (void)displayImmediately;

@end

@protocol _FDisplayLayerDelegate <NSObject>

@optional
/**
 *  绘制函数
 *
 *  @param bounds           绘制范围
 *  @param parameters       绘制参数
 *  @param isCancelledBlock 取消block
 *  @param isRasterizing    是否光栅化
 */
+ (void)drawRect:(CGRect)bounds withParameters:(id<NSObject>)parameters isCancelled:(async_operation_iscancelled_block_t)isCancelledBlock isRasterizing:(BOOL)isRasterizing;
/**
 *  根据参数绘制
 *
 *  @param parameters       绘制参数
 *  @param isCancelledBlock 取消的block
 *
 *  @return 返回一张image
 */
+ (UIImage *)displayWithParameters:(id<NSObject>)parameters isCancelled:(async_operation_iscancelled_block_t)isCancelledBlock;
/**
 *  绘制layer
 *
 *  @param layer 传入layer
 *
 *  @return 返回绘制结果
 */
- (NSObject *)drawParametersForAsyncLayer:(_FDisplayLayer *)layer;
/**
 *  将要绘制layer
 *
 *  @param layer 传入的layer
 */
- (void)willDisplayAsyncLayer:(_FDisplayLayer *)layer;
/**
 *  已经绘制layer
 *
 *  @param layer 传入的layer
 */
- (void)didDisplayAsyncLayer:(_FDisplayLayer *)layer;
/**
 *  绘制layer
 *
 *  @param asyncLayer     传入的layer
 *  @param asynchronously 是否异步的标记
 */
- (async_operation_display_block_t)displayAsyncLayer:(_FDisplayLayer *)asyncLayer isCancelledBlock:(async_operation_iscancelled_block_t)isCacelledBlock asynchronously:(BOOL)asynchronously;
/**
 *  取消绘制layer
 *
 *  @param asyncLayer 传入的layer
 */
- (void)cancelDisplayAsyncLayer:(_FDisplayLayer *)asyncLayer;


@end
