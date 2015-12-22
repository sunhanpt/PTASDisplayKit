//
//  _ASTransaction.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/15.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "ASAssert.h"
#import "ASSentinel.h"
#import "_ASDisplayLayer.h"
#import "_ASAsyncTransaction.h"
#import "_ASAsyncTransactionGroup.h"


@interface _ASDisplayLayer()

/**
 *  事务：包含operations
 */
@property (nonatomic, strong) _ASAsyncTransaction * asTransaction;
@property (nonatomic, strong) ASSentinel * displaySentinel;

@end

@implementation _ASDisplayLayer

#pragma mark - lifeCircle
- (id)init
{
    self = [super init];
    if (self){
        self.displaySentinel = [[ASSentinel alloc] init];
        self.opaque = YES;
        self.displaysAsynchronously = YES;
    }
    return self;
}

#pragma mark - getter and setter
- (_ASAsyncTransaction *)asTransaction
{
    if (!_asTransaction){
        _asTransaction = [[_ASAsyncTransaction alloc] initWithCallbackQueue:NULL completionBlock:^(_ASAsyncTransaction * asTransaction, BOOL canceled) {
            [asTransaction releaseAllOperations];
        }];
    }
    return _asTransaction;
}

#pragma mark - override method
- (void)setContents:(id)contents
{
    ASDisplayNodeAssertMainThread();
    [super setContents:contents];
}
- (void)display
{
    self.contents = super.contents;
    [self _performBlockWithAsyncDelegate:^(id<_ASDisplayLayerDelegate> asyncDelegate) {
        ASSentinel * displaySentinel = self.displaysAsynchronously ? _displaySentinel : nil;
        int32_t displaySentinelValue = [displaySentinel increment];
        async_operation_iscancelled_block_t isCancelledBlock = ^{
            return (BOOL)(displaySentinelValue != displaySentinel.value);
        };
        async_operation_display_block_t displayBlock = [asyncDelegate displayAsyncLayer:self  isCancelledBlock:isCancelledBlock asynchronously:YES];
        __weak typeof(self) weakSelf = self;
        [self.asTransaction addOperationWithBlock:[displayBlock copy] completion:^(id<NSObject> value, BOOL canceled) {
            __strong typeof(self) strongSelf = weakSelf;
            UIImage * image = (UIImage *)value;
            strongSelf.contents = (id)image.CGImage;
        }];
    }];
}

- (void)layoutSublayers
{
    ASDisplayNodeAssertMainThread();
    [super layoutSublayers];
    [self setNeedsDisplay];
}

- (void)setNeedsDisplay
{
    ASDisplayNodeAssertMainThread();
    [self cancelAsyncDisplay];
    
    [super setNeedsDisplay];
}
#pragma mark - private Methodes
- (void)cancelAsyncDisplay
{
    ASDisplayNodeAssertMainThread();
    [_displaySentinel increment];
}

#pragma mark - Helper Methods

- (void)_performBlockWithAsyncDelegate:(void(^)(id<_ASDisplayLayerDelegate> asyncDelegate))block
{
    id<_ASDisplayLayerDelegate> __attribute__((objc_precise_lifetime)) strongAsyncDelegate;
    {
        // TODO:加锁
        //ASDN::MutexLocker l(_asyncDelegateLock);
        strongAsyncDelegate = _asyncDelegate;
    }
    block(strongAsyncDelegate);
}

@end
