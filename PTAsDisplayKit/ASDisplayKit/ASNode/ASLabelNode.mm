//
//  ASLabelNode.m
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/18.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#import "ASLabelNode.h"
#import "ASDisplayNodeInternal.h"

// test parameters
@interface ASLabelNodeDrawParameters : NSObject
@property (nonatomic, assign, readonly) CGRect bounds;
@property (nonatomic, strong, readonly) UIColor * backgroundColor;
@property (nonatomic, strong, readonly) NSString * text;
@property (nonatomic, strong, readonly) UIColor * textColor;
@property (nonatomic, strong, readonly) UIFont * textFont;

@end

@implementation ASLabelNodeDrawParameters

- (instancetype)initWithBounds:(CGRect)bounds backgroundColor:(UIColor *)backgroundColor text:(NSString *)text textColor:(UIColor *)textColor textFont:(UIFont *)textFont
{
    self = [super init];
    if (self){
        _bounds = bounds;
        _backgroundColor = backgroundColor;
        _text = text;
        _textColor = textColor;
        _textFont = textFont;
    }
    return self;
}

@end

@implementation ASLabelNode

#pragma mark setter and getter

#pragma mark implement _ASDisplayLayerDelegate
/**
 *  获取绘制参数
 *
 *  @param layer 传入的layer
 *
 *  @return 返回属性值
 */

- (NSObject *)drawParametersForAsyncLayer:(_ASDisplayLayer *)layer
{
    ASLabelNodeDrawParameters * parameters = [[ASLabelNodeDrawParameters alloc] initWithBounds:self.bounds backgroundColor:self.backgroundColor text:self.text textColor:self.textColor textFont:self.textFont];
    return parameters;
}

+ (void)drawRect:(CGRect)bounds withParameters:(ASLabelNodeDrawParameters *)parameters isCancelled:(async_operation_iscancelled_block_t)isCancelledBlock isRasterizing:(BOOL)isRasterizing
{
    if (isCancelledBlock()){
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    ASDisplayNodeAssert(context, @"This is no good without a context.");
    CGContextSaveGState(context);
    
    CGColorRef backgroundColor = parameters.backgroundColor.CGColor;
    CGContextSetFillColorWithColor(context, backgroundColor);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextFillRect(context, CGRectInset(bounds, -2, -2));
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:parameters.textFont, NSFontAttributeName, parameters.textColor, NSForegroundColorAttributeName, nil];
    
    [parameters.text drawInRect:parameters.bounds withAttributes:attributes];
    
    CGContextRestoreGState(context);
}

@end


