//
//  ASDisplayNode+UIViewBridge.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/23.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//
#import "ASThread.h"
#import "ASDisplayNode.h"
#import "ASDisplayNodeInternal.h"

#define DISPLAYNODE_USE_LOCKS 1

#define __loaded (_layer != nil)

#if DISPLAYNODE_USE_LOCKS
#define _bridge_prologue ASDisplayNodeAssertThreadAffinity(self); ASDN::MutexLocker l(_propertyLock)
#else
#define _bridge_prologue ASDisplayNodeAssertThreadAffinity(self)
#endif


#define _getFromViewOrLayer(layerProperty, viewAndPendingViewStateProperty) __loaded ? \
(_view ? _view.viewAndPendingViewStateProperty : _layer.layerProperty )\
: self.pendingViewState.viewAndPendingViewStateProperty

#define _setToViewOrLayer(layerProperty, layerValueExpr, viewAndPendingViewStateProperty, viewAndPendingViewStateExpr) __loaded ? \
(_view ? _view.viewAndPendingViewStateProperty = (viewAndPendingViewStateExpr) : _layer.layerProperty = (layerValueExpr))\
: self.pendingViewState.viewAndPendingViewStateProperty = (viewAndPendingViewStateExpr)

#define _setToViewOnly(viewAndPendingViewStateProperty, viewAndPendingViewStateExpr) __loaded ? _view.viewAndPendingViewStateProperty = (viewAndPendingViewStateExpr) : self.pendingViewState.viewAndPendingViewStateProperty = (viewAndPendingViewStateExpr)

#define _getFromViewOnly(viewAndPendingViewStateProperty) __loaded ? _view.viewAndPendingViewStateProperty : self.pendingViewState.viewAndPendingViewStateProperty

//#define _getFromLayer(layerProperty) __loaded ? _layer.layerProperty : self.pendingViewState.layerProperty
#define _getFromLayer(layerProperty) _layer.layerProperty

//#define _setToLayer(layerProperty, layerValueExpr) __loaded ? _layer.layerProperty = (layerValueExpr) : self.pendingViewState.layerProperty = (layerValueExpr)
#define _setToLayer(layerProperty, layerValueExpr) do{ if(__loaded){_layer.layerProperty = (layerValueExpr);} }while(0);

#define _messageToViewOrLayer(viewAndLayerSelector) __loaded ? (_view ? [_view viewAndLayerSelector] : [_layer viewAndLayerSelector]) : [self.pendingViewState viewAndLayerSelector]

#define _messageToLayer(layerSelector) __loaded ? [_layer layerSelector] : [self.pendingViewState layerSelector]

@implementation ASDisplayNode(UIViewBridge)

- (id)contents
{
    _bridge_prologue;
    return _getFromLayer(contents);
}

- (void)setContents:(id)newContents
{
    _bridge_prologue;
    _setToLayer(contents, newContents);
}


- (BOOL)isOpaque
{
    _bridge_prologue;
    return _getFromLayer(isOpaque);
}

- (void)setOpaque:(BOOL)newOpaque
{
    _bridge_prologue;
    _setToLayer(opaque, newOpaque);
}

- (BOOL)isHidden
{
    _bridge_prologue;
    return  _getFromLayer(hidden);
}
- (void)setHidden:(BOOL)newHidden
{
    _bridge_prologue;
    _setToLayer(hidden, newHidden);
}

- (CGFloat)alpha
{
    _bridge_prologue;
    return _getFromLayer(opacity);
}

- (void)setAlpha:(CGFloat)alpha
{
    _bridge_prologue;
    _setToLayer(opacity, alpha);
}

- (CGRect)frame
{
    _bridge_prologue;
    CGPoint position = self.position;
    CGRect bounds = self.bounds;
    CGPoint anchorPoint = self.anchorPoint;
    CGPoint origin = CGPointMake(position.x - bounds.size.width * anchorPoint.x,
                                 position.y - bounds.size.height * anchorPoint.y);
    return CGRectMake(origin.x, origin.y, bounds.size.width, bounds.size.height);
}

- (void)setFrame:(CGRect)newFrame
{
    _bridge_prologue;
    if (1){ // 设置到layer
        [self __setSafeFrame:newFrame];
    }
    else{ // 设置到view
        
    }
}

- (void)__setSafeFrame:(CGRect)rect
{
    ASDisplayNodeAssertThreadAffinity(self);
    ASDN::MutexLocker l(_propertyLock);
    
    BOOL useLayer = (_layer && ASDisplayNodeThreadIsMain());
    
    CGPoint origin      = (useLayer ? _layer.bounds.origin : self.bounds.origin);
    CGPoint anchorPoint = (useLayer ? _layer.anchorPoint   : self.anchorPoint);
    
    CGRect  bounds      = (CGRect){ origin, rect.size };
    CGPoint position    = CGPointMake(rect.origin.x + rect.size.width * anchorPoint.x,
                                      rect.origin.y + rect.size.height * anchorPoint.y);
    
    if (useLayer) {
        _layer.bounds = bounds;
        _layer.position = position;
    } else {
        self.bounds = bounds;
        self.position = position;
    }
}

- (UIColor *)backgroundColor
{
    _bridge_prologue;
    return [UIColor colorWithCGColor:_getFromLayer(backgroundColor)];
}
- (void)setBackgroundColor:(UIColor *)newBackgroundColor
{
    _bridge_prologue;
    _setToLayer(backgroundColor, newBackgroundColor.CGColor);
}

- (CGRect)bounds
{
    _bridge_prologue;
    return _getFromLayer(bounds);
}
- (void)setBounds:(CGRect)newBounds
{
    _bridge_prologue;
    _setToLayer(bounds, newBounds);
}

@end
