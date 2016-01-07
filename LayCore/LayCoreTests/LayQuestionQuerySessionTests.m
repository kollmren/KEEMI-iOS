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
    XCTAssertNotNil(questionOne);
    XCTAssertTrue([questionOne isChecked]==YES);
    XCTAssertTrue([questionOne isFavourite]==YES);
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
    XCTAssertEqualObjects(question.question, expectedQuestionText);
    NSString *expectedQuestionName = @"wappenBundeslandBerlin";
    XCTAssertEqualObjects(question.name, expectedQuestionName);
    Answer *answer = question.answerRef;
    NSArray *answerItemSet = [answer answerItemListSessionOrderPreserved];
    const NSUInteger expectedNumberOfAnswerItems = 4;
    XCTAssertTrue([answerItemSet count]==expectedNumberOfAnswerItems);
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
    XCTAssertNotNil(uCatalog);
    UGCBoxCaseId boxCaseId = [uCatalog boxCaseIdOfQuestionWithName:question.name];
    XCTAssertTrue(boxCaseId!=UGC_BOX_CASE_NOT_ANSWERED_QUESTION);
    XCTAssertEqual(UGC_BOX_CASE2, boxCaseId);
    
    //
    // a new session
    //
    datasource = [[LayOrderedQuestionDatasource alloc]initWithCatalog:catalog];
    querySession = [[LayQuestionQuerySession alloc]initWithDatasource:datasource];
    question = [querySession nextQuestion];
    XCTAssertEqualObjects(question.name, expectedQuestionName);
    answer = question.answerRef;
    answerItemSet = [answer answerItemListSessionOrderPreserved];
    XCTAssertTrue([answerItemSet count]==expectedNumberOfAnswerItems);
    for (AnswerItem* item in [answer answerItemListSessionOrderPreserved]) { // answer correctly
        if([item.correct boolValue]) {
            item.setByUser = [NSNumber numberWithBool:YES];
        }
    }
    answer.correctAnsweredByUser = [NSNumber numberWithBool:YES];
    answer.sessionGivenByUser = [NSNumber numberWithBool:YES];
    
    [querySession finish];
    uCatalog = [uStore findCatalogByTitle:catalog.title andPublisher:[catalog publisher]];
    XCTAssertNotNil(uCatalog);
    boxCaseId = [uCatalog boxCaseIdOfQuestionWithName:question.name];
    XCTAssertTrue(boxCaseId!=UGC_BOX_CASE_NOT_ANSWERED_QUESTION);
    XCTAssertEqual(UGC_BOX_CASE3, boxCaseId);
}

-(void)testWithRandomLeitnerDatasource {
    MWLogNameOfTest(_classObj);
    Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    LayRandomLeitnerDatasource *datasource = [[LayRandomLeitnerDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
    LayQuestionQuerySession *querySession = [[LayQuestionQuerySession alloc]initWithDatasource:datasource];
    
    XCTAssertNotNil(querySession);
    
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


