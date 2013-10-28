//
//  LayFrame.m
//  Lay
//
//  Created by Rene Kollmorgen on 18.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayFrame.h"

@implementation LayFrame

+(void)setSizeWith:(CGSize)newSize toView:(UIView*)view {
    CGRect viewFrame = view.frame;
    viewFrame.size = newSize;
    view.frame = viewFrame;
}

+(void)setWidthWith:(CGFloat)newWidth toView:(UIView*)view {
    CGRect viewFrame = view.frame;
    viewFrame.size.width = newWidth;
    view.frame = viewFrame;
}

+(void)setHeightWith:(CGFloat)newHeight toView:(UIView*)view animated:(BOOL)animated {
    CGRect newViewFrame = view.frame;
    newViewFrame.size.height = newHeight;
    if(animated) {
        view.layer.bounds = CGRectMake(0.0f, 0.0f, newViewFrame.size.width, newViewFrame.size.height);
        /*CABasicAnimation *animation = [CABasicAnimation
                                       animationWithKeyPath:@"bounds"];
        NSValue *toValue = [NSValue valueWithCGRect:newlayerFrame];
        [animation setToValue:toValue];
        [animation setDuration:2.5f];
        // Start the animation
        [CATransaction begin];
        [view.layer addAnimation:animation forKey:@"scale"];
        [CATransaction commit];*/
    } else {
        view.frame = newViewFrame;
    }
}

+(void)setPos:(CGPoint)newPosition toView:(UIView*)view {
    CGRect viewFrame = view.frame;
    viewFrame.origin = newPosition;
    view.frame = viewFrame;
}

+(void)setYPos:(CGFloat)yPos toView:(UIView*)view {
    CGRect viewFrame = view.frame;
    viewFrame.origin.y = yPos;
    view.frame = viewFrame;
}

+(void)setXPos:(CGFloat)xPos toView:(UIView*)view {
    CGRect viewFrame = view.frame;
    viewFrame.origin.x = xPos;
    view.frame = viewFrame;
}

+(CGFloat) heightForText:(NSString*)text withFont:(UIFont*)font maxLines:(NSInteger)maxNumberOfLines andCellWidth:(CGFloat)cellWidth {
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    const CGFloat lineHeight = ceil([font lineHeight]);
    const CGSize initialCalcSize = CGSizeMake(cellWidth, 0.0f);
    NSStringDrawingContext *stringDrawingContext = [NSStringDrawingContext new];
    CGRect textRectNeeded= [text boundingRectWithSize:initialCalcSize options:NSStringDrawingUsesLineFragmentOrigin attributes:stringAttributes context:stringDrawingContext];
    CGFloat heightForText = ceil(textRectNeeded.size.height);
    
    const NSInteger numberOfLines = heightForText / lineHeight;
    if(numberOfLines > maxNumberOfLines) {
        heightForText = maxNumberOfLines * lineHeight;
    }
    
    return heightForText;
}

@end
