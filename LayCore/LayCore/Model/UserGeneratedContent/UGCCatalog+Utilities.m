//
//  UGCCatalog+Utilities.m
//  LayCore
//
//  Created by Rene Kollmorgen on 25.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "UGCCatalog+Utilities.h"
#import "UGCQuestion+Utilities.h"
#import "UGCExplanation+Utilities.h"
#import "UGCBox.h"
#import "UGCCase1.h"
#import "UGCCase2.h"
#import "UGCCase3.h"
#import "UGCStatistic.h"

#import "LayUserDataStore.h"
#import "LayMainDataStore.h"
#import "Question+Utilities.h"
#import "Answer.h"
#import "Catalog+Utilities.h"

#import "MWLogging.h"

@implementation UGCCatalog (Utilities)

// from mainStore -> userStore
-(void)syncStateOfQuestions:(NSArray*)listOfChangedQuestions {
    LayUserDataStore *store = [LayUserDataStore store];
    for (Question *question in listOfChangedQuestions) {
        UGCQuestion *uq = [self questionByName:question.name];
        if(!uq) {
            uq = [store insertObject:UGC_OBJECT_QUESTION];
        }
        uq.name = question.name;
        uq.question = question.question;
        uq.favourite = question.favourite;
        [self addQuestionsRefObject:uq];
        [self orderQuestion:uq dependingOn:question.answerRef];
        UGCBoxCaseId boxCaseId = [uq boxCaseId];
        // !!update some user generated properties in the main-store
        [question setCaseNumberPrimitive:boxCaseId];
    }
    
    [self updateNumbersOfWrongAndCorrectAnsweredQuestions:listOfChangedQuestions];
    
    [store saveChanges];
}

// from userStore -> mainStore
-(void)syncUserQuestionState:(NSArray*)listOfQuestions {
    for (Question *question in listOfQuestions) {
        UGCQuestion *uq = [self questionByName:question.name];
        if(uq) {
            UGCBoxCaseId boxCaseId = [uq boxCaseId];
            [question setCaseNumberPrimitive:boxCaseId];
            question.favourite = uq.favourite;
        }
    }
}

-(UGCQuestion*)questionInstance {
    LayUserDataStore *store = [LayUserDataStore store];
    UGCQuestion *uq  = [store insertObject:UGC_OBJECT_QUESTION];
    [self addQuestionsRefObject:uq];
    return uq;
}


-(void)updateNumbersOfWrongAndCorrectAnsweredQuestions:(NSArray*)listOfAnsweredQuestions {
    NSUInteger numberOfCorrectAnsweredQuestions = [self.statisticRef.correct unsignedIntegerValue];
    NSUInteger numberOfWrongAnsweredQuestions = [self.statisticRef.wrong unsignedIntegerValue];
    for (Question *question in listOfAnsweredQuestions) {
        if([question.answerRef.correctAnsweredByUser boolValue]) {
            numberOfCorrectAnsweredQuestions++;
        } else {
            numberOfWrongAnsweredQuestions++;
        }
    }
    self.statisticRef.correct = [NSNumber numberWithUnsignedInteger:numberOfCorrectAnsweredQuestions];
    self.statisticRef.wrong = [NSNumber numberWithUnsignedInteger:numberOfWrongAnsweredQuestions];
}

-(UGCQuestion*)questionByName:(NSString*)name {
    UGCQuestion *question = nil;
    for (UGCQuestion *uq in self.questionsRef) {
        if([uq.name isEqualToString:name]) {
            question = uq;
            break;
        }
    }
    return question;
}

-(void)orderQuestion:(UGCQuestion*)uq dependingOn:(Answer*)answer {
    if(uq.case1Ref) {
        if([answer.correctAnsweredByUser boolValue]) {
            uq.case2Ref = self.boxRef.case2Ref;
            uq.case1Ref = nil;
            MWLogDebug([UGCCatalog class], @"Order question named:%@ to case2.", uq.name);
        }
    } else if(uq.case2Ref) {
        if([answer.correctAnsweredByUser boolValue]) {
            uq.case3Ref = self.boxRef.case3Ref;
            uq.case2Ref = nil;
            MWLogDebug([UGCCatalog class], @"Order question named:%@ to case3.", uq.name);
        } else {
            uq.case1Ref = self.boxRef.case1Ref;
            uq.case2Ref = nil;
            MWLogDebug([UGCCatalog class], @"Order question named:%@ to case1.", uq.name);
        }
    } else if(uq.case3Ref) {
        if([answer.correctAnsweredByUser boolValue]) {
            uq.case4Ref = self.boxRef.case4Ref;
            uq.case3Ref = nil;
            MWLogDebug([UGCCatalog class], @"Order question named:%@ to case4.", uq.name);
        } else {
            uq.case2Ref = self.boxRef.case2Ref;
            uq.case3Ref = nil;
            MWLogDebug([UGCCatalog class], @"Order question named:%@ to case2.", uq.name);
        }
    } else if(uq.case4Ref) {
        if([answer.correctAnsweredByUser boolValue]) {
            uq.case5Ref = self.boxRef.case5Ref;
            uq.case4Ref = nil;
            MWLogDebug([UGCCatalog class], @"Order question named:%@ to case5.", uq.name);
        } else {
            uq.case3Ref = self.boxRef.case3Ref;
            uq.case4Ref = nil;
            MWLogDebug([UGCCatalog class], @"Order question named:%@ to case3.", uq.name);
        }
    } else if(uq.case5Ref) {
        if(![answer.correctAnsweredByUser boolValue]) {
            uq.case4Ref = self.boxRef.case4Ref;
            uq.case5Ref = nil;
            MWLogDebug([UGCCatalog class], @"Order question named:%@ to case4.", uq.name);
        }
    } else {
        if([answer.correctAnsweredByUser boolValue]) {
            uq.case2Ref = self.boxRef.case2Ref;
            MWLogDebug([UGCCatalog class], @"Order question named:%@ to case2.", uq.name);
        } else {
            uq.case1Ref = self.boxRef.case1Ref;
             MWLogDebug([UGCCatalog class], @"Order question named:%@ to case1.", uq.name);
        }
    }
}

-(UGCBoxCaseId)boxCaseIdOfQuestionWithName:(NSString*)name {
    UGCBoxCaseId boxCaseId = UGC_BOX_CASE_NOT_ANSWERED_QUESTION;
    UGCQuestion *question = [self questionByName:name];
    if(question) {
        if(question.case1Ref) {
            boxCaseId = UGC_BOX_CASE1;
        } else if(question.case2Ref) {
            boxCaseId = UGC_BOX_CASE2;
        } else if(question.case3Ref) {
            boxCaseId = UGC_BOX_CASE3;
        } else if(question.case4Ref) {
            boxCaseId = UGC_BOX_CASE4;
        } else if(question.case5Ref) {
            boxCaseId = UGC_BOX_CASE5;
        }
    }
    return boxCaseId;
}

-(NSSet*)questionSet {
    return self.questionsRef;
}

-(NSArray*)alreadyAnsweredQuestions {
    NSMutableArray *answeredQuestionList = [NSMutableArray arrayWithCapacity:20];
    for (UGCQuestion *uQuestion in self.questionsRef) {
        if(uQuestion.case1Ref ||
           uQuestion.case2Ref ||
           uQuestion.case3Ref ||
           uQuestion.case4Ref ||
           uQuestion.case5Ref) {
            [answeredQuestionList addObject:uQuestion];
        }
    }
    return answeredQuestionList;
}

-(NSUInteger)totalNumberCorrectAnsweredQuestions {
    return [self.statisticRef.correct unsignedIntegerValue];
}

-(NSUInteger)totalNumberIncorrectAnsweredQuestions {
    return [self.statisticRef.wrong unsignedIntegerValue];
}

-(UGCExplanation*)explanationByName:(NSString*)name {
    UGCExplanation *explanation = nil;
    for (UGCExplanation *ex in self.explanationRef) {
        if([ex.name isEqualToString:name]) {
            explanation = ex;
            break;
        }
    }
    return explanation;
}

-(UGCExplanation*)explanationInstance {
    LayUserDataStore *store = [LayUserDataStore store];
    UGCExplanation *ex  = [store insertObject:UGC_OBJECT_EXPLANATION];
    [self addExplanationRefObject:ex];
    return ex;
}

-(Catalog*)sourceCatalog {
    LayMainDataStore *mainStore = [LayMainDataStore store];
    Catalog *catalog = [mainStore findCatalogByTitle:self.title andPublisher:self.nameOfPublisher];
    if(!catalog) {
        MWLogError([UGCCatalog class], @"Did not find catalog:%@, %@ in MainStore", self.title, self.nameOfPublisher);
    }
    return catalog;
}

@end
