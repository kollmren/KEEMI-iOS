//
//  LayAnswerItemView.h
//  Lay
//
//  Created by Rene Kollmorgen on 25.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayAnswerButtonDelegate.h"

@protocol LayAnswerItemViewDelegate <LayAnswerButtonDelegate>

@required
-(void) resized;
-(void) minimizedButtonTapped;
-(void) swipedTo:(LayAnswerButton*)currentAnswerButton;
@end


@class AnswerItem;
@protocol LayAnswerItemViewSolutionDelegate

@required
-(BOOL) isAnswerItemCorrect:(AnswerItem*)answerItem;
@end

//
// LayAnswerItemView
//
@class Answer;
@class AnswerItem;
@interface LayAnswerItemView : UIView<LayAnswerButtonDelegate,LayAnswerItemViewSolutionDelegate,UIScrollViewDelegate>

@property (nonatomic) BOOL showMinimizeButton;
@property (nonatomic) BOOL withBackground;
@property (nonatomic) CGFloat space;
@property (nonatomic,weak) id<LayAnswerItemViewDelegate> itemViewDelegate;
@property (nonatomic,weak) id<LayAnswerItemViewSolutionDelegate> itemViewSolutionDelegate;

-(id)initWithPosition:(CGPoint)position width:(CGFloat)width andAnswer:(Answer*)answer;

-(void)showSolution;

-(void)showButtonWith:(AnswerItem*)answerItem;

-(AnswerItem*)currentVisibleAnswerItem;

@end;
