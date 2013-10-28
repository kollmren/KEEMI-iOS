//
//  LayTestDataImport.m
//  Lay
//
//  Created by Rene Kollmorgen on 14.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayTestDataImport.h"
#import "LayCatalogDataFileReaderDummy.h"
#import "LayCatalogImport.h"
#import "LayCatalogImportReport.h"
#import "MWLogging.h"

#import "LayCatalogDataFile_HeadFirstDesignPattern.h"
#import "LayCatalogDataFile_CitizenTest.h"
#import "LayCatalogDataFile_Moma.h"
#import "LayCatalogDataFile_BayernFussball.h"
#import "LayCatalogDataFile_Spiegel.h"

@implementation LayTestDataImport

+(BOOL)importTestData {
    BOOL errorOccurred = YES;
    const NSUInteger GENERATE_NUMBER_OF_QUESTIONS = 30;
    const NSUInteger NUMBER_OF_CATALOGS_TO_IMPORT = 5;
    //const NSInteger NUMBER_OF_AVAILABLE_CATALOGS = 2;
    for (int c=0; c<NUMBER_OF_CATALOGS_TO_IMPORT; ++c) {
        NSObject<LayDataFileDummy> *dataFileDummy = nil;
        //int choose = (rand()+1) % NUMBER_OF_AVAILABLE_CATALOGS;
        switch (c) {
            case 0:
                dataFileDummy = [LayCatalogDataFile_HeadFirstDesignPattern new];
                break;
            case 1:
                dataFileDummy = [LayCatalogDataFile_CitizenTest new];
                break;
            case 2:
                dataFileDummy = [LayCatalogDataFile_Moma new];
                break;
            case 3:
                dataFileDummy = [LayCatalogDataFile_BayernFussball new];
                break;
            case 4:
                dataFileDummy = [LayCatalogDataFile_Spiegel new];
                break;
            default:
                break;
        }
        [dataFileDummy setNumberOfQuestions:GENERATE_NUMBER_OF_QUESTIONS];
        LayCatalogDataFileReaderDummy *dataFileReader =
                [[LayCatalogDataFileReaderDummy alloc]initWithDataFileDummy:dataFileDummy];
        LayCatalogImport *catalogImport = [[LayCatalogImport alloc]initWithDataFileReader:dataFileReader];
        LayCatalogImportReport* importReport = [catalogImport import];
        if(!importReport.imported) {
            LayCatalogFileInfo *fileMetaInfo = [dataFileReader metaInfo];
            MWLogError([LayTestDataImport class], @"Could not import catalog:%@.", fileMetaInfo.catalogTitle);
            errorOccurred = NO;
        }
    }
    return errorOccurred;
}

@end
