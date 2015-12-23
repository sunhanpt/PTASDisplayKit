//
//  _ASAsyncTransactionGroup.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/16.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "ASAssert.h"

#import "_ASDisplayLayer.h"
#import "_ASAsyncTransaction.h"
#import "_ASAsyncTransactionGroup.h"

static void _transactionGroupRunLoopObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info);

@interface _ASAsyncTransactionGroup ()
+ (void)registerTransactionGroupAsMainRunloopObserver:(_ASAsyncTransactionGroup *)transactionGroup;
- (void)commit;
@end

@implementation _ASAsyncTransactionGroup {
    NSHashTable *_displayLayers;
}

+ (_ASAsyncTransactionGroup *)mainTransactionGroup
{
    ASDisplayNodeAssertMainThread();
    static _ASAsyncTransactionGroup *mainTransactionGroup;
    
    if (mainTransactionGroup == nil) {
        mainTransactionGroup = [[_ASAsyncTransactionGroup alloc] init];
        [self registerTransactionGroupAsMainRunloopObserver:mainTransactionGroup];
    }
    return mainTransactionGroup;
}

+ (void)registerTransactionGroupAsMainRunloopObserver:(_ASAsyncTransactionGroup *)transactionGroup
{
    ASDisplayNodeAssertMainThread();
    static CFRunLoopObserverRef observer;
    ASDisplayNodeAssert(observer == NULL, @"A _ASAsyncTransactionGroup should not be registered on the main runloop twice");
    // defer the commit of the transaction so we can add more during the current runloop iteration
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFOptionFlags activities = (kCFRunLoopBeforeWaiting | // before the run loop starts sleeping
                                kCFRunLoopExit);          // before exiting a runloop run
    CFRunLoopObserverContext context = {
        0,           // version
        (__bridge void *)transactionGroup,  // info
        &CFRetain,   // retain
        &CFRelease,  // release
        NULL         // copyDescription
    };
    
    observer = CFRunLoopObserverCreate(NULL,        // allocator
                                       activities,  // activities
                                       YES,         // repeats
                                       INT_MAX,     // order after CA transaction commits
                                       &_transactionGroupRunLoopObserverCallback,  // callback
                                       &context);   // context
    CFRunLoopAddObserver(runLoop, observer, kCFRunLoopCommonModes);
    CFRelease(observer);
}

- (id)init
{
    if ((self = [super init])) {
        _displayLayers = [NSHashTable hashTableWithOptions:NSPointerFunctionsObjectPointerPersonality];
    }
    return self;
}

- (void)addDisplayLayer:(_ASDisplayLayer *)layer
{
    ASDisplayNodeAssertMainThread();
    ASDisplayNodeAssert(layer != nil, @"No layer");
    [_displayLayers addObject:layer];
}

- (void)commit
{
    ASDisplayNodeAssertMainThread();
    
    if ([_displayLayers count]) {
        NSHashTable *displayLayersToCommit = [_displayLayers copy];
        [_displayLayers removeAllObjects];
        
        for (_ASDisplayLayer * layer in displayLayersToCommit) {
            _ASAsyncTransaction * transaction = layer.asTransaction;
            layer.asTransaction = nil;
            [transaction commit];
        }
    }
}

+ (void)commit
{
    [[_ASAsyncTransactionGroup mainTransactionGroup] commit];
}

@end

static void _transactionGroupRunLoopObserverCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    ASDisplayNodeCAssertMainThread();
    _ASAsyncTransactionGroup *group = (__bridge _ASAsyncTransactionGroup *)info;
    [group commit];
}
