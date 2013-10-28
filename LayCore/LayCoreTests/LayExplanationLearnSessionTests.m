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
    STAssertEqualObjects(catalog, catalogFromDatasource, nil);
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
    STAssertEqualObjects(nameOfExplanation, infoReferenceCatalog.nameOfFirstExplanation, nil);
    Explanation *secondExplanation = session.nextExplanation;
    nameOfExplanation = secondExplanation.name;
    STAssertEqualObjects(nameOfExplanation, infoReferenceCatalog.nameOfSecondExplanation, nil);
    Explanation *thirdExplanation = session.nextExplanation;
    nameOfExplanation = thirdExplanation.name;
    STAssertEqualObjects(nameOfExplanation, infoReferenceCatalog.nameOfThirdExplanation, nil);
    //
    NSString *titleOfExplanation = firstExplanation.title;
    STAssertEqualObjects(titleOfExplanation, infoReferenceCatalog.titleOfFirstExplanation, nil);
    titleOfExplanation = secondExplanation.title;
    STAssertEqualObjects(titleOfExplanation, infoReferenceCatalog.titleOfSecondExplanation, nil);
    titleOfExplanation = thirdExplanation.title;
    STAssertEqualObjects(titleOfExplanation, infoReferenceCatalog.titleOfThirdExplanation, nil);
    
    for (NSUInteger e=0; e < [datasource numberOfExplanations]; ++e) {
        Explanation *explanation = session.nextExplanation;
        STAssertNotNil(explanation, nil);
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
    STAssertEqualObjects(nameOfExplanation, infoReferenceCatalog.nameOfSecondExplanation, nil);
    Explanation *firstExplanation = session.previousExplanation;
    nameOfExplanation = firstExplanation.name;
    STAssertEqualObjects(nameOfExplanation, infoReferenceCatalog.nameOfFirstExplanation, nil);
    explanation = session.previousExplanation;
    STAssertEqualObjects(firstExplanation, explanation, nil);
}

-(void)testNumberOfExplanations{
    MWLogNameOfTest(_classObj);
    LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    LayCoreTestCatalogInfo* infoReferenceCatalog = [testCatalogInfoManager infoForCatalog:INFO_TEST_CATALOG_CITIZENSHIPTEST1];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayOrderedExplanationDatasource *datasource = [[LayOrderedExplanationDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
     LayExplanationLearnSession *session = [[LayExplanationLearnSession alloc]initWithDatasource:datasource];
    STAssertEquals(infoReferenceCatalog.expectedNumberOfExplanations, [session numberOfExplanations], nil);
}

@end
