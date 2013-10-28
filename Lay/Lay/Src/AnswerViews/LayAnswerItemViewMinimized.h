//
//  LayAnswerItemView.h
//  Lay
//
//  Created by Rene Kollmorgen on 25.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayAnswerItemView.h"

@class Answer;
@interface LayAnswerItemViewMinimized : UIView<LayAnswerItemViewDelegate>

-(id)initWithMinimizedPosition:(CGPoint)minimizedPos width:(CGFloat)width andAnswer:(Answer*)answer;

-(void)showSolution;

@end;
