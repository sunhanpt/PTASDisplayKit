//
//  ASLabelNode.h
//  PTAsDisplayKit
//
//  Created by sunhanpt-pc on 15/12/18.
//  Copyright © 2015年 sunhanpt-pc. All rights reserved.
//

#ifndef ASLabelNode_h
#define ASLabelNode_h

#import "ASDisplayNode.h"

@interface ASLabelNode : ASDisplayNode

@property (atomic, strong) NSString * text;
@property (atomic, strong) UIFont * textFont;
@property (atomic, strong) UIColor * textColor;

@end


#endif /* ASLabelNode_h */
