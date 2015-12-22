//
//  ASDisplayNode.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/17.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "ASDisplayNode.h"

@interface ASDisplayNode()

@end

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
//    _layer = [[_ASDisplayLayer alloc] initWithCallbackQueue:NULL completionBlock:^(_ASDisplayLayer *completedLayer, BOOL canceled) {
//        [completedLayer releaseAllOperations];
//        // TODO: 添加通知等其他操作
//    }];
    _layer = [[_ASDisplayLayer alloc] init];
    _layer.asyncDelegate = self;
    // test
    
}

#pragma mark - private
// test
- (async_operation_display_block_t)displayAsyncLayer:(_ASDisplayLayer *)asyncLayer asynchronously:(BOOL)asynchronously
{
    
    async_operation_display_block_t displayBlock = ^id{
        return [self.class displayWithParameters:nil isCancelled:nil];
    };
    return [displayBlock copy];
}


@end
