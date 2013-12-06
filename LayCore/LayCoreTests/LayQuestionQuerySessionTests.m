//
//  LayQuestionQuerySessionTests.m
//  LayCore
//
//  Created by Rene Kollmorgen on 06.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayQuestionQuerySessionTests.h"
#import "LayQuestionQuerySession.h"

#import "LayCatalogManager.h"
#import "LayCatalogImportReport.h"
#import "LayCatalogImport.h"
#import "LayMainDataStore.h"
#import "LayQuestionDatasource.h"

#import "Question+Utilities.h"
#import "Answer+Utilities.h"
#import "AnswerItem+Utilities.h"

#import "UGCQuestion+Utilities.h"

#import "LayUserDataStore.h"
#import "UGCCatalog+Utilities.h"

#import "LayOrderedQuestionDatasource.h"
#import "LayRandomLeitnerDatasource.h"

#import "MWLogging.h"
#import "LayCoreTestConfig.h"

@interface DummyUser : NSObject{
    @private
    LayQuestionQuerySession* session;
}
-(id)initWith:(LayQuestionQuerySession*)session;
-(void) actionsQuestionOne;
-(void) actionsQuestionTwo;
-(void) actionsQuestionThree;
-(void) actionsQuestionFour;
-(void)actionsQuestionCurrent;
@end

//
//
//
@implementation LayQuestionQuerySessionTests

static Class _classObj = nil;

+(void)setUp {
    _classObj = [LayQuestionQuerySessionTests class];
    [LayCoreTestConfig configureTestDataStore];
    [LayCoreTestConfig populateTestDatabase];
}

+(void)tearDown {
    LayMainDataStore *mainStore = [LayMainDataStore store];
    [mainStore deleteAllCatalogsFromStore];
     LayUserDataStore *uStore = [LayUserDataStore store];
    [uStore deleteAllCatalogsFromStore];
}

-(void)tearDown {
    LayUserDataStore *uStore = [LayUserDataStore store];
    [uStore deleteAllCatalogsFromStore];
}


-(void)testAddUserAnswer {
    MWLogNameOfTest(_classObj);
    Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    LayOrderedQuestionDatasource *datasource = [[LayOrderedQuestionDatasource alloc]initWithCatalog:catalog];
    LayQuestionQuerySession *querySession = [[LayQuestionQuerySession alloc]initWithDatasource:datasource];
    DummyUser *user = [[DummyUser alloc]initWith:querySession];
    [user actionsQuestionOne];
    [user actionsQuestionTwo];
    [user actionsQuestionThree];
    [user actionsQuestionFour];
    [user actionsQuestionCurrent];
    
    Question* questionOne = [querySession answeredQuestionByNumber:1];
    STAssertNotNil(questionOne, nil);
    STAssertTrue([questionOne isChecked]==YES, nil);
    STAssertTrue([questionOne isFavourite]==YES, nil);
    // TODO
}


// One question is correct answered by a user over a number of sessions.
// The correct answered questions walks to the last case in the question-box.
-(void)testFinishCorrectAnswerdQuestionBoxWalk {
    MWLogNameOfTest(_classObj);
    Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    LayOrderedQuestionDatasource *datasource = [[LayOrderedQuestionDatasource alloc]initWithCatalog:catalog];
    LayQuestionQuerySession *querySession = [[LayQuestionQuerySession alloc]initWithDatasource:datasource];
    Question *question = [querySession nextQuestion];
    NSString *expectedQuestionText = @"Welches Wappen gehört zum Bundesland Berlin?";
    STAssertEqualObjects(question.question, expectedQuestionText, nil);
    NSString *expectedQuestionName = @"wappenBundeslandBerlin";
    STAssertEqualObjects(question.name, expectedQuestionName, nil);
    Answer *answer = question.answerRef;
    NSArray *answerItemSet = [answer answerItemListSessionOrderPreserved];
    const NSUInteger expectedNumberOfAnswerItems = 4;
    STAssertTrue([answerItemSet count]==expectedNumberOfAnswerItems, nil);
    for (AnswerItem* item in [answer answerItemListSessionOrderPreserved]) { // answer correctly
        if([item.correct boolValue]) {
            item.setByUser = [NSNumber numberWithBool:YES];
        }
    }
    answer.correctAnsweredByUser = [NSNumber numberWithBool:YES];
    answer.sessionGivenByUser = [NSNumber numberWithBool:YES];
    
    [querySession finish];
    
    LayUserDataStore *uStore = [LayUserDataStore store];
    UGCCatalog *uCatalog = [uStore findCatalogByTitle:catalog.title andPublisher:[catalog publisher]];
    STAssertNotNil(uCatalog, nil);
    UGCBoxCaseId boxCaseId = [uCatalog boxCaseIdOfQuestionWithName:question.name];
    STAssertTrue(boxCaseId!=UGC_BOX_CASE_NOT_ANSWERED_QUESTION, nil);
    STAssertEquals(UGC_BOX_CASE2, boxCaseId, nil);
    
    //
    // a new session
    //
    datasource = [[LayOrderedQuestionDatasource alloc]initWithCatalog:catalog];
    querySession = [[LayQuestionQuerySession alloc]initWithDatasource:datasource];
    question = [querySession nextQuestion];
    STAssertEqualObjects(question.name, expectedQuestionName, nil);
    answer = question.answerRef;
    answerItemSet = [answer answerItemListSessionOrderPreserved];
    STAssertTrue([answerItemSet count]==expectedNumberOfAnswerItems, nil);
    for (AnswerItem* item in [answer answerItemListSessionOrderPreserved]) { // answer correctly
        if([item.correct boolValue]) {
            item.setByUser = [NSNumber numberWithBool:YES];
        }
    }
    answer.correctAnsweredByUser = [NSNumber numberWithBool:YES];
    answer.sessionGivenByUser = [NSNumber numberWithBool:YES];
    
    [querySession finish];
    uCatalog = [uStore findCatalogByTitle:catalog.title andPublisher:[catalog publisher]];
    STAssertNotNil(uCatalog, nil);
    boxCaseId = [uCatalog boxCaseIdOfQuestionWithName:question.name];
    STAssertTrue(boxCaseId!=UGC_BOX_CASE_NOT_ANSWERED_QUESTION, nil);
    STAssertEquals(UGC_BOX_CASE3, boxCaseId, nil);
}

-(void)testWithRandomLeitnerDatasource {
    MWLogNameOfTest(_classObj);
    Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    LayRandomLeitnerDatasource *datasource = [[LayRandomLeitnerDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
    LayQuestionQuerySession *querySession = [[LayQuestionQuerySession alloc]initWithDatasource:datasource];
    
    STAssertNotNil(querySession, nil);
    
    [querySession finish];

}

@end

//
// DummyUser
//

@implementation DummyUser

-(id)initWith:(LayQuestionQuerySession*)session_ {
    self = [super init];
    if(self) {
        self->session = session_;
    }
    return self;
}
-(void) actionsQuestionOne {
    id<LayQuestionDatasource> questionDatasource = self->session;
    Question* question = [questionDatasource nextQuestion];
    [question markQuestionAsFavourite];
    [question setIsChecked:YES];
    Answer* answer = question.answerRef;
    NSArray* possibleAnswers = [answer answerItemListSessionOrderPreserved];
    NSUInteger itemCounter = 0;
    for (AnswerItem *item in possibleAnswers) {
        if(itemCounter==1) {
            item.setByUser = [NSNumber numberWithBool:YES];
        } else if(itemCounter==2) {
            item.setByUser = [NSNumber numberWithBool:YES];
        }
        ++itemCounter;
    }
}

-(void) actionsQuestionTwo {
    //SKIP
    id<LayQuestionDatasource> questionDatasource = self->session;
    [questionDatasource nextQuestion];
}

-(void) actionsQuestionThree {
    id<LayQuestionDatasource> questionDatasource = self->session;
    Question* question = [questionDatasource nextQuestion];
    Answer* answer = question.answerRef;
    NSArray* possibleAnswers = [answer answerItemListSessionOrderPreserved];
    NSUInteger itemCounter = 0;
    for (AnswerItem *item in possibleAnswers) {
        if(itemCounter==0) {
            item.setByUser = [NSNumber numberWithBool:YES];
        }
        ++itemCounter;
    }
}

-(void) actionsQuestionFour {
    id<LayQuestionDatasource> questionDatasource = self->session;
    Question* question = [questionDatasource nextQuestion];
    question = nil;
}

-(void) actionsQuestionCurrent {
    id<LayQuestionDatasource> questionDatasource = self->session;
    [questionDatasource nextQuestion];
}

@end


