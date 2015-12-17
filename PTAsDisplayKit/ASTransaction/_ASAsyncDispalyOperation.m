//
//  ASTransactionDispalyOperation.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/14.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import <pthread.h>
#import <mach/mach.h>
#import "ASAssert.h"
#import "_ASAsyncDispalyOperation.h"

#if DEBUG
static inline void currentThreadInfo(NSString* str)
{
    if (str){
        NSLog(@"---------%@----------",str);
    }
    
    NSThread* thread = [NSThread currentThread];
    mach_port_t machTID = pthread_mach_thread_np(pthread_self());
    NSLog(@"current thread num: %x thread name:%@", machTID,thread.name);
    
    if (str){
        NSLog(@"-------------------");
    }
}


static inline void dumpThreads(NSString* str) {
    
    NSLog(@"---------%@----------",str);
    currentThreadInfo(nil);
    char name[256];
    thread_act_array_t threads = NULL;
    mach_msg_type_number_t thread_count = 0;
    task_threads(mach_task_self(), &threads, &thread_count);
    for (mach_msg_type_number_t i = 0; i < thread_count; i++) {
        thread_t thread = threads[i];
        pthread_t pthread = pthread_from_mach_thread_np(thread);
        pthread_getname_np(pthread, name, sizeof name);
        NSLog(@"mach thread %x: getname: %s", pthread_mach_thread_np(pthread), name);
    }
    NSLog(@"-------------------");
}
#endif


@interface  _ASAsyncDispalyOperation()
/**
 *  绘制返回的结果值
 */
@property (nonatomic, strong) id<NSObject> value;

@end

@implementation _ASAsyncDispalyOperation

- (id)initWithOperationDispalyBlock:(async_operation_display_block_t)displayBlock andCompletionBlock:(async_operation_completion_block_t)displayCompletionBlock
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
#if DEBUG
    dumpThreads(@"dealloc");
#endif
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
#if DEBUG
    currentThreadInfo(@"start");
#endif
    if (_displayBlock){
        self.value = _displayBlock();
    }
}

/**
 *  在NSOperationQueue中，取消一个operation并不会将其从队列中移除。只有当operation处于完成状态，queue才会将它移除。
 *  因此重写cancel，将状态值置为“完成”，之后queue会将其移除。
 */
- (void)cancel
{
    [super cancel];
    [self setValue:@(YES) forKey:@"isFinished"];
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