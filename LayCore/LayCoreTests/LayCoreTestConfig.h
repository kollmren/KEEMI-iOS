//
//  LayTestConfig.h
//  LayCore
//
//  Created by Rene Kollmorgen on 20.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

//
//
extern const NSString* const TEST_DATA_DIR_NAME;

typedef enum LayCoreTestDataPath_ {
    TestDataPathXmlCatalogReference,
    TestDataPathXmlCatalogCitizenshiptest,
    TestDataPathXmlCatalogCitizenshiptest1,
    TestDataPathXmlCatalogCitizenshiptest2,
    TestDataPathXmlCatalogCitizenshiptest3,
    TestDataPathXmlCatalogCitizenshiptestOtherPublisher,
    TestDataPathXmlCatalogCitizenshiptestZipped,
    TestDataPathInvalidXmlCatalogCitizenshiptest,
    TestDataPathNotWellFormedXmlCatalogCitizenshiptest,
    TestDataPathCatalogCitizenshiptestWithMissingResources,
    TestDataPathCatalogOneQuestionCatalog,
    TestDataPathCatalogWithNoQuestion,
    TestDataPathCatalogEinbuerungstest,
    TestDataPathCatalogGallery
} LayCoreTestDataPath;

@class LayMainDataStore;
@interface LayCoreTestConfig : NSObject

+(void) createDocumentDirectory;

+(BOOL) configureTestDataStore;

+(NSURL*) pathToTestCatalog:(LayCoreTestDataPath)testDataFileId;

+(void)populateTestDatabase;

@end
