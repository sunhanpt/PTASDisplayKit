//
//  O2OTableViewCell.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/18.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "O2OTableViewCell.h"
#import "ASLabelNode.h"

@interface  O2OTableViewCell()

@property (nonatomic, strong) ASLabelNode * labelNode;

@end

@implementation O2OTableViewCell

static int indexLine = 0;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        _labelNode = [[ASLabelNode alloc] init];
        [self.contentView.layer addSublayer:_labelNode.layer];
    }
    return self;
}

- (void)layoutSubviews
{
    [_labelNode setFrame:CGRectMake(100, 0, self.contentView.frame.size.width - 100 - (indexLine++) * 1, self.contentView.frame.size.height)];
    [_labelNode setBackgroundColor:[UIColor colorWithRed:0 green:0.65 blue:0.65 alpha:1.0]];
    [_labelNode setText:self.name];
    [_labelNode setTextFont:[UIFont systemFontOfSize:16]];
    [_labelNode setTextColor:[UIColor redColor]];
}

@end
