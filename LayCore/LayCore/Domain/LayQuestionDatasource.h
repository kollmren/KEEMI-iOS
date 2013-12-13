//
//  LayQuestionDatasource.h
//  Lay
//
//  Created by Rene Kollmorgen on 29.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Catalog;
@class Question;

@protocol LayQuestionDatasource <NSObject>

@required
-(Catalog*) catalog;
// Returns nil if there is no questions or the end of the list of questions is reached
-(Question*) nextQuestion;

-(Question*) previousQuestion;

-(NSUInteger) numberOfQuestions;

-(NSUInteger) currentQuestionCounterValue;

-(NSUInteger) currentQuestionGroupCounterValue;

-(BOOL)hasNextGroupedQuestion;

@end
