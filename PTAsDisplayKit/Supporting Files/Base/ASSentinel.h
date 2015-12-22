//
//  ASSentinel.h
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/22.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @summary We want to avoid capturing layer instances on a background queue, but we want a way to cancel rendering
 immediately if another display pass begins.  ASSentinel is owned by the layer and passed to the background
 block.
 */
@interface ASSentinel : NSObject

/**
 Returns the current value of the sentinel.
 */
- (int32_t)value;

/**
 Atomically increments the value and returns the new value.
 */
- (int32_t)increment;

@end
