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


@implementation LayRandomLeitnerDatasource

static const NSInteger initIdxValueForGroupedQuestions = -1;

@synthesize considerTopicSelection;

-(id)initWithCatalog:(Catalog*)catalog_ considerTopicSelection:(BOOL)consider{
    self = [super init];
    if(self) {
        self->catalog = catalog_;
        considerTopicSelection = consider;
        self->index = 0;
        self->firstQuestionPassed = NO;
        self->groupedQuestionIndex = initIdxValueForGroupedQuestions;
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
    
    if( !self->currentQuestionGroupName ) {
        question = [self nextRandomQuestion];
    } else {
        MWLogDebug([LayRandomLeitnerDatasource class], @"Get(next) question within group:%@.", self->currentQuestionGroupName);
        BOOL breakPath = NO;
        question = [self nextGroupedQuestion:&breakPath];
        if(breakPath) {
            MWLogDebug([LayRandomLeitnerDatasource class], @"Break path for question:%@ in group:%@.", question.name, question.groupName );
            Question* nextQuestionFromRandomList = [self nextRandomQuestion];
            if( ![nextQuestionFromRandomList.groupName isEqualToString:self->currentQuestionGroupName] ) {
                MWLogDebug([LayRandomLeitnerDatasource class], @"Switch to first question in group from randomlist!" );
                // A group of questions at the end of the random list. Stay in the group!
                // Otherwise change to the next question.
                question = nextQuestionFromRandomList;
                self->currentQuestionGroupName = nil;
                self->firstQuestionInGroup = nil;
            } else {
                MWLogDebug([LayRandomLeitnerDatasource class], @"Stay in group:%@!", self->currentQuestionGroupName );
            }
        }
    }
    
    //
    if( question.groupName && !self->currentQuestionGroupName ) {
        MWLogDebug([LayRandomLeitnerDatasource class], @"First(next) question within group:%@.", question.groupName );
        self->currentQuestionGroupName = [NSString stringWithString:question.groupName];
        self->firstQuestionInGroup = question;
        self->currentGroupedQuestionList = nil;
        self->groupedQuestionIndex = initIdxValueForGroupedQuestions;
        self->cancelGroupMode = NO;
    }
    
    return question;
}

-(Question*) previousQuestion {
    Question *question = nil;
    if( !self->currentQuestionGroupName || self->cancelGroupMode  ) {
        question = [self previousRandomQuestion];
        self->cancelGroupMode = NO;
        self->currentQuestionGroupName = nil;
    } else {
        MWLogDebug([LayRandomLeitnerDatasource class], @"Get(prev) question within group:%@.", self->currentQuestionGroupName);
        BOOL breakPath = NO;
        question = [self previousGroupedQuestion:&breakPath];
        if(breakPath) {
            MWLogDebug([LayRandomLeitnerDatasource class], @"Break(prev) path for question:%@ in group:%@.", question.name, question.groupName );
            question = self->firstQuestionInGroup;
            self->cancelGroupMode = YES;
            MWLogDebug([LayRandomLeitnerDatasource class], @"Switch(prev) to first question:%@ in group:%@ from randomlist!", question.name, question.groupName );
        } else {
             MWLogDebug([LayRandomLeitnerDatasource class], @"Got(prev) question:%@ within group:%@.", question.name, self->currentQuestionGroupName);
        }
    }
    
    //
    if( question.groupName && !self->currentQuestionGroupName ) {
        MWLogDebug([LayRandomLeitnerDatasource class], @"First(prev) question within group:%@.", question.groupName );
        self->currentQuestionGroupName = [NSString stringWithString:question.groupName];
        self->groupedQuestionIndex = initIdxValueForGroupedQuestions;
        self->currentGroupedQuestionList = nil;
    }
    
    return question;
}

-(Question*)nextRandomQuestion {
    Question *question = nil;
    if(firstQuestionPassed && self->index < ([self->questionList count] - 1)) {
        self->index++;
    }
    
    MWLogDebug([LayRandomLeitnerDatasource class], @"Get question with index:%u",self->index);
    question = [questionList objectAtIndex:self->index];
    if(self->index==0)firstQuestionPassed = YES;
    
    return question;
}

-(Question*)previousRandomQuestion {
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

-(Question*) nextGroupedQuestion:(BOOL*)breakPath {
    self->groupedQuestionIndex++;
    Question *question = [self groupedQuestionWithIndex:self->groupedQuestionIndex and:breakPath];
    return question;
}

-(Question*) previousGroupedQuestion:(BOOL*)breakPath {
    Question *question = nil;
    self->groupedQuestionIndex--;
    question = [self groupedQuestionWithIndex:self->groupedQuestionIndex and:breakPath];
    return question;
}

-(Question*) groupedQuestionWithIndex:(NSInteger)questionIndex and:(BOOL*)breakPath {
    Question *question = nil;
    if( self->groupedQuestionMap ) {
        if( !self->currentGroupedQuestionList ) {
            self->currentGroupedQuestionList = [self->groupedQuestionMap valueForKey:self->currentQuestionGroupName];
        }
        
        if( self->currentGroupedQuestionList ) {
            const NSInteger numberOfQuestionsInGroup = [self->currentGroupedQuestionList count];
            if( questionIndex >= numberOfQuestionsInGroup ) {
                questionIndex = numberOfQuestionsInGroup - 1;
                *breakPath = YES;
            } else if( questionIndex < 0 ) {
                questionIndex = 0;
                *breakPath = YES;
            }
            question = [self->currentGroupedQuestionList objectAtIndex:questionIndex];
            MWLogDebug([LayRandomLeitnerDatasource class], @"Got question:%@ with index:%d from group:%@", question.name, questionIndex, self->currentQuestionGroupName );
        } else {
            MWLogError([LayRandomLeitnerDatasource class], @"Did not find a cached list with questions for group:%@!", self->currentQuestionGroupName);
            self->currentQuestionGroupName = nil;
            self->currentGroupedQuestionList = nil;
            self->groupedQuestionIndex = initIdxValueForGroupedQuestions;
        }
    } else {
        MWLogError([LayRandomLeitnerDatasource class], @"Started traversing group:%@ of questions but the map with grouped questions is empty!", self->currentQuestionGroupName);
    }
    return question;
}

-(NSUInteger) numberOfQuestions {
    return [self->questionList count];
}

-(NSUInteger) currentQuestionCounterValue {
    return self->index + 1;
}

-(NSUInteger) currentQuestionGroupCounterValue {
    NSUInteger counter = 0;
    if( self->currentQuestionGroupName ) {
        counter = self->groupedQuestionIndex  + 2;
    }
    return counter;
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
        BOOL takeQuestions = YES;
        if(self.considerTopicSelection) {
            takeQuestions = [topic topicIsSelected];
        }
        if(takeQuestions) {
            NSArray *sortedQuestionList = [topic questionsOrderedByNumber];
            NSString *currentNameOfQuestionGroup = nil;
            NSMutableArray *groupedQuestionList = nil;
            for (Question* q in sortedQuestionList) {
                BOOL ignoreQuestion = NO;
                if(q.groupName) {
                    MWLogDebug([LayRandomLeitnerDatasource class], @"Found question:%@ with groupName:%@.", q.name, q.groupName);
                    if(!self->groupedQuestionMap) {
                        MWLogDebug( [LayRandomLeitnerDatasource class], @"Create dictionary to cache grouped questions." );
                        self->groupedQuestionMap = [NSMutableDictionary dictionaryWithCapacity:10];
                    }
                    if( currentNameOfQuestionGroup && [currentNameOfQuestionGroup isEqualToString:q.groupName] ) {
                        // take the first / beginning question of a group only.
                        ignoreQuestion = YES;
                        if( ! groupedQuestionList ) {
                            groupedQuestionList = [NSMutableArray arrayWithCapacity:5];
                            MWLogDebug( [LayRandomLeitnerDatasource class], @"Create new list to cache questions for group:%@.", q.groupName );
                        }
                    } else if( groupedQuestionList ) {
                        MWLogDebug( [LayRandomLeitnerDatasource class], @"Add question group:%@ to dictionary.", currentNameOfQuestionGroup );
                        [self->groupedQuestionMap setObject:groupedQuestionList forKey:currentNameOfQuestionGroup];
                        groupedQuestionList = nil;
                    }
                    currentNameOfQuestionGroup = q.groupName;
                } else {
                    currentNameOfQuestionGroup = nil;
                }
                
                if(!ignoreQuestion) {
                    [allQuestions addObject:q];
                } else {
                    [groupedQuestionList addObject:q];
                    MWLogDebug([LayRandomLeitnerDatasource class], @"Ignore question with groupName;%@.", q.groupName);
                }
            }// for
            
            if( groupedQuestionList ) {
                MWLogDebug( [LayRandomLeitnerDatasource class], @"Add question group:%@ to dictionary.", currentNameOfQuestionGroup );
                [self->groupedQuestionMap setObject:groupedQuestionList forKey:currentNameOfQuestionGroup];
                groupedQuestionList = nil;
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
