//
//  LayCatalogImport.m
//  LayCore
//
//  Created by Rene Kollmorgen on 19.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayCatalogImportTests.h"
#import "LayCatalogDataFileReaderDummy.h"
#import "LayCatalogImportReport.h"
#import "LayCatalogImport.h"
#import "LayMainDataStore.h"
#import "LayXmlCatalogFileReader.h" 

#import "Catalog+Utilities.h"
#import "Question.h"

#import "MWLogging.h"
#import <objc/runtime.h> //class_getName
#import "LayCoreTestConfig.h"
// Testdata
#import "LayCatalogDataFileReaderDummy.h"
#import "LayCatalogDataFile_HeadFirstDesignPattern.h"

@implementation LayCatalogImportTests

static Class _classObj = nil;


+(void)setUp {
    _classObj = [LayCatalogImportTests class];
    [LayCoreTestConfig createDocumentDirectory];
    [LayCoreTestConfig configureTestDataStore];
}

-(void)tearDown {
    LayMainDataStore *mainStore = [LayMainDataStore store];
    STAssertTrue([mainStore deleteAllCatalogsFromStore], nil);
}


-(void)testImport {
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
}

-(void)testImportOfMultipleCatalogs {
    MWLogNameOfTest(_classObj);
    const NSUInteger MAX_CATALOGS_TO_IMPORT = 10;
    for(int c=0; c < MAX_CATALOGS_TO_IMPORT; ++c) {
        LayCatalogDataFile_HeadFirstDesignPattern *catalogFileHeadFirstDesign = [LayCatalogDataFile_HeadFirstDesignPattern new];
        [catalogFileHeadFirstDesign setNumberOfCatalog:c];
        LayCatalogDataFileReaderDummy *dataFileReader = [[LayCatalogDataFileReaderDummy alloc]initWithDataFileDummy:catalogFileHeadFirstDesign];
        LayCatalogImport *catalogImport = [[LayCatalogImport alloc]initWithDataFileReader:dataFileReader];
        LayCatalogImportReport* importReport = [catalogImport import];
        STAssertNotNil(importReport, nil);
        STAssertTrue(importReport.imported, nil);

    }
    LayMainDataStore *mainStore = [LayMainDataStore store];
    NSArray* catalogList = [mainStore findAllCatalogs];
    STAssertEquals(MAX_CATALOGS_TO_IMPORT, [catalogList count], nil);
}

-(void)testImportOfTheSameCatalogTwice {
    MWLogNameOfTest(_classObj);
    NSURL* catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest];;
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    STAssertNotNil(xmlDataFileReader, nil);
    LayCatalogImport *catalogImport = [[LayCatalogImport alloc]initWithDataFileReader:xmlDataFileReader];
    LayCatalogImportReport* importReport = [catalogImport import];
    STAssertNotNil(importReport, nil);
    STAssertTrue(importReport.imported, nil);
    // twice
    importReport = [catalogImport import];
    STAssertNotNil(importReport, nil);
    STAssertFalse(importReport.imported, nil);
}

-(void)testImportOfCatalogsWithSameTitle {
    MWLogNameOfTest(_classObj);
    NSURL* catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptestOtherPublisher];;
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    STAssertNotNil(xmlDataFileReader, nil);
    LayCatalogImport *catalogImport = [[LayCatalogImport alloc]initWithDataFileReader:xmlDataFileReader];
    LayCatalogImportReport* importReport = [catalogImport import];
    STAssertNotNil(importReport, nil);
    STAssertTrue(importReport.imported, nil);
    // twice
    catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest];;
    xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    STAssertNotNil(xmlDataFileReader, nil);
    catalogImport = [[LayCatalogImport alloc]initWithDataFileReader:xmlDataFileReader];
    importReport = [catalogImport import];
    STAssertNotNil(importReport, nil);
    STAssertTrue(importReport.imported, nil);
}

@end

