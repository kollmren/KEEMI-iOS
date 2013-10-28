//
//  LayXmlNode.m
//  LayCore
//
//  Created by Rene Kollmorgen on 07.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayXmlNode.h"

#import "MWLogging.h"

static const NSUInteger DEFAULT_CHILD_NODES_COUNT = 5;
static const NSUInteger DEFAULT_CONTENT_CAPACITY = 50;

@interface LayXmlNode() {
    @private
    NSMutableArray *childNodeList;
    NSMutableString *content;
    NSMutableDictionary *attrMap;
}
@end

@implementation LayXmlNode

@synthesize name, hasContent, parentNode, contextPath;

static Class _classObj = nil;

+(void) initialize {
    _classObj = [LayXmlNode class];
}

-(id)initWithName:(NSString*)name_ {
    self = [super init];
    if(self) {
        name = name_;
        parentNode = nil;
        content = [NSMutableString stringWithCapacity:DEFAULT_CONTENT_CAPACITY];
        childNodeList = [NSMutableArray arrayWithCapacity:DEFAULT_CHILD_NODES_COUNT];
        attrMap = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return self;
}

-(NSString*)description {
    NSString* pathDescription = nil;
    if(self.parentNode) {
        pathDescription = [NSString stringWithFormat:@"%@/%@", self.parentNode, self.name];
    } else {
        if(self.contextPath) {
            pathDescription = [NSString stringWithFormat:@"%@", self.contextPath];
        } else {
            pathDescription = [NSString stringWithFormat:@"/%@", self.name];
        }
    }
    return pathDescription;
}

-(void) addChildNode:(LayXmlNode*)node {
    [childNodeList addObject:node];
    node.parentNode = self;
}

-(LayXmlNode*)nodeByName:(NSString*)nameOfNode {
    LayXmlNode *xmlNode = nil;
    for (LayXmlNode *currentNode in self->childNodeList) {
        if([currentNode.name isEqualToString:nameOfNode]) {
            xmlNode = currentNode;
        }
    }
    return xmlNode;
}

// Comma Separated Values
-(NSString*)csvFromNodeByName:(NSString*)nameOfNode {
    NSMutableString *csv = [NSMutableString stringWithCapacity:50];
    NSString *comma = @",";
    for (LayXmlNode *currentNode in self->childNodeList) {
        if([currentNode.name isEqualToString:nameOfNode]) {
            [csv appendFormat:@"%@%@", [currentNode content], comma];
        }
    }
    
    NSRange lastComma = {0,0};
    lastComma.length = 1;
    lastComma.location = [csv length] - 1;
    
    [csv deleteCharactersInRange:lastComma];
    
    return csv;
}

-(NSArray*)childNodeList {
    return self->childNodeList;
}

-(NSArray*)childNodeListByName:(NSString*)childName {
    NSMutableArray *namedChlidNodeList = [NSMutableArray arrayWithCapacity:[self->childNodeList count]];
    for (LayXmlNode* childNode in self->childNodeList) {
        if([childNode.name isEqualToString:childName]) {
            [namedChlidNodeList addObject:childNode];
        }
    }
    return namedChlidNodeList;
}

-(void)appendContent:(NSString *)content_ {
    [self->content appendString:content_];
    hasContent = YES;
}

-(NSString*)content {
    return self->content;
}

-(void)setContent:(NSString*)content_ {
    [self->content setString:content_];
}

-(void)addAttribute:(NSString*)attrName value:(NSString*)attrValue {
    NSString* attr = [self->attrMap objectForKey:attrName];
    if(attr) {
        MWLogError(_classObj, @"Found another attribute:%@ with the same name! Ignore this attribute!", attrName);
    } else {
        [self->attrMap setObject:attrValue forKey:attrName];
    }
}

-(NSString*) valueOfAttribute:(NSString*)attrName {
    return [self->attrMap valueForKey:attrName];
}

-(NSDictionary*)attributeList {
    return self->attrMap;
}

@end
