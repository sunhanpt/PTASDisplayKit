//
//  ASTransactionDispalyOperation.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/14.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//


#import "_ASAsyncTransactionDispalyOperation.h"
#import "ASAssert.h"

@interface  _ASAsyncTransactionDispalyOperation()
/**
 *  绘制返回的结果值
 */
@property (nonatomic, strong) id<NSObject> value;

@end

@implementation _ASAsyncTransactionDispalyOperation

- (id)initWithOperationDispalyBlock:(asyncdisplaykit_async_transaction_operation_block_t)displayBlock andCompletionBlock:(asyncdisplaykit_async_transaction_operation_completion_block_t)displayCompletionBlock
{
    self = [self init];
    if (self){
        _displayBlock = [displayBlock copy];
        _displayCompletionBlock = [displayCompletionBlock copy];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self){
        _displayBlock = nil;
        _displayCompletionBlock = nil;
        _value = nil;
    }
    return self;
}

- (void)dealloc
{
    ASDisplayNodeAssertNil(_displayCompletionBlock, @"Should have been called and released before -dealloc");
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)main
{
    // isCancelled可以通过cancel函数调用，也可以在取消transaction的时候调用
    if (self.isCancelled){
        return;
    }
    self.value = _displayBlock();
}
- (void)callAndReleaseCompletionBlock:(BOOL)canceled
{
    if (_displayCompletionBlock){
        _displayCompletionBlock(self.value, canceled);
        _displayCompletionBlock = nil;
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<ASDisplayNodeAsyncTransactionOperation: %p - value = %@", self, self.value];
}

@end