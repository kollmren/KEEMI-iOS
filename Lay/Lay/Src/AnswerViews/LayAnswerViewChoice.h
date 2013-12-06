//
//  LayAnswerViewMultipleChoice.h
//  Lay
//
//  Created by Rene Kollmorgen on 03.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayAnswerView.h"
#import "LayAnswerButtonDelegate.h"
#import "LayImageRibbonDelegate.h"

typedef enum LAY_ANSWER_VIEW_CHOICE_MODE_ {
    LAY_ANSWER_VIEW_MULTIPLE_CHOICE, // default
    LAY_ANSWER_VIEW_SINGLE_CHOICE
} LAY_ANSWER_VIEW_CHOICE_MODE;

@interface LayAnswerViewChoice : UIView<LayAnswerView, LayAnswerButtonDelegate, LayImageRibbonDelegate>

@property (nonatomic) LAY_ANSWER_VIEW_CHOICE_MODE mode;

@property (nonatomic) BOOL showMarkIndicatorInButtons;

@property (nonatomic) BOOL showMediaList;

@property (nonatomic) BOOL showAnswerItemsOrdered;

@property (nonatomic) BOOL showAnswerItemsRespectingLearnState;

@end
