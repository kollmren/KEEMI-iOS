//
//  LayCatalogDataFile_HeadFirstDesignPattern.m
//  LayCore
//
//  Created by Rene Kollmorgen on 04.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayCatalogDataFile_HeadFirstDesignPattern.h"
#import "LayTestDataHelper.h"

#import "Catalog+Utilities.h"
#import "Answer+Utilities.h"
#import "Question+Utilities.h"
#import "AnswerItem+Utilities.h"
#import "Media+Utilities.h"
#import "Explanation+Utilities.h"

#import "LayAnswerType.h"

@interface LayCatalogDataFile_HeadFirstDesignPattern() {
    NSInteger numberOfQuestions;
    NSInteger numberOfCatalog;
    NSString* titleTemplate;
    NSString* pathToTestDataTemplate;
    Catalog *catalogRef;
}
@end

@implementation LayCatalogDataFile_HeadFirstDesignPattern

-(id)init {
    self = [super init];
    if(self) {
        pathToTestDataTemplate = @"TestData/headFirstDesignPattern/%@";
        titleTemplate = @"Head first design patterns %d";
        numberOfCatalog = 0;
        numberOfQuestions = 10;
    }
    return self;
}

-(void)data:(Catalog*)catalog {
    self->catalogRef = catalog;
    NSString *title = [[NSString alloc]initWithFormat:titleTemplate, numberOfCatalog];
    catalog.title = title;
    NSData* const cover = [LayTestDataHelper getDataOfFile:@"TestData/HeadFirstDesignPattern" andType:@"jpg"];
    [catalog setCoverImage:cover withType:LAY_FORMAT_JPG];
    catalog.catalogDescription = @"A detailed description ....";
    [catalog setAuthor:@"Oswald Kolle"];
    [catalog setPublisher:@"Oreilly"];
    NSData* const logo = [LayTestDataHelper getDataOfFile:@"TestData/headFirstDesignPattern/500px-O_Reilly_Media_logo" andType:@"png"];
    [catalog setPublisherLogo:logo withType:LAY_FORMAT_PNG];
    
    for (int i=1; i<=self->numberOfQuestions; ++i) {
        Question *question = [catalog questionInstance];
        [question setQuestionNumber:i];
        if(1==i) {
            [self questionOne:question];
            [catalog addQuestion:question];
        } else {
            if(i%3) {
                question.question = [NSString stringWithFormat:@"This is question number %d",i];
            } else {
                question.question = [NSString stringWithFormat:@"This is a long question. The question has the number %d. Every question has a number. The number can be used to ...",i];
            }
            if(i%2) {
                NSString *intro = [NSString stringWithFormat:@"This is an introduction! The number of the intro is %d. An intro can be long!",i];
                question.introduction = intro;
            }
            [self addAnswersTo:question];
            [catalog addQuestion:question];
        }
    }
}

-(void)addAnswersTo:(Question*)question {
    Answer *answer = [question answerInstance];
    answer.number = 1;
    [question setQuestionType:ANSWER_TYPE_MULTIPLE_CHOICE];
    AnswerItem *answerItem = [answer answerItemInstance];
    answerItem.text = @"This is an answer";
    [answer addAnswerItem:answerItem];
    
    [question setAnswer:answer];
}

-(NSString*)titleOfCatalog {
    return [[NSString alloc]initWithFormat:self->titleTemplate,numberOfCatalog];
}

-(void)setNumberOfCatalog:(NSUInteger)number {
    numberOfCatalog = number;
}

-(void)setNumberOfQuestions:(NSInteger)num {
    self->numberOfQuestions = num;
}

-(NSInteger) numberOfQuestions {
    return self->numberOfQuestions;
}

-(void)questionOne:(Question*)question {
    question.question = @"Which of the following statements apply to the initial design?";
    Answer *answer = [question answerInstance];
    answer.number = 1;
    [question setQuestionType:ANSWER_TYPE_MULTIPLE_CHOICE_LARGE_MEDIA];
    
    NSString *filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"StrategyPattern"];
    [LayTestDataHelper addFileAsMediaToAnswer:answer file:filePath type:@"svg"];
    
    AnswerItem *answerItem = [answer answerItemInstance];
    answerItem.text = @"Runtime behavior changes are difficult";
    answerItem.correct = YES;
    Explanation *explanation = [self->catalogRef explanationInstance];
    [explanation addShortExplanationText:@"Changes at runtime are difficult because ...."];
    [answerItem setExplanation:explanation];
    [answer addAnswerItem:answerItem];
    
    answerItem = [answer answerItemInstance];
    answerItem.text = @"The behavior could not appropiate for some other Duck subclasses";
    answerItem.correct = YES;
    [answer addAnswerItem:answerItem];
    
    answerItem = [answer answerItemInstance];
    answerItem.text = @"Qverriding behavior can lead to duplicate code across subclasses";
    [answer addAnswerItem:answerItem];
    
    answerItem = [answer answerItemInstance];
    answerItem.text = @"We can not make ducks dance";
    [answer addAnswerItem:answerItem];
    
    answerItem = [answer answerItemInstance];
    answerItem.text = @"Changes on behavior can unintentionally affect other ducks";
    [answer addAnswerItem:answerItem];
    
    [question setAnswer:answer];
}

@end
