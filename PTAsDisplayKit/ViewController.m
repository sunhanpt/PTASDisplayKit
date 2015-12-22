//
//  ViewController.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/11.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "ViewController.h"
#import "_ASDisplayLayer.h"
#import "O2OTableView.h"




@interface ViewController ()
@property (nonatomic, strong) O2OTableView * tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[O2OTableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
