//
//  _FDisplayLayer.m
//  PTAsDisplayKit
//
//  Created by 净枫 on 15/12/24.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "_FDisplayLayer.h"
#import "ASAssert.h"
#import "FDisplayNode.h"


@implementation _FDisplayLayer{
    
    id<_FDisplayLayerDelegate> __weak _asyncDelegate;
}


- (instancetype)init{
    if(self = [super init]){
        _displaySentinel = [[ASSentinel alloc] init] ;
    }
    return self ;
}

#pragma mark setter and getter
- (id<_FDisplayLayerDelegate>)asyncDelegate{
    return _asyncDelegate ;
}

- (void)setAsyncDelegate:(id<_FDisplayLayerDelegate>)asyncDelegate{
    ASDisplayNodeAssert(!asyncDelegate || [asyncDelegate isKindOfClass:[FDisplayNode class]], @"_FDisplayLayer is inherently coupled to FDisplayNode and cannot be used with another asyncDelegate");
    _asyncDelegate = asyncDelegate ;
}

- (void)setContents:(id)contents{
    ASDisplayNodeAssertMainThread() ;
    [super setContents:contents];
}

- (void)setDisplaySuspended:(BOOL)displaySuspended{
    if(_displaySuspended != displaySuspended){
        _displaySuspended = displaySuspended ;
        if(!_displaySuspended){ //如果不暂停
            [self setNeedsDisplay];
        }else{
            [self cancelAsyncDisplay];
        }
    }
}

#pragma mark override CALayout method

- (void)layoutSublayers{
    [super layoutSublayers];
    //这里要进行node的布局
}

- (void)setNeedsLayout{
    ASDisplayNodeAssertMainThread() ;
    [super setNeedsLayout];
}

- (void)setNeedsDisplay{
    ASDisplayNodeAssertMainThread() ;
    //这里先取消异步绘制
    [self cancelAsyncDisplay];
    
    if(!_displaySuspended){
        [super setNeedsDisplay];
    }
}


- (void)display{
    
    ASDisplayNodeAssertMainThread() ;
    
    super.contents = super.contents;
    
    if(_displaySuspended){
        return ;
    }
    [self display:self.displaysAsyncChronously];
    
}

- (void)display:(BOOL)asynchronously{
    __weak typeof(self) weakSelf = self ;
    [self _performBlockWithAsyncDelegate:^(id<_FDisplayLayerDelegate> asyncDelegate) {
        async_operation_iscancelled_block_t isCancelledBlock = ^{
            ASSentinel * displaySentinel = weakSelf.displaysAsyncChronously ? _displaySentinel : nil;
            int32_t displaySentinelValue = [displaySentinel increment];
            return (BOOL)(displaySentinelValue != displaySentinel.value);
        };
        
        [asyncDelegate displayAsyncLayer:self isCancelledBlock:isCancelledBlock asynchronously:asynchronously];
    }];
}

- (void)cancelAsyncDisplay{
    [_displaySentinel increment];
    [self _performBlockWithAsyncDelegate:^(id<_FDisplayLayerDelegate> asyncDelegate) {
        [asyncDelegate cancelDisplayAsyncLayer:self];
    }];
}


- (void)displayImmediately{
    ASDisplayNodeAssertMainThread() ;
    [self display:NO];
}


#pragma mark - Helper Methods

- (void)_performBlockWithAsyncDelegate:(void(^)(id<_FDisplayLayerDelegate> asyncDelegate))block
{
    id<_FDisplayLayerDelegate> __attribute__((objc_precise_lifetime)) strongAsyncDelegate;
    {
        strongAsyncDelegate = _asyncDelegate;
    }
    block(strongAsyncDelegate);
}


@end
