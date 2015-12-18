//
//  O2OTableViewCell.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/18.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "O2OTableViewCell.h"
#import "ASLabelNode.h"

@implementation O2OTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        ASLabelNode * labelNode = [[ASLabelNode alloc] init];
        [self.contentView.layer addSublayer:labelNode.layer];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView.layer layoutSublayers];
}

@end
