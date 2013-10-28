//
//  LayVBoxLayout.h
//  Lay
//
//  Created by Rene Kollmorgen on 03.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

// An simple helper class whichs calculates the y-positions of
// subviews depending on the height and an given space.
@interface LayVBoxLayout : NSObject

// Sets the y-Pos, x-Pos and width of the subviews of superview.
// !! Only subviews of type LayVBoxView are considered.!!
// Returns the needed height of the subviews, but does not set this height
// to the superview!
+(CGFloat)layoutVBoxSubviewsInView:(UIView*)superView;


+(CGFloat)layoutVerticalSubviewsWithTagOrder:(NSUInteger*)tagList numberOfTags:(NSUInteger)numberOfTags inView:(UIView*)superView withSpace:(CGFloat)space;

+(CGFloat)layoutSubviewsOfView:(UIView*)superView withSpace:(CGFloat)space;

+(CGFloat)layoutSubviewsOfView:(UIView*)superView withSpace:(CGFloat)space andBorder:(CGFloat)border;

+(CGFloat)layoutSubviewsOfView:(UIView*)superView withSpace:(CGFloat)space andBorder:(CGFloat)border ignore:(NSInteger)tag;

+(CGFloat)neededHeightOfSubviewsOfView:(UIView*)superView;

// Only an simple helper method which does the frame assignment.
+(void)setHeight:(CGFloat)height forView:(UIView*)view;

@end
