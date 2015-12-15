//
//  ViewController.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/11.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "ViewController.h"

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
    // Do any additional setup after loading the view, typically from a nib.
    NSOperationQueue * queue = [NSOperationQueue new];
    ASOperation * operation = [ASOperation new];
    [queue addOperation:operation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
