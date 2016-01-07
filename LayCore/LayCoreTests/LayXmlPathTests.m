//
//  LayXmlPathTests.m
//  LayCore
//
//  Created by Rene Kollmorgen on 07.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayXmlPathTests.h"
#import "LayXmlPath.h"

#import "MWLogging.h"

@implementation LayXmlPathTests

static Class _classObj = nil;


+(void)setUp {
    _classObj = [LayXmlPathTests class];
}

-(void)testInit{
    MWLogNameOfTest(_classObj);
    NSString *path1 = @"catalog/info_publisher";
    LayXmlPath *xmlPath1 = [[LayXmlPath alloc]initWithXmlPath:path1];
    XCTAssertNil(xmlPath1, @"Must be nil due to the invalid path");
    path1 = @"cataloginfo_publisher";
    xmlPath1 = [[LayXmlPath alloc]initWithXmlPath:path1];
    XCTAssertNil(xmlPath1, @"Must be nil due to the invalid path");
}

-(void)testPath{
    MWLogNameOfTest(_classObj);
    NSString *path1 = @"/catalog/info/publisher";
    NSString *path2 = @"/catalog";
    LayXmlPath *xmlPath1 = [[LayXmlPath alloc]initWithXmlPath:path1];
    LayXmlPath *xmlPath2 = [[LayXmlPath alloc]initWithXmlPath:path2];
    [xmlPath2 pushElementWithName:@"info"];
    [xmlPath2 pushElementWithName:@"publisher"];
    XCTAssertEqualObjects([xmlPath1 path] ,[xmlPath2 path]);
}

-(void)testPop{
    MWLogNameOfTest(_classObj);
    NSString *path1 = @"/catalog/info/publisher";
    NSString *path2 = @"/catalog";
    LayXmlPath *xmlPath1 = [[LayXmlPath alloc]initWithXmlPath:path1];
    LayXmlPath *xmlPath2 = [[LayXmlPath alloc]initWithXmlPath:path2];
    [xmlPath1 popElement];
    [xmlPath1 popElement];
    XCTAssertEqualObjects([xmlPath1 path] ,[xmlPath2 path]);
    //
    LayXmlPath *xmlPath3 = [[LayXmlPath alloc]init];
    LayXmlPath *xmlPath4 = [[LayXmlPath alloc]init];
    [xmlPath3 popElement];
    [xmlPath4 popElement];
}

-(void)testIsEqual {
    MWLogNameOfTest(_classObj);
    NSString *path1 = @"/catalog/info/publisher";
    NSString *path2 = @"/catalog";
    LayXmlPath *xmlPath1 = [[LayXmlPath alloc]initWithXmlPath:path1];
    LayXmlPath *xmlPath2 = [[LayXmlPath alloc]initWithXmlPath:path2];
    [xmlPath2 pushElementWithName:@"info"];
    [xmlPath2 pushElementWithName:@"publisher"];
    XCTAssertTrue([xmlPath1 isEqual:xmlPath2]);
}

@end
