//
//  LayQuestionView.h
//  Lay
//
//  Created by Rene Kollmorgen on 29.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayQuestionViewDelegate.h"
#import "LayQuestionDatasource.h"
#import "LayAnswerViewManager.h"
#import "LayAnswerViewDelegate.h"

@interface LayQuestionView : UIView<LayAnswerViewDelegate> {
    Question* currentQuestion;
    NSMutableDictionary* statistic;
}

// If all needed delegates are set this method must be called.
// Otherwise no Question/Answer is shown.
-(void)viewCanAppear;

@property (nonatomic,weak) id<LayQuestionViewDelegate> questionDelegate;

@property (nonatomic,weak) id<LayQuestionDatasource> questionDatasource;

@property (nonatomic,weak) id<LayAnswerViewManager> answerViewManager;

@property (nonatomic,readonly) UIToolbar* toolbar;

@property (nonatomic) UIButton *nextButton;

@property (nonatomic) UIButton *previousButton;

@property (nonatomic) UIButton *checkButton;

@property (nonatomic) UIButton *utilitiesButton;

-(void)showMiniIconsForQuestion;

-(void)viewWillAppear;

@end
