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
    [_labelNode.layer setFrame:CGRectMake(0, 0, self.contentView.frame.size.width - (indexLine) * 2, self.contentView.frame.size.height)];
    [_labelNode.layer setBackgroundColor:[UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.0].CGColor];
}

@end
