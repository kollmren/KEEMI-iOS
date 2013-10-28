//
//  UGCCatalog+Utilities.h
//  LayCore
//
//  Created by Rene Kollmorgen on 25.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "UGCCatalog.h"

typedef enum UGCBoxCaseId_ {
    UGC_BOX_CASE_NOT_ANSWERED_QUESTION,
    UGC_BOX_CASE1,
    UGC_BOX_CASE2,
    UGC_BOX_CASE3,
    UGC_BOX_CASE4,
    UGC_BOX_CASE5
} UGCBoxCaseId;

@class UGCExplanation;
@class Catalog;
@interface UGCCatalog (Utilities)

-(void)syncStateOfQuestions:(NSArray*)listOfChangedQuestions;

-(void)syncUserQuestionState:(NSArray*)listOfQuestions;

-(UGCBoxCaseId)boxCaseIdOfQuestionWithName:(NSString*)name;

-(NSSet*)questionSet;

-(NSArray*)alreadyAnsweredQuestions;

-(UGCQuestion*)questionByName:(NSString*)name;

-(UGCQuestion*)questionInstance;

-(NSUInteger)totalNumberCorrectAnsweredQuestions;

-(NSUInteger)totalNumberIncorrectAnsweredQuestions;

-(UGCExplanation*)explanationByName:(NSString*)name;

-(UGCExplanation*)explanationInstance;

-(Catalog*)sourceCatalog;

@end
