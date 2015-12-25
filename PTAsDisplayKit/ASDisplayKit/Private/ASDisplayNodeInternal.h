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
    ASDN::RecursiveMutex _propertyLock;
    
    _ASDisplayLayer * _layer;
    
    struct ASDisplayNodeFlags {
        // whether custom drawing is enabled
        unsigned implementsDrawRect:1;
        unsigned implementsImageDisplay:1;
    } _flags;
}

@end

#endif /* ASDisplayNodeInternal_h */
