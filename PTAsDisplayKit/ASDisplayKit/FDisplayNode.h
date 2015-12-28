//
//  FDisplayNode.h
//  PTAsDisplayKit
//
//  Created by 净枫 on 15/12/24.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "_FDisplayLayer.h"


@interface FDisplayNode : NSObject


- (id)init;


/**
 *  后台的layer是否加载完
 */
@property (atomic, readonly, assign, getter=isNodeLoaded) BOOL nodeLoaded;

/**
 *  用layer替代view
 */
@property (nonatomic, assign, getter=isLayerBacked) BOOL layerBacked;


/**
 *  node里面持有一个layer
 */
@property (nonatomic, readonly, retain) CALayer *layer;


/**
 *  缓存计算的大小
 */
@property (nonatomic, readonly, assign) CGSize calculatedSize;


/**
 *  是否异步显示
 */
@property (nonatomic, assign) BOOL displaysAsynchronously;

/**
 *  是否光栅化
 */
@property (nonatomic, assign) BOOL shouldRasterizeDescendants;

/**
 *  是否暂停显示
 */
@property (nonatomic, assign) BOOL displaySuspended;

/**
 *  子node
 */
@property (nonatomic, readonly, retain) NSArray *subnodes;

/**
 *  父node
 */
@property (nonatomic, readonly, weak) FDisplayNode *supernode;

/**
 *  计算大小
 *
 *  @param constrainedSize 约束的大小
 *
 *  @return 计算的大小
 */
- (CGSize)measure:(CGSize)constrainedSize;

/*--------------------这里是对tableview的优化做准备，暂时不在node里面实现-----------------------*/
/**
 *  递归暂停 ，折后考虑后面去掉
 *
 *  @param flag 标志
 */
- (void)recursivelySetDisplaySuspended:(BOOL)flag;

/**
 *  递归清楚content
 */
- (void)recursivelyClearContents;

/**
 *  递归清除
 */
- (void)recursivelyClearFetchedData;

- (void)recursivelyFetchData;


/*--------------------这里是对tableview的优化做准备，暂时不在node里面实现-----------------------*/

/*-------------------------------------------node 树操作-----------------------------------*/
- (void)addSubnode:(FDisplayNode *)subnode;

- (void)insertSubnode:(FDisplayNode *)subnode belowSubnode:(FDisplayNode *)below;

- (void)insertSubnode:(FDisplayNode *)subnode aboveSubnode:(FDisplayNode *)above;

- (void)insertSubnode:(FDisplayNode *)subnode atIndex:(NSInteger)idx;

- (void)replaceSubnode:(FDisplayNode *)subnode withSubnode:(FDisplayNode *)replacementSubnode;

- (void)removeFromSupernode;
/*-------------------------------------------node 树操作-----------------------------------*/


@end



@interface FDisplayNode(UIViewBridge)

- (void)setNeedsDisplay ;
- (void)setNeedsLayout;
/*----------UIView----------*/
@property (atomic, assign)           BOOL clipsToBounds;                    // default==NO
@property (atomic, assign)           BOOL autoresizesSubviews;              // default==YES (undefined for layer-backed nodes)
@property (atomic, assign)           UIViewAutoresizing autoresizingMask;   // default==UIViewAutoresizingNone  (undefined for layer-backed nodes)
@property (atomic, retain)           UIColor *tintColor;                    // default=Blue
@property (atomic, assign)           UIViewContentMode contentMode;         // default=UIViewContentModeScaleToFill

@property (atomic, assign, getter=isUserInteractionEnabled) BOOL userInteractionEnabled; // default=YES (NO for layer-backed nodes)
@property (atomic, assign, getter=isExclusiveTouch) BOOL exclusiveTouch;    // default=NO
/*----------UIView----------*/

/*----------CALayer---------*/
@property (atomic, retain)           id contents;                           // default=nil
@property (atomic, getter=isOpaque)  BOOL opaque;                           // default==YES
@property (atomic, assign)           BOOL allowsEdgeAntialiasing;
@property (atomic, assign)           unsigned int edgeAntialiasingMask;     // default==all values from CAEdgeAntialiasingMask
@property (atomic, getter=isHidden)  BOOL hidden;                           // default==NO
@property (atomic, assign)           BOOL needsDisplayOnBoundsChange;       // default==NO
@property (atomic, assign)           CGFloat alpha;                         // default=1.0f
@property (atomic, assign)           CGRect bounds;                         // default=CGRectZero
@property (atomic, assign)           CGRect frame;

// default=CGRectZero
@property (atomic, assign)           CGPoint anchorPoint;                   // default={0.5, 0.5}
@property (atomic, assign)           CGFloat zPosition;                     // default=0.0
@property (atomic, assign)           CGPoint position;                      // default=CGPointZero
@property (atomic, assign)           CGFloat cornerRadius;                  // default=0.0
@property (atomic, assign)           CGFloat contentsScale;                 // default=1.0f. See @contentsScaleForDisplay for more info
@property (atomic, assign)           CATransform3D transform;               // default=CATransform3DIdentity
@property (atomic, assign)           CATransform3D subnodeTransform;        // default=CATransform3DIdentity
@property (atomic, copy)             NSString *name;                        // default=nil. Use this to tag your layers in the server-recurse-description / pca or
@property (atomic, retain)           UIColor *backgroundColor;              // default=nil

@property (atomic, assign)           CGColorRef shadowColor;                // default=opaque rgb black
@property (atomic, assign)           CGFloat shadowOpacity;                 // default=0.0
@property (atomic, assign)           CGSize shadowOffset;                   // default=(0, -3)
@property (atomic, assign)           CGFloat shadowRadius;                  // default=3
@property (atomic, assign)           CGFloat borderWidth;                   // default=0
@property (atomic, assign)           CGColorRef borderColor;                // default=opaque rgb black
/*----------CALayer---------*/

// Accessibility support
@property (atomic, assign)           BOOL isAccessibilityElement;
@property (atomic, copy)             NSString *accessibilityLabel;
@property (atomic, copy)             NSString *accessibilityHint;
@property (atomic, copy)             NSString *accessibilityValue;
@property (atomic, assign)           UIAccessibilityTraits accessibilityTraits;
@property (atomic, assign)           CGRect accessibilityFrame;
@property (atomic, retain)           NSString *accessibilityLanguage;
@property (atomic, assign)           BOOL accessibilityElementsHidden;
@property (atomic, assign)           BOOL accessibilityViewIsModal;
@property (atomic, assign)           BOOL shouldGroupAccessibilityChildren;


@end


@interface FDisplayNode(SubClassing)

- (void)didLoadLayer ;
- (void)layout ;
- (void)layoutDidFinish ;
- (CGSize)calculateSizeThatFits:(CGSize)constrainedSize ;
- (void)invalidateCalculatedSize ;
- (void)clearContents ;
- (void)displayWillStart ;
- (void)displayDidFinish ;

@end

@interface CALayer(FDisplayKit)

- (void)addSubnode:(FDisplayNode *)node;

@end
