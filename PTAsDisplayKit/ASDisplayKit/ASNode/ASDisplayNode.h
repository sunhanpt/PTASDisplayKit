//
//  ASDisplayNode.h
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/17.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#ifndef ASDisplayNode_h
#define ASDisplayNode_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "_ASDisplayLayer.h"
#import "_ASDisplayView.h"

@interface ASDisplayNode : NSObject
/**
 *  node的名称
 */
@property (nonatomic, copy) NSString * name;
/**
 *  包含的layer
 */
@property (nonatomic, readonly, strong) _ASDisplayLayer * layer;
/**
 *  包含的view
 */
@property (nonatomic, readonly, strong) _ASDisplayView * view;
/**
 *  标记node是否是直接依赖于layer而非view
 */
@property (nonatomic, assign, getter=isLayerBacked) BOOL layerBacked;
/**
 *  node的尺寸
 */
@property (nonatomic, readonly, assign) CGSize calculatedSize;
/**
 *  添加新的node
 *
 *  @param subnode 要添加的node
 */
- (void)addSubnode:(ASDisplayNode *)subnode;

@end

#endif /* ASDisplayNode_h */
/**
 *  node与layer的数据transform，存储数据加上锁，保证线程安全
 */
@interface ASDisplayNode(UIViewBridge)

///**
// *  设置需要layout
// */
//- (void)setNeedsLayout;

@property (atomic, strong) id contents; // 展示内容：layer中的展示内容，默认nil
@property (atomic, getter=isOpaque)  BOOL opaque; // 不透明，默认YES
@property (atomic, getter=isHidden) BOOL hidden; // 是否隐藏
@property (atomic, assign) CGFloat alpha; // alpha通道值,默认值1.0
@property (atomic, assign) CGRect bounds; // bounds 默认为CGrectZero
@property (atomic, assign) CGRect frame; // frame 默认为CGrectZero
@property (atomic, strong) UIColor * backgroundColor; // 背景色
@property (atomic, assign) CGPoint anchorPoint;  //锚点 default={0.5, 0.5}
@property (atomic, assign) CGFloat zPosition;    //深度值，相当于光栅中使用的z-buffer值
@property (atomic, assign) CGPoint position; // layer在父层中的位置。父层的左上角为原点

@end

// 改造宏定义
#define ASDisplayNodeAssertThreadAffinity(viewNode)   ASDisplayNodeAssert(!viewNode || ASDisplayNodeThreadIsMain(), @"Incorrect display node thread affinity - this method should not be called off the main thread after the ASDisplayNode's view or layer have been created")
#define ASDisplayNodeCAssertThreadAffinity(viewNode) ASDisplayNodeCAssert(!viewNode || ASDisplayNodeThreadIsMain(), @"Incorrect display node thread affinity - this method should not be called off the main thread after the ASDisplayNode's view or layer have been created")

