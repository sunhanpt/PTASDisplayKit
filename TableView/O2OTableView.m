//
//  O2OTableView.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/18.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//


#import "O2OTableView.h"
#import "O2OTableViewCell.h"

@interface O2OTableView()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation O2OTableView
#pragma mark - lifeCircle
- (id)init
{
    self = [super init];
    if (self){
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}
#pragma mark - dataSourceDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    O2OTableViewCell * tableViewCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([O2OTableViewCell class])];
    if (!tableViewCell){
        tableViewCell = [[O2OTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([O2OTableViewCell class])];
    }
    return tableViewCell;
}

#pragma mark - delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

@end