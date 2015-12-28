//
//  FDisplayNodeInternal.h
//  PTAsDisplayKit
//
//  Created by 净枫 on 15/12/25.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "_FDisplayLayer.h"
#import "FDisplayNode.h"


@interface FDisplayNode() <_FDisplayLayerDelegate>
{
@protected
    ASSentinel *_displaySentinel;
    CGFloat _contentsScale;
    CALayer *_layer;
    NSMutableArray *_subnodes ;
    FDisplayNode * __weak  _supernode ;
    Class _layerClass ;
    
    CGSize _size;
    CGSize _constrainedSize;
    //将即将展示还未展示的node保存起来
    NSMutableSet *_pendingDisplayNodes;

    
    struct {
        // public properties
        unsigned layerBacked:1;
        unsigned displaysAsynchronously:1;
        unsigned shouldRasterizeDescendants:1;
        unsigned displaySuspended:1;
        
        // whether custom drawing is enabled
        unsigned implementsDrawRect:1;
        unsigned implementsImageDisplay:1;
        unsigned implementsDrawParameters:1;
        
        // internal state
        unsigned isMeasured:1;
        
    } _flags;
}

@property (nonatomic, readonly, retain) _FDisplayLayer *asyncLayer;


- (void)_setSupernode:(FDisplayNode *)supernode ;
- (CGSize)_measure:(CGSize)constrainedSize;
- (void)displayImmediately;
- (void)_layout;


@end


@interface CALayer (FDisplayNodeInternal)
@property (nonatomic, assign, readwrite) FDisplayNode *asyncdisplaykit_node;
@end
