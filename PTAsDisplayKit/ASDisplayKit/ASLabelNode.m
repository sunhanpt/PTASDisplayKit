//
//  ASLabelNode.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/18.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "ASLabelNode.h"

@implementation ASLabelNode

+ (UIImage *)displayWithParameters:(id<NSObject>)parameters isCancelled:(asdisplaynode_iscancelled_block_t)isCancelledBlock
{
    
    UILabel * label = [[UILabel alloc] init];
    [label setFrame: CGRectMake(0, 0, 200, 100)];
    label.backgroundColor = [UIColor redColor];
    label.text = @"test";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor colorWithRed:0.2 green:0.7 blue:0.5 alpha:1.0];
    
    UIGraphicsBeginImageContextWithOptions(label.frame.size, NO, 1.0);
    
    [[label layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

@end

