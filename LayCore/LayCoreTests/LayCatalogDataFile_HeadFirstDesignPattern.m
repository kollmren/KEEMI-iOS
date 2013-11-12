//
//  LayCatalogDataFile_HeadFirstDesignPattern.m
//  LayCore
//
//  Created by Rene Kollmorgen on 04.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayCatalogDataFile_HeadFirstDesignPattern.h"
#import "LayCoreTestConfig.h"

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"
#import "Answer+Utilities.h"
#import "AnswerItem+Utilities.h"

@interface LayCatalogDataFile_HeadFirstDesignPattern() {
    NSInteger numberOfQuestions;
    NSInteger numberOfCatalog;
}
@end

@implementation LayCatalogDataFile_HeadFirstDesignPattern

-(id)init {
    self = [super init];
    if(self) {
        g_titleTemplate = @"%d Head first design patterns";
        numberOfCatalog = 0;
        numberOfQuestions = 10;
    }
    return self;
}

static NSString* g_titleTemplate;

-(void)data:(Catalog*)catalog {
    NSString *title = [[NSString alloc]initWithFormat:g_titleTemplate, numberOfCatalog];
    catalog.title = title;
    catalog.catalogDescription = @"A detailed description ....";
    [catalog setAuthorInfo:@"Oswald Kolle" andEmail:@"author@country.org"];
    [catalog setPublisher:@"Oreilly"];
    for (int i=1; i <= self->numberOfQuestions; ++i) {
        Question *question = [catalog questionInstance];
        [question setQuestionType:ANSWER_TYPE_MULTIPLE_CHOICE];
        [question setQuestionNumber:i];
        question.question = [NSString stringWithFormat:@"This is question number %d",i];
        /*if(i%2) {
            NSString *intro = [NSString stringWithFormat:@"This is an introduction! The number of the intro is %d. An intro can be long!",i];
            question.introduction = intro;
        }*/
        if(i==1) {
            [self addAnswersToQuestionOne:question];
        } else if(i==2) {
            [self addAnswersToQuestionTwo:question];
        } else if(i==3) {
            [self addAnswersToQuestionThree:question];
        } else {
            [self addAnswersTo:question];
        }
        
        [catalog addQuestion:question];
    }
}

-(void)addAnswersTo:(Question*)question {
    Answer *answer = [question answerInstance];
    AnswerItem *answerItem = [answer answerItemInstance];
    answerItem.text = @"This is an answer";
    [answer addAnswerItem:answerItem];
    
    [question setAnswer:answer];
}

-(void)addAnswersToQuestionOne:(Question*)question {
    Answer *answer = [question answerInstance];
    AnswerItem *answerItem = [answer answerItemInstance];
    answerItem.text = @"This is an answer 1";
    [answer addAnswerItem:answerItem];
    
    
    answerItem = [answer answerItemInstance];
    answerItem.text = @"This is an answer 2";
    [answer addAnswerItem:answerItem];
    
    answerItem = [answer answerItemInstance];
    answerItem.text = @"This is an answer 3";
    [answer addAnswerItem:answerItem];
    
    [question setAnswer:answer];
}

-(void)addAnswersToQuestionTwo:(Question*)question {
    Answer *answer = [question answerInstance];
    AnswerItem *answerItem = [answer answerItemInstance];
    answerItem.text = @"This is an answer 1";
    [answer addAnswerItem:answerItem];
    
    
    answerItem = [answer answerItemInstance];
    answerItem.text = @"This is an answer 2";
    [answer addAnswerItem:answerItem];
    [question setAnswer:answer];
}

-(void)addAnswersToQuestionThree:(Question*)question {
    Answer *answer = [question answerInstance];
    AnswerItem *answerItem = [answer answerItemInstance];
    answerItem.text = @"This is an answer 1";
    [answer addAnswerItem:answerItem];
    
    
    answerItem = [answer answerItemInstance];
    answerItem.text = @"This is an answer 2";
    [answer addAnswerItem:answerItem];
    
    answerItem = [answer answerItemInstance];
    answerItem.text = @"This is an answer 3";
    [answer addAnswerItem:answerItem];

    [question setAnswer:answer];
}

-(NSString*)titleOfCatalog {
    return [[NSString alloc]initWithFormat:g_titleTemplate, numberOfCatalog];
}

-(NSString*)nameOfPublisher {
    return @"Oreilly";
}

-(void)setNumberOfQuestions:(NSInteger)num {
    self->numberOfQuestions = num;
}

-(void)setNumberOfCatalog:(NSUInteger)number {
    numberOfCatalog = number;
}

-(NSInteger) numberOfQuestions {
    return self->numberOfQuestions;
}

@end
