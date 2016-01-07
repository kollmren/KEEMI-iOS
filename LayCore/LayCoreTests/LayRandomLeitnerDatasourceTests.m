//
//  LayRandomLeitnerDatasourceTests.m
//  LayCore
//
//  Created by Rene Kollmorgen on 25.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayRandomLeitnerDatasourceTests.h"
#import "LayRandomLeitnerDatasource.h"
#import "LayXmlCatalogFileReader.h"
#import "LayMainDataStore.h"
#import "LayCatalogImport.h"
#import "LayCatalogImportReport.h"
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
    XCTAssertEqualObjects(catalog, catalogFromDatasource);
}

-(void)testNextQuestion{
    MWLogNameOfTest(_classObj);
    //LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    //LayCoreTestCatalogInfo* infoReferenceCatalog = [testCatalogInfoManager infoForCatalog:INFO_TEST_CATALOG_REFERENCE];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayRandomLeitnerDatasource *datasource = [[LayRandomLeitnerDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
    Question *question = datasource.nextQuestion;
    XCTAssertNotNil(question);
    NSString *questionText = question.question;
    XCTAssertNotNil(questionText);
    question = datasource.nextQuestion;
    XCTAssertNotNil(question);
    questionText = question.question;
    XCTAssertNotNil(questionText);
}

-(void)testPreviousQuestion {
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
    XCTAssertNotNil(question);
    NSString *questionText = question.question;
    XCTAssertNotNil(questionText);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    questionText = question.question;
    XCTAssertNotNil(questionText);
}

-(void)testQuestionGroup {
    MWLogNameOfTest(_classObj);
    NSURL* catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathCatalogGallery];
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    XCTAssertNotNil(xmlDataFileReader);
    LayCatalogImport *catalogImport = [[LayCatalogImport alloc]initWithDataFileReader:xmlDataFileReader];
    LayCatalogImportReport *importReport = [catalogImport import];
    XCTAssertTrue(importReport.imported);
    //
    LayRandomLeitnerDatasource *datasource = [[LayRandomLeitnerDatasource alloc]initWithCatalog:importReport.importedCatalog considerTopicSelection:NO];
    const NSString *nameOfExpectedGroup = @"borderCanada";
    Question *currenQuestion = nil;
    Question *nextQuestion = datasource.nextQuestion;
    BOOL foundGroup = NO;
    do {
        currenQuestion = nextQuestion;
        if(currenQuestion.groupName && [currenQuestion.groupName isEqualToString:(NSString*)nameOfExpectedGroup] ) {
            foundGroup = YES;
            break;
        }
        nextQuestion = datasource.nextQuestion;
    } while (nextQuestion != currenQuestion );
    
    XCTAssertTrue(foundGroup);
    BOOL groupIsAsExpected = YES;
    const NSInteger numberOfExpectedQuestionsInGroup = 4;
    for (NSInteger questionInGroupIdx = 0; questionInGroupIdx < numberOfExpectedQuestionsInGroup; ++questionInGroupIdx) {
        if( ![currenQuestion.groupName isEqualToString:(NSString*)nameOfExpectedGroup] ) {
            groupIsAsExpected = NO;
            MWLogError(_classObj, @"Expected name of group is:%@ not:%@!", nameOfExpectedGroup, currenQuestion.groupName );
        }
        currenQuestion = datasource.nextQuestion;
        
        if(questionInGroupIdx==2) {
            if( [currenQuestion.name isEqualToString:@"borderCanada4"] ) {
                Question *q = datasource.previousQuestion;
                if( [q.name isEqualToString:@"borderCanada3"] ) {
                    Question *q = datasource.previousQuestion;
                    if( [q.name isEqualToString:@"borderCanada2"] ) {
                        Question *q = datasource.previousQuestion;
                        if( ![q.name isEqualToString:@"borderCanada"] ) {
                            groupIsAsExpected = NO;
                             MWLogError(_classObj, @"Question with name:borderCanada expected!");
                        }
                    } else {
                        groupIsAsExpected = NO;
                        MWLogError(_classObj, @"Question with name:borderCanada2 expected!");
                    }
                } else {
                    groupIsAsExpected = NO;
                    MWLogError(_classObj, @"Question with name:borderCanada3 expected!");
                }
            } else {
                groupIsAsExpected = NO;
                MWLogError(_classObj, @"Question with name:borderCanada4 expected!");
            }
        }
    }
    XCTAssertTrue(groupIsAsExpected);
    
    currenQuestion = datasource.nextQuestion;
    XCTAssertNotNil(currenQuestion);
}

-(void)testNumberOfQuestions{
    MWLogNameOfTest(_classObj);
    //LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayRandomLeitnerDatasource *datasource = [[LayRandomLeitnerDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
    const NSUInteger expectedNumberOfQuestions = 13;
    XCTAssertEqual(expectedNumberOfQuestions, [datasource numberOfQuestions]);
}

-(void)testNextQuestionRepeated{
    MWLogNameOfTest(_classObj);
    //LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    //LayCoreTestCatalogInfo* infoReferenceCatalog = [testCatalogInfoManager infoForCatalog:INFO_TEST_CATALOG_REFERENCE];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayRandomLeitnerDatasource *datasource = [[LayRandomLeitnerDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
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
    LayRandomLeitnerDatasource *datasource = [[LayRandomLeitnerDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
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


-(void)testWithOneQuestionCatalog {
    LayMainDataStore *mainStore = [LayMainDataStore store];
    NSString *titleOfCatalog = @"One question catalog";
    Catalog *oneQuestionCatalog = [mainStore findCatalogByTitle:titleOfCatalog];
    XCTAssertNotNil(oneQuestionCatalog);
    LayRandomLeitnerDatasource *datasource = [[LayRandomLeitnerDatasource alloc]initWithCatalog:oneQuestionCatalog considerTopicSelection:NO];
    Question *question = datasource.nextQuestion;
    XCTAssertNotNil(question);
    question = datasource.nextQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
    question = datasource.previousQuestion;
    XCTAssertNotNil(question);
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
    XCTAssertNil(question);
    question = datasource.previousQuestion;
    XCTAssertNil(question);
    question = datasource.previousQuestion;
    XCTAssertNil(question);
    question = datasource.previousQuestion;
    XCTAssertNil(question);
    question = datasource.previousQuestion;
    XCTAssertNil(question);
    question = datasource.previousQuestion;
    XCTAssertNil(question);
    question = datasource.previousQuestion;
    XCTAssertNil(question);
    question = datasource.previousQuestion;
    XCTAssertNil(question);
    question = datasource.previousQuestion;
    XCTAssertNil(question);
    question = datasource.previousQuestion;
    XCTAssertNil(question);
}

@end
