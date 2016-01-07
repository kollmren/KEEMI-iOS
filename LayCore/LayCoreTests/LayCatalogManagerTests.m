//
//  LayCatalogManagerTest.m
//  LayCore
//
//  Created by Rene Kollmorgen on 22.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayCatalogManagerTests.h"
#import "LayCatalogManager.h"

#import "MWLogging.h"
#import <objc/runtime.h> //class_getName

@implementation LayCatalogManagerTests

-(void)testInstance {
    MWLogNameOfTest([LayCatalogManagerTests class]);
    LayCatalogManager* catalogManager1 = [LayCatalogManager instance];
    LayCatalogManager* catalogManager2 = [LayCatalogManager instance];
    XCTAssertEqualObjects(catalogManager1, catalogManager2);
}

@end
