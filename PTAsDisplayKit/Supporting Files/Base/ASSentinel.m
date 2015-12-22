//
//  ASSentinel.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/22.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "ASSentinel.h"

#import <libkern/OSAtomic.h>

@implementation ASSentinel
{
    int32_t _value;
}

- (int32_t)value
{
    return _value;
}

- (int32_t)increment
{
    return OSAtomicIncrement32(&_value);
}

@end

