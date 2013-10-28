//
//  LayAnswerViewSingleChoice.m
//  Lay
//
//  Created by Rene Kollmorgen on 15.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayAnswerViewSingleChoice.h"
#import "LayAnswerViewChoice.h"

@interface LayAnswerViewSingleChoice() {
    LayAnswerViewChoice *answerViewChoice;
}
@end

@implementation LayAnswerViewSingleChoice

-(id)init {
    self = [super init];
    if(self) {
        self->answerViewChoice = [[LayAnswerViewChoice alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
        self->answerViewChoice.mode = LAY_ANSWER_VIEW_SINGLE_CHOICE;
    }
    return self;
}

//
// LayAnswerView
//
-(id<LayAnswerView>)initAnswerView {
    self = [self init];
    return self;
}

-(CGSize)showAnswer:(Answer *)answer_
            andSize:(CGSize)viewSize
        userCanSetAnswer:(BOOL)userCanSetAnswer {
    return [self->answerViewChoice showAnswer:answer_ andSize:viewSize userCanSetAnswer:userCanSetAnswer];
}

-(void)showSolution {
    return [self->answerViewChoice showSolution];
}

-(BOOL)isUserAnswerCorrect {
    return [self->answerViewChoice isUserAnswerCorrect];
}

-(BOOL)userSetAnswer {
    return [self->answerViewChoice userSetAnswer];
}

-(UIView*)answerView {
    return [self->answerViewChoice answerView];
}

-(void)setDelegate:(id<LayAnswerViewDelegate>)delegate {
    [self->answerViewChoice setDelegate:delegate];
}

@end
