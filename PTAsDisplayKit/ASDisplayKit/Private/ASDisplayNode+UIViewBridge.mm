//
//  ASDisplayNode+UIViewBridge.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/23.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//
#import "ASThread.h"
#import "ASDisplayNode.h"

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

#define _getFromLayer(layerProperty) __loaded ? _layer.layerProperty : self.pendingViewState.layerProperty

#define _setToLayer(layerProperty, layerValueExpr) __loaded ? _layer.layerProperty = (layerValueExpr) : self.pendingViewState.layerProperty = (layerValueExpr)

#define _messageToViewOrLayer(viewAndLayerSelector) __loaded ? (_view ? [_view viewAndLayerSelector] : [_layer viewAndLayerSelector]) : [self.pendingViewState viewAndLayerSelector]

#define _messageToLayer(layerSelector) __loaded ? [_layer layerSelector] : [self.pendingViewState layerSelector]

@implementation ASDisplayNode(UIViewBridge)

- (id)contents
{
    //_bridge_prologue;
    //return _getFromLayer(contents);
    return nil;
}

@end
