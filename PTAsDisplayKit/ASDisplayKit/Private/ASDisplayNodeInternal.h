//
//  ASDisplayNodeInternal.h
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/24.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#ifndef ASDisplayNodeInternal_h
#define ASDisplayNodeInternal_h

#import "_AS-objc-internal.h"
#import "ASThread.h"
#import "ASDisplayNode.h"

@interface ASDisplayNode()<_ASDisplayLayerDelegate>
{
@protected
    //ASDN::RecursiveMutex _propertyLock;
    
    //ASDisplayNode * __weak _supernode;
    //ASDN::RecursiveMutex _propertyLock;
}

@end

#endif /* ASDisplayNodeInternal_h */
