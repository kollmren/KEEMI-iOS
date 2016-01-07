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
    XCTAssertNotNil(xmlDataCatcher);
}

-(void)testInitWithNotExistingFile{
    MWLogNameOfTest(_classObj);
    NSURL* catalofFile = [NSURL URLWithString:@"tmp/notExistingFile"];
    LayXmlDocumentDataCatcher *xmlDataCatcher = [[LayXmlDocumentDataCatcher alloc]initWithPathToXmlFile:catalofFile];
    XCTAssertNil(xmlDataCatcher);
}

-(void)testRegisterPath{
    MWLogNameOfTest(_classObj);
    NSURL* catalofFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest];;
    LayXmlDocumentDataCatcher *xmlDataCatcher = [[LayXmlDocumentDataCatcher alloc]initWithPathToXmlFile:catalofFile];
    XCTAssertNotNil(xmlDataCatcher);
    //
    LayXmlNode *infoNode = [[LayXmlNode alloc]initWithName:@"info"];
    NodeCatcherTarget *nodeCatcherTarget = [[NodeCatcherTarget alloc]initWithExpectedNode:infoNode];
    BOOL registered = [xmlDataCatcher registerPath:nodeCatcherTarget action:@selector(nodeCatcher:) forPath:@"/catalog/info"];
    XCTAssertTrue(registered);
}

-(void)testUnregisterPath{
    MWLogNameOfTest(_classObj);
    NSURL* catalofFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest];;
    LayXmlDocumentDataCatcher *xmlDataCatcher = [[LayXmlDocumentDataCatcher alloc]initWithPathToXmlFile:catalofFile];
    XCTAssertNotNil(xmlDataCatcher);
    //
    LayXmlNode *infoNode = [[LayXmlNode alloc]initWithName:@"info"];
    NodeCatcherTarget *nodeCatcherTarget = [[NodeCatcherTarget alloc]initWithExpectedNode:infoNode];
    NSString *pathToCatchData = @"/catalog/info";
    BOOL registered = [xmlDataCatcher registerPath:nodeCatcherTarget action:@selector(nodeCatcher:) forPath:pathToCatchData];
    XCTAssertTrue(registered);
    BOOL unregistered = [xmlDataCatcher unregisterPath:pathToCatchData];
    XCTAssertTrue(unregistered);
    //
    LayError *layError = nil;
    BOOL parsed = [xmlDataCatcher startCatching:&layError];
    XCTAssertTrue(parsed);
    // no data catched
    XCTAssertFalse(nodeCatcherTarget.result);
}

-(void)testStartCatching{
    MWLogNameOfTest(_classObj);
    NSURL* catalofFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest];
    LayXmlDocumentDataCatcher *xmlDataCatcher = [[LayXmlDocumentDataCatcher alloc]initWithPathToXmlFile:catalofFile];
    XCTAssertNotNil(xmlDataCatcher);
    //
    LayXmlNode *infoNode = [[LayXmlNode alloc]initWithName:@"info"];
    NodeCatcherTarget *nodeCatcherTarget = [[NodeCatcherTarget alloc]initWithExpectedNode:infoNode];
    BOOL registered = [xmlDataCatcher registerPath:nodeCatcherTarget action:@selector(nodeCatcher:) forPath:@"/catalog/info"];
    XCTAssertTrue(registered);
    LayError *layError = nil;
    BOOL parsed = [xmlDataCatcher startCatching:&layError];
    XCTAssertTrue(parsed);
    XCTAssertTrue(nodeCatcherTarget.result);
    // check node
    NSArray *nodeList = [nodeCatcherTarget catchedNodeList];
    XCTAssertNotNil(nodeList);
    XCTAssertTrue([nodeList count]>0);
    LayXmlNode* node = [nodeList objectAtIndex:0];
    XCTAssertNotNil(node);
    LayXmlNode* titleNode = [node nodeByName:@"title"];
    XCTAssertNotNil(titleNode);
    NSString* title = [titleNode content];
    XCTAssertEqualObjects(@"Einbürgerungstest", title);
}

-(void)testStartCatchingNodesWithAttributes{
    MWLogNameOfTest(_classObj);
    NSURL* catalofFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest];
    LayXmlDocumentDataCatcher *xmlDataCatcher = [[LayXmlDocumentDataCatcher alloc]initWithPathToXmlFile:catalofFile];
    XCTAssertNotNil(xmlDataCatcher);
    //
    LayXmlNode *questionNode = [[LayXmlNode alloc]initWithName:@"question"];
    NodeCatcherTarget *nodeCatcherTarget = [[NodeCatcherTarget alloc]initWithExpectedNode:questionNode];
    BOOL registered = [xmlDataCatcher registerPath:nodeCatcherTarget action:@selector(nodeCatcher:) forPath:@"/catalog/questionList/question"];
    XCTAssertTrue(registered);
    LayError *layError = nil;
    BOOL parsed = [xmlDataCatcher startCatching:&layError];
    XCTAssertTrue(parsed);
    XCTAssertTrue(nodeCatcherTarget.result);
    // check node
    NSArray *nodeList = [nodeCatcherTarget catchedNodeList];
    XCTAssertNotNil(nodeList);
    XCTAssertTrue([nodeList count]>0);
    LayXmlNode* catchedQuestionNode = [nodeList objectAtIndex:0];
    XCTAssertNotNil(catchedQuestionNode);
    NSString *typeOfAnswer = [catchedQuestionNode valueOfAttribute:@"type"];
    XCTAssertEqualObjects(@"singleChoice", typeOfAnswer);
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

