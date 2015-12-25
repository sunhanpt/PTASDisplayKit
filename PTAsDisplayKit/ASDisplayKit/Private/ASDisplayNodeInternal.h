//
//  ASDisplayNodeInternal.h
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/24.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#ifndef ASDisplayNodeInternal_h
#define ASDisplayNodeInternal_h

#import "ASThread.h"
#import "ASDisplayNode.h"

@interface ASDisplayNode()<_ASDisplayLayerDelegate>
{
@protected
    // 线程锁
    ASDN::RecursiveMutex _propertyLock;
    // 包含的layer
    _ASDisplayLayer * _layer;
    // 包含的view
    _ASDisplayView * _view;
    
    // node的状态值，一次获取，保存，减少不必要的操作
    struct ASDisplayNodeFlags {
        // public property
        unsigned layerBacked:1;
        
        // whether custom drawing is enabled
        unsigned implementsDrawRect:1;
        unsigned implementsImageDisplay:1;
    } _flags;
}

@end

#endif /* ASDisplayNodeInternal_h */
