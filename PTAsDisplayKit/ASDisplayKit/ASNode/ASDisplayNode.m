//
//  ASDisplayNode.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/17.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "ASDisplayNode.h"
#import "ASDisplayNodeInternal.h"

@implementation ASDisplayNode

#pragma mark - lifeCircle
- (id)init
{
    self = [super init];
    if (self){
        [self _initializeInstance];
    }
    return self;
}

- (void)addSubnode:(ASDisplayNode *)subnode
{
    
}

- (CGSize)calculatedSize
{
    return CGSizeMake(200, 200);
}

#pragma mark - private
- (void)_initializeInstance
{
    _layer = [[_ASDisplayLayer alloc] init];
    _layer.asyncDelegate = self;
}

#pragma mark - _ASDisplayLayerDelegate
- (async_operation_display_block_t)displayAsyncLayer:(_ASDisplayLayer *)asyncLayer isCancelledBlock:(async_operation_iscancelled_block_t)isCacelledBlock asynchronously:(BOOL)asynchronously
{
    async_operation_display_block_t displayBlock = ^id{
        if (isCacelledBlock && isCacelledBlock()){
            return nil;
        }
        return [self.class displayWithParameters:nil isCancelled:nil];
    };
    return [displayBlock copy];
}


@end
