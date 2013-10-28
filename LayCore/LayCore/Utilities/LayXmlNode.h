//
//  LayXmlNode.h
//  LayCore
//
//  Created by Rene Kollmorgen on 07.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LayXmlPath.h"

@interface LayXmlNode : NSObject

@property (nonatomic,readonly) NSString* name;
@property (nonatomic, weak) LayXmlNode* parentNode;
@property (nonatomic,readonly) BOOL hasContent;
@property (nonatomic) NSString* contextPath;

-(id)initWithName:(NSString*)name;

-(void) addChildNode:(LayXmlNode*)node;

-(LayXmlNode*)nodeByName:(NSString*)name;
-(NSString*)csvFromNodeByName:(NSString*)nameOfNode;
-(NSArray*)childNodeList;
-(NSArray*)childNodeListByName:(NSString*)childName;

-(void)appendContent:(NSString *)content;
-(NSString*)content;
-(void)setContent:(NSString*)content_;

-(void)addAttribute:(NSString*)attrName value:(NSString*)attrValue;
-(NSDictionary*)attributeList;
-(NSString*) valueOfAttribute:(NSString*)attrName;

@end
