//
//  LayXmlDocumentDataCatcherTests.m
//  LayCore
//
//  Created by Rene Kollmorgen on 08.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayXmlDocumentDataCatcherTests.h"
#import "LayXmlDocumentDataCatcher.h"
#import "LayXmlNode.h"
#import "LayError.h"

#import "MWLogging.h"
#import "LayCoreTestConfig.h"

//
// NodeCatcherTarget
//
@interface NodeCatcherTarget : NSObject {
    LayXmlNode* expectedNode;
    NSMutableArray *catchedNodeList;
}

@property (nonatomic, readonly) BOOL result;

-(id)initWithExpectedNode:(LayXmlNode*)xmlNode;

-(NSArray*)catchedNodeList;

-(void)nodeCatcher:(LayXmlNode*)xmlNode;

@end

//
// LayXmlDocumentDataCatcherTests
//
@implementation LayXmlDocumentDataCatcherTests

static Class _classObj = nil;


+(void)setUp {
    _classObj = [LayXmlDocumentDataCatcherTests class];
}

-(void)testInit{
    MWLogNameOfTest(_classObj);
    NSURL* catalofFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest];
    LayXmlDocumentDataCatcher *xmlDataCatcher = [[LayXmlDocumentDataCatcher alloc]initWithPathToXmlFile:catalofFile];
    STAssertNotNil(xmlDataCatcher, nil);
}

-(void)testInitWithNotExistingFile{
    MWLogNameOfTest(_classObj);
    NSURL* catalofFile = [NSURL URLWithString:@"tmp/notExistingFile"];
    LayXmlDocumentDataCatcher *xmlDataCatcher = [[LayXmlDocumentDataCatcher alloc]initWithPathToXmlFile:catalofFile];
    STAssertNil(xmlDataCatcher, nil);
}

-(void)testRegisterPath{
    MWLogNameOfTest(_classObj);
    NSURL* catalofFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest];;
    LayXmlDocumentDataCatcher *xmlDataCatcher = [[LayXmlDocumentDataCatcher alloc]initWithPathToXmlFile:catalofFile];
    STAssertNotNil(xmlDataCatcher, nil);
    //
    LayXmlNode *infoNode = [[LayXmlNode alloc]initWithName:@"info"];
    NodeCatcherTarget *nodeCatcherTarget = [[NodeCatcherTarget alloc]initWithExpectedNode:infoNode];
    BOOL registered = [xmlDataCatcher registerPath:nodeCatcherTarget action:@selector(nodeCatcher:) forPath:@"/catalog/info"];
    STAssertTrue(registered, nil);
}

-(void)testUnregisterPath{
    MWLogNameOfTest(_classObj);
    NSURL* catalofFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest];;
    LayXmlDocumentDataCatcher *xmlDataCatcher = [[LayXmlDocumentDataCatcher alloc]initWithPathToXmlFile:catalofFile];
    STAssertNotNil(xmlDataCatcher, nil);
    //
    LayXmlNode *infoNode = [[LayXmlNode alloc]initWithName:@"info"];
    NodeCatcherTarget *nodeCatcherTarget = [[NodeCatcherTarget alloc]initWithExpectedNode:infoNode];
    NSString *pathToCatchData = @"/catalog/info";
    BOOL registered = [xmlDataCatcher registerPath:nodeCatcherTarget action:@selector(nodeCatcher:) forPath:pathToCatchData];
    STAssertTrue(registered, nil);
    BOOL unregistered = [xmlDataCatcher unregisterPath:pathToCatchData];
    STAssertTrue(unregistered, nil);
    //
    LayError *layError = nil;
    BOOL parsed = [xmlDataCatcher startCatching:&layError];
    STAssertTrue(parsed, nil);
    // no data catched
    STAssertFalse(nodeCatcherTarget.result, nil);
}

-(void)testStartCatching{
    MWLogNameOfTest(_classObj);
    NSURL* catalofFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest];
    LayXmlDocumentDataCatcher *xmlDataCatcher = [[LayXmlDocumentDataCatcher alloc]initWithPathToXmlFile:catalofFile];
    STAssertNotNil(xmlDataCatcher, nil);
    //
    LayXmlNode *infoNode = [[LayXmlNode alloc]initWithName:@"info"];
    NodeCatcherTarget *nodeCatcherTarget = [[NodeCatcherTarget alloc]initWithExpectedNode:infoNode];
    BOOL registered = [xmlDataCatcher registerPath:nodeCatcherTarget action:@selector(nodeCatcher:) forPath:@"/catalog/info"];
    STAssertTrue(registered, nil);
    LayError *layError = nil;
    BOOL parsed = [xmlDataCatcher startCatching:&layError];
    STAssertTrue(parsed, nil);
    STAssertTrue(nodeCatcherTarget.result, nil);
    // check node
    NSArray *nodeList = [nodeCatcherTarget catchedNodeList];
    STAssertNotNil(nodeList, nil);
    STAssertTrue([nodeList count]>0, nil);
    LayXmlNode* node = [nodeList objectAtIndex:0];
    STAssertNotNil(node, nil);
    LayXmlNode* titleNode = [node nodeByName:@"title"];
    STAssertNotNil(titleNode, nil);
    NSString* title = [titleNode content];
    STAssertEqualObjects(@"Einbürgerungstest", title, nil);
}

-(void)testStartCatchingNodesWithAttributes{
    MWLogNameOfTest(_classObj);
    NSURL* catalofFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest];
    LayXmlDocumentDataCatcher *xmlDataCatcher = [[LayXmlDocumentDataCatcher alloc]initWithPathToXmlFile:catalofFile];
    STAssertNotNil(xmlDataCatcher, nil);
    //
    LayXmlNode *questionNode = [[LayXmlNode alloc]initWithName:@"question"];
    NodeCatcherTarget *nodeCatcherTarget = [[NodeCatcherTarget alloc]initWithExpectedNode:questionNode];
    BOOL registered = [xmlDataCatcher registerPath:nodeCatcherTarget action:@selector(nodeCatcher:) forPath:@"/catalog/questionList/question"];
    STAssertTrue(registered, nil);
    LayError *layError = nil;
    BOOL parsed = [xmlDataCatcher startCatching:&layError];
    STAssertTrue(parsed, nil);
    STAssertTrue(nodeCatcherTarget.result, nil);
    // check node
    NSArray *nodeList = [nodeCatcherTarget catchedNodeList];
    STAssertNotNil(nodeList, nil);
    STAssertTrue([nodeList count]>0, nil);
    LayXmlNode* catchedQuestionNode = [nodeList objectAtIndex:0];
    STAssertNotNil(catchedQuestionNode, nil);
    NSString *typeOfAnswer = [catchedQuestionNode valueOfAttribute:@"type"];
    STAssertEqualObjects(@"singleChoice", typeOfAnswer, nil);
}

@end


//
// NodeCatcherTarget
//
@implementation NodeCatcherTarget

@synthesize result;

-(id)initWithExpectedNode:(LayXmlNode*)xmlNode {
    self = [super init];
    if(self) {
        self->catchedNodeList = [NSMutableArray arrayWithCapacity:10];
        self->expectedNode = xmlNode;
        result = NO;
    }
    return self;
}


-(void)nodeCatcher:(LayXmlNode*)xmlNode {
    if([self->expectedNode.name isEqualToString:xmlNode.name]) {
        result = YES;
        [catchedNodeList addObject:xmlNode];
    }
}

-(NSArray*)catchedNodeList {
    return self->catchedNodeList;
}

@end

