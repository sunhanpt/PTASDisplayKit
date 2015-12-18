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
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(200, 100), 1.0, 1.0);
    
    UILabel * label = [[UILabel alloc] init];
    label.text = @"test";
    [[label layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

@end

