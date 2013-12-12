//
//  LayAnswerViewOrder.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 11.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayAnswerView.h"
#import "LayAnswerViewDelegate.h"

@class Answer, LayButton, LayQuestionBubbleView;
@interface LayAnswerViewOrder : UIView< LayAnswerView, UITableViewDataSource, UITableViewDelegate > {
    @private
    Answer* answer;
    NSMutableArray* answerItemColumnList;
    id<LayAnswerViewDelegate> delegate;
    BOOL userSetAnswer;
    BOOL userAnswerIsCorrect;
    LayButton* reorderCorrectButton;
}

@end
