//
//  LayHintView.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 05.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayStyleGuide.h"

@interface LayHintView : UIView

@property (nonatomic) CGFloat duration;

- (id)initWithWidth:(CGFloat)width view:(UIView*)superView_ target:(id)target_ andAction:(SEL)action_;

-(void) showHint:(NSString*)hint withBorderColor:(LayStyleGuideColor)borderColor;

@end
