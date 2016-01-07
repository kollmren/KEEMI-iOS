//
//  LayOrderedQuestionDatasourceTests.m
//  LayCore
//
//  Created by Rene Kollmorgen on 20.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayOrderedQuestionDatasourceTests.h"
#import "LayOrderedQuestionDatasource.h"
#import "LayCoreTestConfig.h"
#import "LayMainDataStore.h"
#import "LayError.h"
#import "LayCatalogManager.h"

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"
#import "Media+Utilities.h"
#import "Topic+Utilities.h"

#import "LayCoreTestCatalogInfoManager.h"
#import "MWLogging.h"

@implementation LayOrderedQuestionDatasourceTests

static Class _classObj = nil;

+(void)setUp {
    _classObj = [LayOrderedQuestionDatasourceTests class];
    [LayCoreTestConfig configureTestDataStore];
    [LayCoreTestConfig populateTestDatabase];
}

+(void)tearDown {
    LayMainDataStore *mainStore = [LayMainDataStore store];
    BOOL deletedAll = [mainStore deleteAllCatalogsFromStore];
    if(!deletedAll) {
        MWLogError(_classObj, @"Could not delete all data from store!");
    }
}

-(void)testCatalog{
    MWLogNameOfTest(_classObj);
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayOrderedQuestionDatasource *datasource = [[LayOrderedQuestionDatasource alloc]initWithCatalog:catalog];
    Catalog* catalogFromDatasource = datasource.catalog;
    XCTAssertEqualObjects(catalog, catalogFromDatasource);
}

-(void)testNextQuestion{
    MWLogNameOfTest(_classObj);
    //LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    //LayCoreTestCatalogInfo* infoReferenceCatalog = [testCatalogInfoManager infoForCatalog:INFO_TEST_CATALOG_REFERENCE];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayOrderedQuestionDatasource *datasource = [[LayOrderedQuestionDatasource alloc]initWithCatalog:catalog];
    Question *question = datasource.nextQuestion;
    XCTAssertNotNil(question);
    NSString *questionText = question.question;
    XCTAssertNotNil(questionText);
    question = datasource.nextQuestion;
    XCTAssertNotNil(question);
    questionText = question.question;
    XCTAssertNotNil(questionText);
}

-(void)testPreviousQuestion{
    MWLogNameOfTest(_classObj);
    //LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    //LayCoreTestCatalogInfo* infoReferenceCatalog = [testCatalogInfoManager infoForCatalog:INFO_TEST_CATALOG_REFERENCE];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayOrderedQuestionDatasource *datasource = [[LayOrderedQuestionDatasource alloc]initWithCatalog:catalog];
    Question *question = datasource.nextQuestion;
    question = datasource.nextQuestion;
    question = datasource.nextQuestion;
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    NSString *questionText = question.question;
    XCTAssertNotNil(questionText);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    questionText = question.question;
    XCTAssertNotNil(questionText);
}

-(void)testNumberOfQuestions{
    MWLogNameOfTest(_classObj);
    //LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayOrderedQuestionDatasource *datasource = [[LayOrderedQuestionDatasource alloc]initWithCatalog:catalog];
    const NSUInteger expectedNumberOfQuestions = 13;
    XCTAssertEqual(expectedNumberOfQuestions, [datasource numberOfQuestions]);
}

-(void)testNextQuestionRepeated{
    MWLogNameOfTest(_classObj);
    //LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    //LayCoreTestCatalogInfo* infoReferenceCatalog = [testCatalogInfoManager infoForCatalog:INFO_TEST_CATALOG_REFERENCE];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayOrderedQuestionDatasource *datasource = [[LayOrderedQuestionDatasource alloc]initWithCatalog:catalog];
    Question *question = datasource.nextQuestion;
    XCTAssertNotNil(question);
    question = datasource.nextQuestion;
    XCTAssertNotNil(question);
    question = datasource.nextQuestion;
    XCTAssertNotNil(question);
    question = datasource.nextQuestion;
    XCTAssertNotNil(question);
    question = datasource.nextQuestion;
    XCTAssertNotNil(question);
    question = datasource.nextQuestion;
    XCTAssertNotNil(question);
    question = datasource.nextQuestion;
    XCTAssertNotNil(question);
    question = datasource.nextQuestion;
    XCTAssertNotNil(question);
    question = datasource.nextQuestion;
    XCTAssertNotNil(question);
    question = datasource.nextQuestion;
    XCTAssertNotNil(question);
}

-(void)testPreviousQuestionRepeated{
    MWLogNameOfTest(_classObj);
    //LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    //LayCoreTestCatalogInfo* infoReferenceCatalog = [testCatalogInfoManager infoForCatalog:INFO_TEST_CATALOG_REFERENCE];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayOrderedQuestionDatasource *datasource = [[LayOrderedQuestionDatasource alloc]initWithCatalog:catalog];
    Question *question = datasource.nextQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
}

-(void)testWithNoSelectedTopics {
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    for (Topic *topic in [catalog topicList]) {
        [topic setTopicAsNotSelected];
    }
    LayOrderedQuestionDatasource *datasource = [[LayOrderedQuestionDatasource alloc]initWithCatalog:catalog];
    // The orderded-datasource ignores topics, so the deselection has no effect!
    Question *question = datasource.nextQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
}

@end
