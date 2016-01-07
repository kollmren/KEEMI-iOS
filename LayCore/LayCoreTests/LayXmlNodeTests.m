//
//  LayXmlNodeTests.m
//  LayCore
//
//  Created by Rene Kollmorgen on 07.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayXmlNodeTests.h"
#import "LayXmlNode.h"

#import "MWLogging.h"

@implementation LayXmlNodeTests

static Class _classObj = nil;


+(void)setUp {
    _classObj = [LayXmlNodeTests class];
}

-(void)testNodeByName {
    MWLogNameOfTest(_classObj);
    NSString *nameOfNode1 = @"element1";
    NSString *nameOfNode2 = @"element2";
    NSString *nameOfNode3 = @"element3";
    LayXmlNode *node1 = [[LayXmlNode alloc]initWithName:nameOfNode1];
    LayXmlNode *node2 = [[LayXmlNode alloc]initWithName:nameOfNode2];
    LayXmlNode *node3 = [[LayXmlNode alloc]initWithName:nameOfNode3];
    XCTAssertNotNil(node1);
    XCTAssertNotNil(node2);
    XCTAssertNotNil(node3);
    
    [node1 addChildNode:node2];
    [node1 addChildNode:node3];
    LayXmlNode *parentNodeOfNode2 = node2.parentNode;
    XCTAssertTrue(node1 == parentNodeOfNode2);
    
    LayXmlNode *refNode2 = [node1 nodeByName:nameOfNode2];
    XCTAssertNotNil(refNode2);
    XCTAssertEqual(refNode2.name, nameOfNode2);
}

-(void)testChildNodeList {
    MWLogNameOfTest(_classObj);
    NSString *nameOfNode1 = @"element1";
    NSString *nameOfNode2 = @"element2";
    NSString *nameOfNode3 = @"element3";
    LayXmlNode *node1 = [[LayXmlNode alloc]initWithName:nameOfNode1];
    LayXmlNode *node2 = [[LayXmlNode alloc]initWithName:nameOfNode2];
    LayXmlNode *node3 = [[LayXmlNode alloc]initWithName:nameOfNode3];
    XCTAssertNotNil(node1);
    XCTAssertNotNil(node2);
    XCTAssertNotNil(node3);
    
    [node1 addChildNode:node2];
    [node1 addChildNode:node3];
    NSArray *childNodeList = [node1 childNodeList];
    XCTAssertNotNil(childNodeList);
    XCTAssertTrue( 2 == [childNodeList count]);
}

-(void)testhasContent {
    MWLogNameOfTest(_classObj);
    NSString *nameOfNode1 = @"element1";
    LayXmlNode *node1 = [[LayXmlNode alloc]initWithName:nameOfNode1];
    XCTAssertNotNil(node1);
    [node1 appendContent:@"content"];
    XCTAssertTrue(node1.hasContent);
}

@end
