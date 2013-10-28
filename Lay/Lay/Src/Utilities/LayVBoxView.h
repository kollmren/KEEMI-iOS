//
//  LayUIView.h
//  Lay
//
//  Created by Rene Kollmorgen on 05.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LayVBoxView

@required
// The space to the view above this view.
-(void)setSpaceAbove:(CGFloat)spaceAobove;
-(CGFloat)spaceAbove;

// If YES, no changes to the horizontal settings are made to this view
// neither the x-position not the width is touched.
-(void)setKeepWidth:(BOOL)keepWidth;
-(BOOL)keepWidth;

// left and right border
-(void)setBorder:(CGFloat)border;
-(CGFloat)border;

@end
