//
//  ViewController.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/11.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "ViewController.h"
#import "_ASAsyncTransaction.h"

@interface ASOperation : NSOperation

@end

@implementation ASOperation

- (void)main
{
    NSLog(@"test\n");
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // test
    _ASAsyncTransaction * transaction = [[_ASAsyncTransaction alloc] initWithCallbackQueue:nil completionBlock:^(_ASAsyncTransaction *completedTransaction, BOOL canceled) {
    }];
    for (int i = 0; i < 20; i++){
        _ASAsyncTransactionDispalyOperation * operation = [[_ASAsyncTransactionDispalyOperation alloc] initWithOperationDispalyBlock:^id<NSObject>{return nil;} andCompletionBlock:^(id<NSObject> value, BOOL canceled) {
            transaction addOperationWithBlock:<#^id<NSObject>(void)block#> completion:<#^(id<NSObject> value, BOOL canceled)completion#>
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
