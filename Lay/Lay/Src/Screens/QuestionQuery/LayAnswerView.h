//
//  LayAnswerView.h
//  Lay
//
//  Created by Rene Kollmorgen on 03.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LayAnswerViewDelegate.h"

@class Answer;
@class Question;
@protocol LayAnswerView <NSObject>

// A instance of an answer-view can be used multiple times to show different answers.
// For that reason each instance of an answer-view must do a cleanup at the beginning
// of the method showAnswer!
@required

// Setting up the answer-view properly here.
-(id<LayAnswerView>)initAnswerView;

// Returns the view whichs shows the answer. Is used after method
// showAnswer to add the view into the questionView.
-(UIView*)answerView;

// Parameters:
// answer: The answer to show. If the user has already set some or all answer-items of the answer, the answer-view must show
//         the already selected answer-items(See class AnswerIte, property setByUser).
// viewSize: the visible size for the answer-view
// userCanSetAnswer: YES- a user can set answers, NO- a user can not change the answer
// Returns the size needed by the answer-view to show the content.
-(CGSize)showAnswer:(Answer*)answer andSize:(CGSize)viewSize userCanSetAnswer:(BOOL)userCanSetAnswer;

// Based on the given answer(s) by the user, the answer-view shows the evalutaion.
-(void)showSolution;

// Returns YES - if the user started to answer the question(regardless if the user set all possible answers).
// NO - if the user did not set any answer.
-(BOOL)userSetAnswer;

// An answer-view is responsible for the evaluation of an answer.
-(BOOL)isUserAnswerCorrect;
//
-(void)setDelegate:(id<LayAnswerViewDelegate>)delegate;

@optional
-(void)showMarkIndicator:(BOOL)yesNo;

@end
