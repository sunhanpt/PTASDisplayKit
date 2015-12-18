//
//  ASTransactionConfig.h
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/14.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#ifndef ASTransactionConfig_h
#define ASTransactionConfig_h

@class _ASDisplayLayer;

/**
 *  整个layer完成的block
 *
 *  @param completedLayer 传入layer
 *  @param canceled       传入是否取消的标记
 */
typedef void(^async_layer_completion_block_t)(_ASDisplayLayer *completedLayer, BOOL canceled);
/**
 *  operation绘制block
 *
 *  @return 返回绘制结果
 */
typedef id<NSObject>(^async_operation_display_block_t)(void);
/**
 *  operation完成block
 *
 *  @param value    传入value
 *  @param canceled 取消标记
 */
typedef void(^async_operation_completion_block_t)(id<NSObject> value, BOOL canceled);
/**
 *  标记displayNode是否被取消绘制
 *
 *  @return 返回BOOL值
 */
typedef BOOL(^asdisplaynode_iscancelled_block_t)(void);
/**
 *  transaction的状态
 */
typedef NS_ENUM(NSUInteger, ASAsyncDisplayLayerState) {
    /**
     *  打开状态
     */
    ASAsyncDisplayLayerStateOpen = 0,
    /**
     *  已经提交状态
     */
    ASAsyncDisplayLayerStateCommitted,
    /**
     *  取消状态
     */
    ASAsyncDisplayLayerStateCanceled,
    /**
     *  完成状态
     */
    ASAsyncDisplayLayerStateComplete
};

#endif /* ASTransactionConfig_h */
