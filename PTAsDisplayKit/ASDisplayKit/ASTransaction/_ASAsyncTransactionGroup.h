//
//  _ASAsyncTransactionGroup.h
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/16.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#ifndef _ASAsyncTransactionGroup_h
#define _ASAsyncTransactionGroup_h

#import <UIKit/UIKit.h>


@class _ASDisplayLayer;

/// A group of transaction container layers, for which the current transactions are committed together at the end of the next runloop tick.
@interface _ASAsyncTransactionGroup : NSObject
/// The main transaction group is scheduled to commit on every tick of the main runloop.
+ (instancetype)mainTransactionGroup;
+ (void)commit;

/// Add a transaction container to be committed.
/// @param containerLayer A layer containing a transaction to be commited. May or may not be a container layer.
/// @see ASAsyncTransactionContainer
- (void)addDisplayLayer:(_ASDisplayLayer *)layer;
@end


#endif /* _ASAsyncTransactionGroup_h */
