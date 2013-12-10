//
//  LayXmlPath.m
//  LayCore
//
//  Created by Rene Kollmorgen on 07.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayXmlPath.h"

#define MW_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_INFO

#import "MWLogging.h"

static const NSUInteger XML_PATH_DEFAULT_CHARACTERS = 50;

@interface LayXmlPath() {
    NSMutableString *path;
    NSString *pathDelimiter;
    NSString *currentElement;
}

@end

@implementation LayXmlPath

static Class _classObj = nil;

+(void) initialize {
    _classObj = [LayXmlPath class];
}

-(id)init {
    self = [super init];
    if(self) {
        pathDelimiter = @"/";
        self->path = [NSMutableString stringWithCapacity:XML_PATH_DEFAULT_CHARACTERS];
    }
    return self;
}

// xmlPath: e.g. /root/a/b
-(id)initWithXmlPath:(NSString*)xmlPath {
    if(NO==[LayXmlPath isValidPath:xmlPath]) return nil;
    self = [super init];
    if(self) {
        pathDelimiter = @"/";
        self->currentElement = [self extractCurrentElement:xmlPath];
        if(self->currentElement) {
            self->path = [NSMutableString stringWithCapacity:XML_PATH_DEFAULT_CHARACTERS];
            [self->path appendString:xmlPath];
        }
    }
    return self;
}

-(void)pushElementWithName:(NSString*)nameOfElement {
    MWLogDebug(_classObj, @"append element:%@ to path:%@", nameOfElement, self->path);
    [self->path appendFormat:@"%@%@", pathDelimiter, nameOfElement];
    self->currentElement = [self extractCurrentElement:self->path];
    MWLogDebug(_classObj, @"pushed path:%@", self->path);
}

-(void)popElement {
    if([self->currentElement length] <= 1) return;
    
    NSString *currentElementWithSlash = [NSString stringWithFormat:@"%@%@", pathDelimiter, self->currentElement];
    MWLogDebug(_classObj, @"pop current element:%@", currentElementWithSlash);
    NSRange currentElementRange = [self->path rangeOfString:currentElementWithSlash options:NSBackwardsSearch];
    @try{
        [self->path deleteCharactersInRange:currentElementRange];
    }
    @catch (NSException* ex){
        MWLogError(_classObj, @"Exception message:%@", [ex reason]);
    }
    
    // set currentElement - path can be ""
    if([self->path length]>0) {
        self->currentElement = [self extractCurrentElement:self->path];
        MWLogDebug(_classObj, @"poped path:%@", self->path);
    }
}

-(NSString*) extractCurrentElement:(NSString*)path_ {
    NSString* extractedCurrentElement = nil;
    NSRange idxDelim = [path_ rangeOfString:pathDelimiter options:NSBackwardsSearch];
    if(idxDelim.location!=NSNotFound) {
        extractedCurrentElement = [path_  substringFromIndex:idxDelim.location + 1];
        MWLogDebug(_classObj, @"Current element is:%@!", extractedCurrentElement);
    } else {
        MWLogError(_classObj, @"Seems that the valid check does not work!");
    }
    return extractedCurrentElement;
}

-(NSString*)path {
    return self->path;
}

-(BOOL)isEqual:(LayXmlPath*)xmlPath {
    BOOL equal = NO;
    MWLogDebug(_classObj, @"Compare path:%@ with path:%@", self->path, [xmlPath path]);
    if([self->path isEqualToString:[xmlPath path]]) {
        equal = YES;
    }
    return equal;
}

-(void)clear {
    [self->path setString:@""];
}

//
// super simple path check
// expected:
// example1: /element
// example2: /element/child
+(BOOL)isValidPath:(NSString*)xmlPath {
    BOOL validPath = YES;
    // checl length
    if([xmlPath length] <= 1) {
        validPath = NO;
    }
    // check if path starts with a /
    const unichar solidus = 0x002F; // solidus
    if(validPath) {
        unichar startChar = [xmlPath characterAtIndex:0];
        if(solidus != startChar) {
            validPath = NO;
        }
    }
    
    // check if path does not end with a /
    if(validPath) {
        const NSUInteger idxLastChar = [xmlPath length] - 1;
        unichar endChar = [xmlPath characterAtIndex:idxLastChar];
        if(solidus == endChar) {
            validPath = NO;
        }
    }
    
    
    if(!validPath) {
        MWLogError(_classObj, @"Given path:%@ is a invalid xml-path!", xmlPath);
    } else {
        MWLogDebug(_classObj, @"Given path:%@ is a valid xml-path!", xmlPath);
    }
    
    return validPath;
}


@end
