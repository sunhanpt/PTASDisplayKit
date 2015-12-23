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

@interface ASDisplayNode : NSObject<_ASDisplayLayerDelegate>
/**
 *  node的名称
 */
@property (nonatomic, copy) NSString * name;
/**
 *  包含的layer
 */
@property (nonatomic, readonly, strong) _ASDisplayLayer * layer;
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

/**
 *  设置需要layout
 */
- (void)setNeedsLayout;

@property (atomic, strong) id contents; // 展示内容：layer中的展示内容，默认nil
@property (atomic, assign) BOOL clipsToBounds; // 裁剪到边界，默认NO
@property (atomic, getter=isOpaque)  BOOL opaque; // 不透明，默认YES
@property (atomic, getter=isHidden) BOOL hidden; // 是否隐藏
//@property ();

@end
