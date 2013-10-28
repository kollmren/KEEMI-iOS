//
//  LayTestConfig.m
//  LayCore
//
//  Created by Rene Kollmorgen on 20.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayCoreTestConfig.h"
#import "LayDataStoreConfiguration.h"
#import "LayUserDataStoreConfiguration.h"
#import "LayXmlCatalogFileReader.h"
#import "LayCatalogImport.h"
#import "LayCatalogImportReport.h"
#import "LayCatalogManager.h"
#import "LayError.h"
#import "MWLogging.h"


const NSString* const TEST_DATA_DIR_NAME = @"TestData";

static NSMutableDictionary *g_testDataFiles = nil;

@implementation LayCoreTestConfig
static Class _classObj = nil;

+(void) initialize {
    _classObj = [LayCoreTestConfig class];
    [LayCoreTestConfig configureLogging];
    [LayCoreTestConfig initTestDataPathMap];
}

+(void) createDocumentDirectory {
    // The returned document path from:
    // [fileMngr URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    // is not the real path to the Document directory like the case the actually app is launched.
    // The returned path running in the simulator is like:
    // /Users/--USER---/Library/Application Support/iPhone Simulator/5.0
    // where --USER-- is the name of the user running the test.
    // We create a directory Documents in this directory.
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    NSArray *dirList = [fileMngr URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    if([dirList count] > 1) MWLogWarning(_classObj, @"More than one directory found!");
    NSURL *documentDirUrl = [dirList objectAtIndex:0];
    if(![fileMngr fileExistsAtPath:[documentDirUrl path]]) {
        NSError *error = nil;
        BOOL directotyDocumentCreated =
        [fileMngr createDirectoryAtURL:documentDirUrl withIntermediateDirectories:YES attributes:nil error:&error];
        if(directotyDocumentCreated) MWLogInfo(_classObj, @"Directory:%@ created!", documentDirUrl);
    }
    
}

+(BOOL) configureTestDataStore {
    NSFileManager *fileMngr = [[NSFileManager alloc]init];
    // Get the path to the Document directory from the current app running.
    NSArray *dirList = [fileMngr URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    if([dirList count] > 1) MWLogWarning(_classObj, @"More than one directory found! Testcase:testSetup");
    NSURL *documentDirUrl = [dirList objectAtIndex:0];
    NSString* STORE_FILE_NAME = @"LayCoreTest.sqlite";
    NSURL *urlStoreFile = [documentDirUrl URLByAppendingPathComponent:STORE_FILE_NAME];
    NSString* MODEL_FILE_NAME = @"LayDataModel";
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *pathToModelFile = [bundle pathForResource:MODEL_FILE_NAME ofType:@"momd"];
    NSURL *urlModelFile = [NSURL URLWithString:pathToModelFile];
    LayError *error = nil;
    BOOL configured = YES;
    if(![LayDataStoreConfiguration isValid]) {
        configured = [LayDataStoreConfiguration configure:urlStoreFile andUrlToModel:urlModelFile : &error];
    }
    if(!configured) MWLogError(_classObj, @"Configuration of datastore failed! Details:%@", [error description]);
    
    // configure store for user generated stuff
    NSString* USER_STORE_FILE_NAME = @"LayUserDataCoreTest.sqlite";
    NSURL *urlUserStoreFile = [documentDirUrl URLByAppendingPathComponent:USER_STORE_FILE_NAME];
    NSString* USER_MODEL_FILE_NAME = @"LayUserDataModel";
    NSString *pathToUSerModelFile = [bundle pathForResource:USER_MODEL_FILE_NAME ofType:@"momd"];
    NSURL *urlUserModelFile = [NSURL URLWithString:pathToUSerModelFile];
    error = nil;
    if(![LayUserDataStoreConfiguration isValid]) {
        configured = [LayUserDataStoreConfiguration configure:urlUserStoreFile andUrlToModel:urlUserModelFile : &error];
    }
    if(!configured) MWLogError(_classObj, @"Configuration of user-datastore failed! Details:%@", [error description]);
    
    return configured;
}

+(BOOL)configureLogging {
    BOOL configured = YES;
    NSString *nameOfLogFile = @"LayTestLog.log";
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    NSArray *dirList = [fileMngr URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentDirUrl = [dirList objectAtIndex:0];
    if(documentDirUrl) {
        NSURL* urlToLogFile = [documentDirUrl URLByAppendingPathComponent:nameOfLogFile];
        char const *path = [fileMngr fileSystemRepresentationWithPath:urlToLogFile.path];
        configured = logToFileWithPath(path)==true?YES:FALSE;
    } else {
        configured = NO;
    }
    return configured;
}

+(void) initTestDataPathMap {
    if(!g_testDataFiles) {
        g_testDataFiles = [NSMutableDictionary dictionaryWithCapacity:6];
        [g_testDataFiles setObject:@"/keemiReferenceCatalog/KeemiReferenceCatalog.xml" forKey:[NSNumber numberWithInt:TestDataPathXmlCatalogReference]];
        [g_testDataFiles setObject:@"/citizenshiptest/citizenshiptest.xml" forKey:[NSNumber numberWithInt:TestDataPathXmlCatalogCitizenshiptest]];
         [g_testDataFiles setObject:@"/citizenshiptest1/citizenshiptest.xml" forKey:[NSNumber numberWithInt:TestDataPathXmlCatalogCitizenshiptest1]];
         [g_testDataFiles setObject:@"/citizenshiptest2/citizenshiptest.xml" forKey:[NSNumber numberWithInt:TestDataPathXmlCatalogCitizenshiptest2]];
        [g_testDataFiles setObject:@"/citizenshiptest3/citizenshiptest.xml" forKey:[NSNumber numberWithInt:TestDataPathXmlCatalogCitizenshiptest3]];
        [g_testDataFiles setObject:@"/citizenshiptestNotWellFormedXml/citizenshiptest.xml" forKey:[NSNumber numberWithInt:TestDataPathNotWellFormedXmlCatalogCitizenshiptest]];
        [g_testDataFiles setObject:@"/citizenshiptestInvalid/citizenshiptest.xml" forKey:[NSNumber numberWithInt:TestDataPathInvalidXmlCatalogCitizenshiptest]];
        [g_testDataFiles setObject:@"/citizenshiptestOtherPublisher/citizenshiptest.xml" forKey:[NSNumber numberWithInt:TestDataPathXmlCatalogCitizenshiptestOtherPublisher]];
        [g_testDataFiles setObject:@"/citizenshiptestPack.keemi" forKey:[NSNumber numberWithInt:TestDataPathXmlCatalogCitizenshiptestZipped]];
        [g_testDataFiles setObject:@"/citizenshiptestMissingResources/citizenshiptest.xml" forKey:[NSNumber numberWithInt:TestDataPathCatalogCitizenshiptestWithMissingResources]];
        [g_testDataFiles setObject:@"/oneQuestionCatalog/OneQuestionCatalog.xml" forKey:[NSNumber numberWithInt:TestDataPathCatalogOneQuestionCatalog]];
        [g_testDataFiles setObject:@"/catalogWithNoQuestion/CatalogWithNoQuestion.xml" forKey:[NSNumber numberWithInt:TestDataPathCatalogWithNoQuestion]];
        [g_testDataFiles setObject:@"/einbürgerungstest/einbürgerungtest.xml" forKey:[NSNumber numberWithInt:TestDataPathCatalogEinbuerungstest]];
        [g_testDataFiles setObject:@"/catalogPossibleQuestionTypesGallery/CatalogPossibleQuestionTypesGallery.xml" forKey:[NSNumber numberWithInt:TestDataPathCatalogGallery]];
    }
}

+(NSURL*) pathToTestCatalog:(LayCoreTestDataPath)testDataFileId {
    NSURL *pathToCatalog = nil;
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    NSArray *dirList = [fileMngr URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentDirUrl = [dirList objectAtIndex:0];
    if(documentDirUrl) {
        NSNumber *testDataFileIdNumber = [NSNumber numberWithInt:testDataFileId];
        NSString *nameOfCatalogFile = [g_testDataFiles objectForKey:testDataFileIdNumber];
        NSString *pathToCatalogFile = [NSString stringWithFormat:@"%@%@", TEST_DATA_DIR_NAME, nameOfCatalogFile ];
        pathToCatalog = [documentDirUrl URLByAppendingPathComponent:pathToCatalogFile];
        if(![fileMngr fileExistsAtPath:[pathToCatalog path]]) {
            MWLogError(_classObj, @"File %@ does not exists!", [pathToCatalog path]);
        }
    } else {
        MWLogError(_classObj, @"Got now document-directory!");
    }
    return pathToCatalog;
}

+(void)populateTestDatabase {
    NSURL* catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest1];
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    LayCatalogImport *catalogImport = [[LayCatalogImport alloc]initWithDataFileReader:xmlDataFileReader];
    LayCatalogImportReport* importReport = [catalogImport import];
    if(!importReport.imported) {
        MWLogError(_classObj, @"Could not populate database with test-data(referenceCatalog)!");
    } else {
        [LayCatalogManager instance].currentSelectedCatalog = importReport.importedCatalog;
    }
    
    catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest];
    xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    catalogImport = [[LayCatalogImport alloc]initWithDataFileReader:xmlDataFileReader];
    importReport = [catalogImport import];
    if(!importReport.imported) {
        MWLogError(_classObj, @"Could not populate database with test-data(citizenship)!");
    }
    
    catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathCatalogOneQuestionCatalog];
    xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    catalogImport = [[LayCatalogImport alloc]initWithDataFileReader:xmlDataFileReader];
    importReport = [catalogImport import];
    if(!importReport.imported) {
        MWLogError(_classObj, @"Could not populate database with test-data(one-Question-catalog)!");
    }
}

@end
