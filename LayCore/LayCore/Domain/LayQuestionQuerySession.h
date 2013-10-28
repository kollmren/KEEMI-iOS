//
//  LayQuestionQuerySession.h
//  LayCore
//
//  Created by Rene Kollmorgen on 06.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LayQuestionDatasource.h"

@class Question;
@interface LayQuestionQuerySession : NSObject<LayQuestionDatasource>

@property (nonatomic, readonly) NSUInteger numberOfWrongAnsweredQuestions;
@property (nonatomic, readonly) NSUInteger numberOfCorrectAnsweredQuestions;
@property (nonatomic, readonly) NSUInteger numberOfSkippedQuestions;
@property (nonatomic, readonly) NSTimeInterval neededTime;

-(id) initWithDatasource:(id<LayQuestionDatasource>)datasource;

-(Question*) answeredQuestionByNumber:(NSUInteger)number;

-(NSArray*)updatedQuestionList;

-(void)finish;

@end
