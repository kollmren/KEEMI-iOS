//
//  LayRandomLeitnerDatasource.m
//  LayCore
//
//  Created by Rene Kollmorgen on 06.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayRandomLeitnerDatasource.h"

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"
#import "Topic+Utilities.h"

#import "LayUserDataStore.h"
#import "UGCCatalog+Utilities.h"

#import "MWLogging.h"

//!!Note: This implementation is still and simple index based!
@implementation LayRandomLeitnerDatasource

@synthesize considerTopicSelection;

-(id)initWithCatalog:(Catalog*)catalog_ considerTopicSelection:(BOOL)consider{
    self = [super init];
    if(self) {
        self->catalog = catalog_;
        considerTopicSelection = consider;
        self->index = 0;
        self->firstQuestionPassed = NO;
        [self preparingQuestionList:catalog_];
    }
    return self;
}

//
// LayQuestionDatasource
//
-(Catalog*) catalog {
    return self->catalog;
}

-(Question*) nextQuestion {
    Question *question = nil;
    if([questionList count]==0) {
        MWLogWarning([LayRandomLeitnerDatasource class], @"No questions in datasource!");
        return question;
    }
    
    
    if(firstQuestionPassed && self->index < ([self->questionList count] - 1)) {
        self->index++;
    }

    MWLogDebug([LayRandomLeitnerDatasource class], @"Get question with index:%u",self->index);
    question = [questionList objectAtIndex:self->index];
    if(self->index==0)firstQuestionPassed = YES;
    return question;
}

-(Question*) previousQuestion {
    Question *question = nil;
    if([questionList count]==0) {
        MWLogWarning([LayRandomLeitnerDatasource class], @"No questions in datasource!");
        return question;
    }
    
    if(self->index > 0) {
        self->index--;
    } 
    MWLogDebug([LayRandomLeitnerDatasource class], @"Get(previous) question with index:%u",self->index);
    question = [questionList objectAtIndex:self->index];
    return question;
}

-(NSUInteger) numberOfQuestions {
    return [self->questionList count];
}

-(NSUInteger) currentQuestionCounterValue {
    return self->index + 1;
}

-(void) randomizeQuestions:(NSMutableArray*)questionListToRandomize {
    for (NSUInteger x = 0; x < [questionListToRandomize count]; x++) {
        NSUInteger randInt = (random() % ([questionListToRandomize count] - x)) + x;
        [questionListToRandomize exchangeObjectAtIndex:x withObjectAtIndex:randInt];
    }
}

-(void) leitnerQuestions:(NSMutableArray*)questionListToLeitner withQuestionsStatesFromCatalog:(Catalog*)catalog_ {
    NSMutableArray *boxCase1 = [NSMutableArray arrayWithCapacity:50];
    NSMutableArray *boxCase2 = [NSMutableArray arrayWithCapacity:50];
    NSMutableArray *boxCase3 = [NSMutableArray arrayWithCapacity:50];
    NSMutableArray *boxCase4 = [NSMutableArray arrayWithCapacity:50];
    NSMutableArray *boxCase5 = [NSMutableArray arrayWithCapacity:50];
    LayUserDataStore *uStore = [LayUserDataStore store];
    UGCCatalog *uCatalog = [uStore findCatalogByTitle:catalog_.title andPublisher:[catalog_ publisher]];
    if(uCatalog) {
        for (Question *question in questionListToLeitner) {
            UGCBoxCaseId caseId = [uCatalog boxCaseIdOfQuestionWithName:question.name];
            switch (caseId) {
                case UGC_BOX_CASE1:
                    [boxCase1 addObject:question];
                    break;
                case UGC_BOX_CASE2:
                    [boxCase2 addObject:question];
                    break;
                case UGC_BOX_CASE3:
                    [boxCase3 addObject:question];
                    break;
                case UGC_BOX_CASE4:
                    [boxCase4 addObject:question];
                    break;
                case UGC_BOX_CASE5:
                    [boxCase5 addObject:question];
                    break;
                case UGC_BOX_CASE_NOT_ANSWERED_QUESTION:
                    [boxCase1 addObject:question];
                    break;
                default:
                    MWLogError([LayRandomLeitnerDatasource class], @"Unknown type of caseId:%u", caseId);
                    break;
            }
        }
    } else {
        for (Question *question in questionListToLeitner) {
            [boxCase1 addObject:question];
        }
    }
    // check if at least one box has one question
    if([boxCase1 count] == 0 &&
       [boxCase2 count] == 0 &&
       [boxCase3 count] == 0 &&
       [boxCase4 count] == 0 &&
       [boxCase5 count] == 0) {
        MWLogError([LayRandomLeitnerDatasource class], @"There are no questions in boxes 1-5!");
    } else {
        // 4.
        const CGFloat boxCase1Weight = 0.4f;
        const CGFloat boxCase2Weight = 0.2f;
        const CGFloat boxCase3Weight = 0.2f;
        const CGFloat boxCase4Weight = 0.1f;
        const CGFloat boxCase5Weight = 0.1f;
        NSUInteger numberOfQuestionsToOrder = [questionListToLeitner count];
        const NSUInteger numberOfQuestionsToGetFromCase1 = numberOfQuestionsToOrder * boxCase1Weight + 1.0f;
        const NSUInteger numberOfQuestionsToGetFromCase2 = numberOfQuestionsToOrder * boxCase2Weight + 1.0f;
        const NSUInteger numberOfQuestionsToGetFromCase3 = numberOfQuestionsToOrder * boxCase3Weight + 1.0f;
        const NSUInteger numberOfQuestionsToGetFromCase4 = numberOfQuestionsToOrder * boxCase4Weight + 1.0f;
        const NSUInteger numberOfQuestionsToGetFromCase5 = numberOfQuestionsToOrder * boxCase5Weight + 1.0f;
        NSUInteger currentIndex = 0;
        NSUInteger numberOfQuestionsToFetch = 0;
        NSRange removeRange = { 0 , 0 };
        while (currentIndex < numberOfQuestionsToOrder) {
            MWLogDebug([LayRandomLeitnerDatasource class], @"Leitner questions(currentIndex=%u)....", currentIndex);
            // Case 1
            numberOfQuestionsToFetch = numberOfQuestionsToGetFromCase1;
            if([boxCase1 count] < numberOfQuestionsToFetch) {
                numberOfQuestionsToFetch = [boxCase1 count];
            }
            
            for (NSUInteger q=0; q < numberOfQuestionsToFetch; ++q) {
                Question *question = [boxCase1 objectAtIndex:q];
                [questionListToLeitner replaceObjectAtIndex:currentIndex withObject:question];
                currentIndex++;
            }
            removeRange.length = numberOfQuestionsToFetch;
            [boxCase1 removeObjectsInRange:removeRange];
            
            // Case 2
            numberOfQuestionsToFetch = numberOfQuestionsToGetFromCase2;
            if([boxCase2 count] < numberOfQuestionsToFetch) {
                numberOfQuestionsToFetch = [boxCase2 count];
            }
            
            for (NSUInteger q=0; q < numberOfQuestionsToFetch; ++q) {
                Question *question = [boxCase2 objectAtIndex:q];
                [questionListToLeitner replaceObjectAtIndex:currentIndex withObject:question];
                currentIndex++;
            }
            removeRange.length = numberOfQuestionsToFetch;
            [boxCase2 removeObjectsInRange:removeRange];
            
            // Case 3
            numberOfQuestionsToFetch = numberOfQuestionsToGetFromCase3;
            if([boxCase3 count] < numberOfQuestionsToFetch) {
                numberOfQuestionsToFetch = [boxCase3 count];
            }
            
            for (NSUInteger q=0; q < numberOfQuestionsToFetch; ++q) {
                Question *question = [boxCase3 objectAtIndex:q];
                [questionListToLeitner replaceObjectAtIndex:currentIndex withObject:question];
                currentIndex++;
            }
            removeRange.length = numberOfQuestionsToFetch;
            [boxCase3 removeObjectsInRange:removeRange];
            
            // Case 4
            numberOfQuestionsToFetch = numberOfQuestionsToGetFromCase4;
            if([boxCase4 count] < numberOfQuestionsToFetch) {
                numberOfQuestionsToFetch = [boxCase4 count];
            }
            
            for (NSUInteger q=0; q < numberOfQuestionsToFetch; ++q) {
                Question *question = [boxCase4 objectAtIndex:q];
                [questionListToLeitner replaceObjectAtIndex:currentIndex withObject:question];
                currentIndex++;
            }
            removeRange.length = numberOfQuestionsToFetch;
            [boxCase4 removeObjectsInRange:removeRange];
            
            // Case 5
            numberOfQuestionsToFetch = numberOfQuestionsToGetFromCase5;
            if([boxCase5 count] < numberOfQuestionsToFetch) {
                numberOfQuestionsToFetch = [boxCase5 count];
            }
            
            for (NSUInteger q=0; q < numberOfQuestionsToFetch; ++q) {
                Question *question = [boxCase5 objectAtIndex:q];
                [questionListToLeitner replaceObjectAtIndex:currentIndex withObject:question];
                currentIndex++;
            }
            removeRange.length = numberOfQuestionsToFetch;
            [boxCase5 removeObjectsInRange:removeRange];
        }
    }
}

-(void)preparingQuestionList:(Catalog*)catalog_ {
    // 1. Get questions by selected topics into one list.
    // 2. Randomize the list with questions.
    // 3. Check each question if the user did already answer the question in the past.
    // 4. Consider the state of a question from step 2. to collect the final list.
    
    //1.
    NSMutableArray *allQuestions = [NSMutableArray arrayWithCapacity:[catalog_ numberOfQuestions]];
    for (Topic *topic in [catalog_ topicList]) {
        BOOL takeQuestion = YES;
        if(self.considerTopicSelection) {
            takeQuestion = [topic topicIsSelected];
        }
        if(takeQuestion) {
            NSSet *questionSet = [topic questionSet];
            for (Question* q in questionSet) {
                [allQuestions addObject:q];
            }
        }
    }
    
    if([allQuestions count]>0) {
        // 2.
        [self randomizeQuestions:allQuestions];
        // 3 + 4.
        [self leitnerQuestions:allQuestions withQuestionsStatesFromCatalog:catalog_];
    } else {
        MWLogError([LayRandomLeitnerDatasource class], @"Internal! No questions to order!");
    }
    
    self->questionList = allQuestions;
}

@end
