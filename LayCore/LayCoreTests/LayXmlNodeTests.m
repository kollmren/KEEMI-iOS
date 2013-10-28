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
    STAssertNotNil(node1, nil);
    STAssertNotNil(node2, nil);
    STAssertNotNil(node3, nil);
    
    [node1 addChildNode:node2];
    [node1 addChildNode:node3];
    LayXmlNode *parentNodeOfNode2 = node2.parentNode;
    STAssertTrue(node1 == parentNodeOfNode2, nil);
    
    LayXmlNode *refNode2 = [node1 nodeByName:nameOfNode2];
    STAssertNotNil(refNode2, nil);
    STAssertEquals(refNode2.name, nameOfNode2, nil);
}

-(void)testChildNodeList {
    MWLogNameOfTest(_classObj);
    NSString *nameOfNode1 = @"element1";
    NSString *nameOfNode2 = @"element2";
    NSString *nameOfNode3 = @"element3";
    LayXmlNode *node1 = [[LayXmlNode alloc]initWithName:nameOfNode1];
    LayXmlNode *node2 = [[LayXmlNode alloc]initWithName:nameOfNode2];
    LayXmlNode *node3 = [[LayXmlNode alloc]initWithName:nameOfNode3];
    STAssertNotNil(node1, nil);
    STAssertNotNil(node2, nil);
    STAssertNotNil(node3, nil);
    
    [node1 addChildNode:node2];
    [node1 addChildNode:node3];
    NSArray *childNodeList = [node1 childNodeList];
    STAssertNotNil(childNodeList, nil);
    STAssertTrue( 2 == [childNodeList count], nil);
}

-(void)testhasContent {
    MWLogNameOfTest(_classObj);
    NSString *nameOfNode1 = @"element1";
    LayXmlNode *node1 = [[LayXmlNode alloc]initWithName:nameOfNode1];
    STAssertNotNil(node1, nil);
    [node1 appendContent:@"content"];
    STAssertTrue(node1.hasContent, nil);
}

@end
