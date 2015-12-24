//
//  ASLabelNode.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/18.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "ASLabelNode.h"

// test parameters
@interface ASLabelNodeDrawParameters : NSObject
@property (nonatomic, assign, readonly) CGPoint labelOrigin;
@property (nonatomic, assign, readonly) CGColorRef backgroundColor;
@property (nonatomic, assign, readonly) CGRect bounds;
@property (nonatomic, assign, readonly) CGRect frame;
@property (nonatomic, strong, readonly) NSString * text;
@property (nonatomic, assign, readonly) CGColorRef textColor;
@property (nonatomic, strong, readonly) UIFont * textFont;
@end

@implementation ASLabelNode

/**
 *  获取绘制参数
 *
 *  @param layer 传入的layer
 *
 *  @return 返回属性值
 */
- (NSObject *)drawParametersForAsyncLayer:(_ASDisplayLayer *)layer
{
    
    return nil;
}

+ (UIImage *)displayWithParameters:(id<NSObject>)parameters isCancelled:(async_operation_iscancelled_block_t)isCancelledBlock
{
    UILabel * label = [[UILabel alloc] init];
    [label setFrame: CGRectMake(0, 0, 100, 50)];
    label.backgroundColor = [UIColor redColor];
    label.text = @"test";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor colorWithRed:0.2 green:0.7 blue:0.5 alpha:1.0];
    
    UIGraphicsBeginImageContextWithOptions(label.frame.size, YES, 1.0);
    
    [[label layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

@end

