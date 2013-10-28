//
//  LayCatalogImport.m
//  LayCore
//
//  Created by Rene Kollmorgen on 19.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayCatalog+UtilitiesTests.h"

#import "LayCatalogImportReport.h"
#import "LayCatalogImport.h"
#import "LayMainDataStore.h"

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"

#import "MWLogging.h"
#import "LayCoreTestConfig.h"

#import <objc/runtime.h> //class_getName

// Testdata
#import "LayCatalogDataFileReaderDummy.h"
#import "LayCatalogDataFile_HeadFirstDesignPattern.h"

@implementation LayCatalogUtilitiesTests

static Class _classObj = nil;


+(void)setUp {
    _classObj = [LayCatalogUtilitiesTests class];
    [LayCoreTestConfig createDocumentDirectory];
    [LayCoreTestConfig configureTestDataStore];
}

-(void)tearDown {
    LayMainDataStore *mainStore = [LayMainDataStore store];
    STAssertTrue([mainStore deleteAllCatalogsFromStore], nil);
}


-(void)testQuestionListSortedByNumber_ {
    MWLogNameOfTest(_classObj);
    // Setup testdata
    const NSInteger GENERATE_NUMBER_OF_QUESTIONS = 100;
    LayCatalogDataFile_HeadFirstDesignPattern *catalogFileHeadFirstDesign = [LayCatalogDataFile_HeadFirstDesignPattern new];
    [catalogFileHeadFirstDesign setNumberOfQuestions:GENERATE_NUMBER_OF_QUESTIONS];
    LayCatalogDataFileReaderDummy *dataFileReader = [[LayCatalogDataFileReaderDummy alloc]initWithDataFileDummy:catalogFileHeadFirstDesign];
    LayCatalogImport *catalogImport = [[LayCatalogImport alloc]initWithDataFileReader:dataFileReader];
    LayCatalogImportReport* importReport = [catalogImport import];
    STAssertNotNil(importReport, nil);
    STAssertTrue(importReport.imported, nil);
    // Check if catalog was imported / catalog is stored in the datastore
    LayMainDataStore *mainStore = [LayMainDataStore store];
    NSString *titleCatalog = [dataFileReader metaInfo].catalogTitle;
    Catalog* catalog = [mainStore findCatalogByTitle:titleCatalog];
    STAssertNotNil(catalog, nil);
    NSArray *questionList = [catalog questionListSortedByNumber];
    STAssertTrue(questionList.count==GENERATE_NUMBER_OF_QUESTIONS, @"Actually value is:%u", questionList.count);
    STAssertTrue([[questionList objectAtIndex:0] isKindOfClass:[Question class]], nil);
    Question *firstQuestion = (Question*)[questionList objectAtIndex:0];
    STAssertTrue([firstQuestion numberAsPrimitive] == 1, nil);
    Question *lastQuestion = (Question*)[questionList lastObject];
    NSNumber *lastQuestionNumber = [lastQuestion questionNumber];
    NSNumber *expectedLastNumber = [NSNumber numberWithInt:GENERATE_NUMBER_OF_QUESTIONS];
    STAssertTrue([lastQuestionNumber isEqualToNumber:expectedLastNumber], @"Actually value is:%u", [lastQuestionNumber unsignedIntegerValue]);
}

@end

