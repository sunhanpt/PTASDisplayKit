//
//  ASDisplayNode.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/17.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "ASDisplayNode.h"
#import "ASDisplayNodeInternal.h"
#import <objc/runtime.h>

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
    // 获取node的flags
    _flags = GetASDisplayNodeFlags(self.class, nil);
}

#pragma mark - _ASDisplayLayerDelegate
- (async_operation_display_block_t)displayAsyncLayer:(_ASDisplayLayer *)asyncLayer isCancelledBlock:(async_operation_iscancelled_block_t)isCacelledBlock asynchronously:(BOOL)asynchronously
{
    // TODO: 添加rasterizing参数，并添加相关逻辑
    if (_flags.implementsImageDisplay){
        async_operation_display_block_t displayBlock = ^id{
            if (isCacelledBlock && isCacelledBlock()){
                return nil;
            }
            return [self.class displayWithParameters:nil isCancelled:nil];
        };
        return [displayBlock copy];
    }
    else if (_flags.implementsDrawRect){
        CGRect bounds = self.bounds;
        if (CGRectIsEmpty(bounds)){
            return nil;
        }
        id drawParameters = [self drawParametersForAsyncLayer:_layer];
        BOOL opaque = self.opaque;
        async_operation_display_block_t displayBlock = ^id{
            if (isCacelledBlock && isCacelledBlock()){
                return nil;
            }
            UIGraphicsBeginImageContextWithOptions(bounds.size, opaque, 1.0);
            [self.class drawRect:bounds withParameters:drawParameters isCancelled:isCacelledBlock isRasterizing:NO];
            if (isCacelledBlock()){
                UIGraphicsEndImageContext();
                return nil;
            }
            UIImage * image = nil;
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return image;
        };
        return [displayBlock copy];
    }
    return nil;
}

#pragma mark - static methods
// 标记是否实现子函数，避免重复判定，增加运行效率
static struct ASDisplayNodeFlags GetASDisplayNodeFlags(Class c, ASDisplayNode *instance)
{
    ASDisplayNodeCAssertNotNil(c, @"class is required");
    
    struct ASDisplayNodeFlags flags = {0};
    
    flags.implementsDrawRect = ([c respondsToSelector:@selector(drawRect:withParameters:isCancelled:isRasterizing:)] ? 1 : 0);
    //flags.implementsImageDisplay = ([c respondsToSelector:@selector(displayWithParameters:isCancelled:)] ? 1 : 0);
    flags.implementsImageDisplay = ([c respondsToSelector:@selector(displayWithParameters:isCancelled:)] ? 1 : 0);
    return flags;
}
@end
