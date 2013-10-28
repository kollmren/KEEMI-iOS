//
//  LayFrame.h
//  Lay
//
//  Created by Rene Kollmorgen on 18.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LayFrame : NSObject

+(void)setSizeWith:(CGSize)newSize toView:(UIView*)view;

+(void)setWidthWith:(CGFloat)newWidth toView:(UIView*)view;

+(void)setHeightWith:(CGFloat)newHeight toView:(UIView*)view animated:(BOOL)animated;

+(void)setPos:(CGPoint)newPosition toView:(UIView*)view;

+(void)setYPos:(CGFloat)yPos toView:(UIView*)view;

+(void)setXPos:(CGFloat)xPos toView:(UIView*)view;

+(CGFloat) heightForText:(NSString*)text withFont:(UIFont*)font maxLines:(NSInteger)maxNumberOfLines andCellWidth:(CGFloat)cellWidth;

@end
