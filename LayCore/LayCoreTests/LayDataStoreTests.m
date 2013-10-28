//
//  LayDataStoreTests.m
//  LayCore
//
//  Created by Rene Kollmorgen on 14.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayDataStoreTests.h"
#import "LayMainDataStore.h"
#import "MWLogging.h"

#import "LayCoreTestConfig.h"
#import <objc/runtime.h>

@implementation LayDataStoreTests

static Class _classObj = nil;

// class method setUp runs only one for all tests.
+(void)setUp {
    _classObj = [LayDataStoreTests class];
    
    [LayCoreTestConfig createDocumentDirectory];
}

+(void)tearDown {
    
}

- (void)testSetupWithExistingModelFile
{
    MWLogNameOfTest(_classObj);
}


@end
