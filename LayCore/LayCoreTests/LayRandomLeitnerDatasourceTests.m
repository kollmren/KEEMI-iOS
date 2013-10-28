//
//  LayRandomLeitnerDatasourceTests.m
//  LayCore
//
//  Created by Rene Kollmorgen on 25.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayRandomLeitnerDatasourceTests.h"
#import "LayRandomLeitnerDatasource.h"
#import "LayMainDataStore.h"
#import "LayError.h"
#import "LayCatalogManager.h"

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"
#import "Media+Utilities.h"
#import "Topic+Utilities.h"

#import "MWLogging.h"

#import "LayCoreTestConfig.h"
#import "LayCoreTestCatalogInfoManager.h"

@implementation LayRandomLeitnerDatasourceTests

static Class _classObj = nil;

+(void)setUp {
    _classObj = [LayRandomLeitnerDatasourceTests class];
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
    LayRandomLeitnerDatasource *datasource = [[LayRandomLeitnerDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
    Catalog* catalogFromDatasource = datasource.catalog;
    STAssertEqualObjects(catalog, catalogFromDatasource, nil);
}

-(void)testNextQuestion{
    MWLogNameOfTest(_classObj);
    //LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    //LayCoreTestCatalogInfo* infoReferenceCatalog = [testCatalogInfoManager infoForCatalog:INFO_TEST_CATALOG_REFERENCE];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayRandomLeitnerDatasource *datasource = [[LayRandomLeitnerDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
    Question *question = datasource.nextQuestion;
    STAssertNotNil(question, nil);
    NSString *questionText = question.question;
    STAssertNotNil(questionText, nil);
    question = datasource.nextQuestion;
    STAssertNotNil(question, nil);
    questionText = question.question;
    STAssertNotNil(questionText, nil);
}

-(void)testPreviousQuestion{
    MWLogNameOfTest(_classObj);
    //LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    //LayCoreTestCatalogInfo* infoReferenceCatalog = [testCatalogInfoManager infoForCatalog:INFO_TEST_CATALOG_REFERENCE];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayRandomLeitnerDatasource *datasource = [[LayRandomLeitnerDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
    Question *question = datasource.nextQuestion;
    question = datasource.nextQuestion;
    question = datasource.nextQuestion;
    question = datasource.previousQuestion;
    STAssertNotNil(question, nil);
    NSString *questionText = question.question;
    STAssertNotNil(questionText, nil);
    question = datasource.previousQuestion;
    STAssertNotNil(question, nil);
    questionText = question.question;
    STAssertNotNil(questionText, nil);
}

-(void)testNumberOfQuestions{
    MWLogNameOfTest(_classObj);
    //LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayRandomLeitnerDatasource *datasource = [[LayRandomLeitnerDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
    const NSUInteger expectedNumberOfQuestions = 13;
    STAssertEquals(expectedNumberOfQuestions, [datasource numberOfQuestions], nil);
}

-(void)testNextQuestionRepeated{
    MWLogNameOfTest(_classObj);
    //LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    //LayCoreTestCatalogInfo* infoReferenceCatalog = [testCatalogInfoManager infoForCatalog:INFO_TEST_CATALOG_REFERENCE];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayRandomLeitnerDatasource *datasource = [[LayRandomLeitnerDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
    Question *question = datasource.nextQuestion;
    STAssertNotNil(question, nil);
    question = datasource.nextQuestion;
    STAssertNotNil(question, nil);
    question = datasource.nextQuestion;
    STAssertNotNil(question, nil);
    question = datasource.nextQuestion;
    STAssertNotNil(question, nil);
    question = datasource.nextQuestion;
    STAssertNotNil(question, nil);
    question = datasource.nextQuestion;
    STAssertNotNil(question, nil);
    question = datasource.nextQuestion;
    STAssertNotNil(question, nil);
    question = datasource.nextQuestion;
    STAssertNotNil(question, nil);
    question = datasource.nextQuestion;
    STAssertNotNil(question, nil);
    question = datasource.nextQuestion;
    STAssertNotNil(question, nil);
}

-(void)testPreviousQuestionRepeated{
    MWLogNameOfTest(_classObj);
    //LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    //LayCoreTestCatalogInfo* infoReferenceCatalog = [testCatalogInfoManager infoForCatalog:INFO_TEST_CATALOG_REFERENCE];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayRandomLeitnerDatasource *datasource = [[LayRandomLeitnerDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
    Question *question = datasource.nextQuestion;
    STAssertNotNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNotNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNotNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNotNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNotNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNotNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNotNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNotNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNotNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNotNil(question, nil);
}


-(void)testWithOneQuestionCatalog {
    LayMainDataStore *mainStore = [LayMainDataStore store];
    NSString *titleOfCatalog = @"One question catalog";
    Catalog *oneQuestionCatalog = [mainStore findCatalogByTitle:titleOfCatalog];
    STAssertNotNil(oneQuestionCatalog, nil);
    LayRandomLeitnerDatasource *datasource = [[LayRandomLeitnerDatasource alloc]initWithCatalog:oneQuestionCatalog considerTopicSelection:NO];
    Question *question = datasource.nextQuestion;
    STAssertNotNil(question, nil);
    question = datasource.nextQuestion;
    STAssertNotNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNotNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNotNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNotNil(question, nil);
}

-(void)testWithNoSelectedTopics{
    MWLogNameOfTest(_classObj);
    //LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    //LayCoreTestCatalogInfo* infoReferenceCatalog = [testCatalogInfoManager infoForCatalog:INFO_TEST_CATALOG_REFERENCE];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    for (Topic *topic in [catalog topicList]) {
        [topic setTopicAsNotSelected];
    }
    LayRandomLeitnerDatasource *datasource = [[LayRandomLeitnerDatasource alloc]initWithCatalog:catalog considerTopicSelection:YES];
    Question *question = datasource.nextQuestion;
    STAssertNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNil(question, nil);
    question = datasource.previousQuestion;
    STAssertNil(question, nil);
}

@end
