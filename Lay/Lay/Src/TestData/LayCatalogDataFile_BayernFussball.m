//
//  LayCatalogDataFile_HeadFirstDesignPattern.m
//  LayCore
//
//  Created by Rene Kollmorgen on 04.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayCatalogDataFile_BayernFussball.h"
#import "LayTestDataHelper.h"

#import "Catalog+Utilities.h"
#import "Answer+Utilities.h"
#import "Question+Utilities.h"
#import "AnswerItem+Utilities.h"

#import "LayAnswerType.h"

@interface LayCatalogDataFile_BayernFussball() {
    NSInteger numberOfQuestions;
    NSInteger numberOfCatalog;
    NSString* pathToTestDataTemplate;
}
@end

@implementation LayCatalogDataFile_BayernFussball

-(id)init {
    self = [super init];
    if(self) {
        g_titleTemplate = @"Bayern München %d";
        pathToTestDataTemplate = @"TestData/bayernMuenchen/%@";
        numberOfCatalog = 0;
        numberOfQuestions = 10;
    }
    return self;
}

static NSString* g_titleTemplate;

-(void)data:(Catalog*)catalog {
    numberOfCatalog++;
    NSString *title = [[NSString alloc]initWithFormat:g_titleTemplate, numberOfCatalog];
    catalog.title = title;
    NSData* const cover = [LayTestDataHelper getDataOfFile:@"TestData/bayernMuenchen/cover" andType:@"jpg"];
    [catalog setCoverImage:cover withType:LAY_FORMAT_JPG];
    catalog.catalogDescription = @"A detailed description ....";
    [catalog setAuthor:@"SPORT BILD"];
    [catalog setPublisher:@"SPORT BILD"];
    NSData* const logo = [LayTestDataHelper getDataOfFile:@"TestData/bayernMuenchen/logo" andType:@"jpg"];
    [catalog setPublisherLogo:logo withType:LAY_FORMAT_PNG];
    const int MAX_QUESTIONS_TO_IMPORT = 30;
    for (int i=1; i<=MAX_QUESTIONS_TO_IMPORT; ++i) {
        Question *question = [catalog questionInstance];
        [question setQuestionNumber:i];
        NSString* methodName = [@"question" stringByAppendingString:[NSString stringWithFormat:@"%d:", i]];
        SEL selector = NSSelectorFromString(methodName);
        if ([self respondsToSelector: selector]) {
            [self performSelector:selector withObject:question];
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
    return [[NSString alloc]initWithFormat:g_titleTemplate, numberOfCatalog];
}

-(NSString*)nameOfPublisher {
    return @"Bayern";
}

-(void)setNumberOfQuestions:(NSInteger)num {
    self->numberOfQuestions = num;
}

-(NSInteger) numberOfQuestions {
    return self->numberOfQuestions;
}

-(void)question1:(Question*)question {
    question.question = @"In welchen Vereinen spielte Arjen Robben bereits?";
    Answer *answer = [question answerInstance];
    answer.number = 1;
    [question setQuestionType:ANSWER_TYPE_MULTIPLE_CHOICE_LARGE_MEDIA];
    AnswerItem *answerItem = [answer answerItemInstance];
    NSString *filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"arjenRobben"];
    [LayTestDataHelper addFileAsMediaToAnswer:answer file:filePath type:@"jpg" linkedWith:answerItem];
    answerItem.text = @"FC Chelsea";
    filePath = [NSString stringWithFormat:self->pathToTestDataTemplate, @"ChelseaLogo"];
    [LayTestDataHelper addFileAsMediaToAnswerItem:answerItem file:filePath type:@"png"];
    answerItem.correct = YES;
    [answer addAnswerItem:answerItem];
    
    //Van_Gogh_Age_19
    
    answerItem = [answer answerItemInstance];
    answerItem.text = @"Real Madrid";
    answerItem.correct = YES;
    answerItem.correct = [NSNumber numberWithBool:YES];
    [answer addAnswerItem:answerItem];
    
    answerItem = [answer answerItemInstance];
    answerItem.text = @"Hamburger SV";
    answerItem.correct = NO;
    answerItem.correct = [NSNumber numberWithBool:YES];
    [answer addAnswerItem:answerItem];
    
    [question setAnswer:answer];
}

-(NSString*) retrieveQuestion:(NSArray*)fields {
    for(NSString* s in fields) {
        if([s hasPrefix:@"DataType<:>Question<;>"]) {
            NSArray* fields = [s componentsSeparatedByString:@"<;>"];
            return [fields objectAtIndex:1];
        }
    }
    return nil;
}

-(NSDictionary*) retrieveAnswerData:(NSArray*)fields {
    for(NSString* s in fields) {
        if([s hasPrefix:@"DataType<:>Answer<;>"]) {
            return [self splitData:s];
        }
    }
    return nil;
}

-(NSArray*) retrieveAnswerItemData:(NSArray*)fields {
    NSMutableArray* result = [NSMutableArray new];
    for(NSString* s in fields) {
        if([s hasPrefix:@"DataType<:>AnswerItem<;>"]) {
            [result addObject:[self splitData:s]];
        }
    }
    return result;
}

-(NSDictionary*) splitData:(NSString*)data {
    NSMutableDictionary* result = [NSMutableDictionary new];
    NSArray* fields = [data componentsSeparatedByString:@"<;>"];
    for(NSString* s in fields) {
        NSArray* d = [s componentsSeparatedByString:@"<:>"];
        [result setObject:[d objectAtIndex:1] forKey:[d objectAtIndex:0]];
    }
    return result;
}

@end
