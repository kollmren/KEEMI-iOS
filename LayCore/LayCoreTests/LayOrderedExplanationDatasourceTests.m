//
//  LayOrderedExplanationDatasourceTests.m
//  LayCore
//
//  Created by Rene Kollmorgen on 13.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayOrderedExplanationDatasourceTests.h"
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


@implementation LayOrderedExplanationDatasourceTests

static Class _classObj = nil;

+(void)setUp {
    _classObj = [LayOrderedExplanationDatasourceTests class];
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
    Catalog* catalogFromDatasource = datasource.catalog;
    STAssertEqualObjects(catalog, catalogFromDatasource, nil);
}

-(void)testNextExplanation{
    MWLogNameOfTest(_classObj);
    LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    LayCoreTestCatalogInfo* infoReferenceCatalog = [testCatalogInfoManager infoForCatalog:INFO_TEST_CATALOG_CITIZENSHIPTEST1];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayOrderedExplanationDatasource *datasource = [[LayOrderedExplanationDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
    Explanation *firstExplanation = datasource.nextExplanation;
    NSString *nameOfExplanation = firstExplanation.name;
    STAssertEqualObjects(nameOfExplanation, infoReferenceCatalog.nameOfFirstExplanation, nil);
    Explanation *secondExplanation = datasource.nextExplanation;
    nameOfExplanation = secondExplanation.name;
    STAssertEqualObjects(nameOfExplanation, infoReferenceCatalog.nameOfSecondExplanation, nil);
    Explanation *thirdExplanation = datasource.nextExplanation;
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
        Explanation *explanation = datasource.nextExplanation;
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
    Explanation *explanation = datasource.nextExplanation;
    explanation = datasource.nextExplanation;
    explanation = datasource.nextExplanation;
    
    explanation = datasource.previousExplanation;
    NSString *nameOfExplanation = explanation.name;
    STAssertEqualObjects(nameOfExplanation, infoReferenceCatalog.nameOfSecondExplanation, nil);
    Explanation *firstExplanation = datasource.previousExplanation;
    nameOfExplanation = firstExplanation.name;
    STAssertEqualObjects(nameOfExplanation, infoReferenceCatalog.nameOfFirstExplanation, nil);
    explanation = datasource.previousExplanation;
    STAssertEqualObjects(firstExplanation, explanation, nil);
}

-(void)testNumberOfExplanations{
    MWLogNameOfTest(_classObj);
    LayCoreTestCatalogInfoManager *testCatalogInfoManager = [LayCoreTestCatalogInfoManager instance];
    LayCoreTestCatalogInfo* infoReferenceCatalog = [testCatalogInfoManager infoForCatalog:INFO_TEST_CATALOG_CITIZENSHIPTEST1];
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    Catalog *catalog = catalogManager.currentSelectedCatalog;
    LayOrderedExplanationDatasource *datasource = [[LayOrderedExplanationDatasource alloc]initWithCatalog:catalog considerTopicSelection:NO];
    STAssertEquals(infoReferenceCatalog.expectedNumberOfExplanations, [datasource numberOfExplanations], nil);
}


@end
