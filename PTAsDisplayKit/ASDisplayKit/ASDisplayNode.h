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
