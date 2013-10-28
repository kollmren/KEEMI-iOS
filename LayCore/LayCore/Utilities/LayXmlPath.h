//
//  LayXmlPath.h
//  LayCore
//
//  Created by Rene Kollmorgen on 07.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LayXmlPath : NSObject

-(id)init;

// xmlPath: e.g. /root/a/b
-(id)initWithXmlPath:(NSString*)xmlPath;

-(void)pushElementWithName:(NSString*)nameOfElement;

-(void)popElement;

-(NSString*)path;

-(BOOL)isEqual:(LayXmlPath*)xmlPath;

-(void)clear;

@end
