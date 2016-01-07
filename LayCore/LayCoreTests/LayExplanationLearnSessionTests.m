//
//  LayExplanationLearnSessionTests.m
//  LayCore
//
//  Created by Rene Kollmorgen on 14.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayExplanationLearnSessionTests.h"
#import "LayExplanationLearnSession.h"

#import "LayOrderedExplanationDatasource.h"
#import "LayCoreTestConfig.h"
#import "LayMainDataStore.h"
#import "LayError.h"
#import "LayCatalogManager.h"

#import "Catalog+Utilities.h"
#import "Explanation+Utilities.h"
#import "Media+Utilities.h"

#import "LayCoreTestCatalogInfoManager.h"
#import "MWLogging.h"

@implementation LayExplanationLearnSessionTests

static Class _classObj = nil;

+(void)setUp {
    _classObj = [LayExplanationLearnSessionTests class];
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
    LayOrderedExplanationDatasource *datasource = [[LayOrderedExplanationDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
    LayExplanationLearnSession *session = [[LayExplanationLearnSession alloc]initWithDatasource:datasource];
    Catalog* catalogFromDatasource = session.catalog;
    XCTAssertEqualObjects(catalog, catalogFromDatasource);
}

-(void)testNextExplanation{
    MWLogNameOfTest(_classObj);
    LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    LayCoreTestCatalogInfo* infoReferenceCatalog = [testCatalogInfoManager infoForCatalog:INFO_TEST_CATALOG_CITIZENSHIPTEST1];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayOrderedExplanationDatasource *datasource = [[LayOrderedExplanationDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
    LayExplanationLearnSession *session = [[LayExplanationLearnSession alloc]initWithDatasource:datasource];
    Explanation *firstExplanation = session.nextExplanation;
    NSString *nameOfExplanation = firstExplanation.name;
    XCTAssertEqualObjects(nameOfExplanation, infoReferenceCatalog.nameOfFirstExplanation);
    Explanation *secondExplanation = session.nextExplanation;
    nameOfExplanation = secondExplanation.name;
    XCTAssertEqualObjects(nameOfExplanation, infoReferenceCatalog.nameOfSecondExplanation);
    Explanation *thirdExplanation = session.nextExplanation;
    nameOfExplanation = thirdExplanation.name;
    XCTAssertEqualObjects(nameOfExplanation, infoReferenceCatalog.nameOfThirdExplanation);
    //
    NSString *titleOfExplanation = firstExplanation.title;
    XCTAssertEqualObjects(titleOfExplanation, infoReferenceCatalog.titleOfFirstExplanation);
    titleOfExplanation = secondExplanation.title;
    XCTAssertEqualObjects(titleOfExplanation, infoReferenceCatalog.titleOfSecondExplanation);
    titleOfExplanation = thirdExplanation.title;
    XCTAssertEqualObjects(titleOfExplanation, infoReferenceCatalog.titleOfThirdExplanation);
    
    for (NSUInteger e=0; e < [datasource numberOfExplanations]; ++e) {
        Explanation *explanation = session.nextExplanation;
        XCTAssertNotNil(explanation);
    }
    
}

-(void)testPreviousExplanation{
    MWLogNameOfTest(_classObj);
    LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    LayCoreTestCatalogInfo* infoReferenceCatalog = [testCatalogInfoManager infoForCatalog:INFO_TEST_CATALOG_CITIZENSHIPTEST1];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayOrderedExplanationDatasource *datasource = [[LayOrderedExplanationDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
    LayExplanationLearnSession *session = [[LayExplanationLearnSession alloc]initWithDatasource:datasource];
    Explanation *explanation = session.nextExplanation;
    explanation = session.nextExplanation;
    explanation = session.nextExplanation;
    
    explanation = session.previousExplanation;
    NSString *nameOfExplanation = explanation.name;
    XCTAssertEqualObjects(nameOfExplanation, infoReferenceCatalog.nameOfSecondExplanation);
    Explanation *firstExplanation = session.previousExplanation;
    nameOfExplanation = firstExplanation.name;
    XCTAssertEqualObjects(nameOfExplanation, infoReferenceCatalog.nameOfFirstExplanation);
    explanation = session.previousExplanation;
    XCTAssertEqualObjects(firstExplanation, explanation);
}

-(void)testNumberOfExplanations{
    MWLogNameOfTest(_classObj);
    LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    LayCoreTestCatalogInfo* infoReferenceCatalog = [testCatalogInfoManager infoForCatalog:INFO_TEST_CATALOG_CITIZENSHIPTEST1];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayOrderedExplanationDatasource *datasource = [[LayOrderedExplanationDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
     LayExplanationLearnSession *session = [[LayExplanationLearnSession alloc]initWithDatasource:datasource];
    XCTAssertEqual(infoReferenceCatalog.expectedNumberOfExplanations, [session numberOfExplanations]);
}

@end
