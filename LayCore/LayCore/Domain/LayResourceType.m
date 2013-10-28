//
//  LayResourceType.m
//  LayCore
//
//  Created by Rene Kollmorgen on 17.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayResourceType.h"

#import "MWLogging.h"

@implementation LayResourceType

static const NSString* LAY_RESOURCE_TYPE_NAME_PAGE = @"website";
static const NSString* LAY_RESOURCE_TYPE_NAME_BOOK = @"book";
static const NSString* LAY_RESOURCE_TYPE_NAME_FILE = @"file";

static Class _classObj = nil;

+(void)initialize {
    _classObj = [LayResourceType class];
}

+(LayResourceTypeIdentifier)resourceTypeByString:(NSString*)resourceType;{
    LayResourceTypeIdentifier identifier = RESOURCE_TYPE_UNKNOWN;
    if([resourceType isEqualToString:(NSString*)LAY_RESOURCE_TYPE_NAME_PAGE]) {
        identifier = RESOURCE_TYPE_WEB;
    } else if([resourceType isEqualToString:(NSString*)LAY_RESOURCE_TYPE_NAME_BOOK]) {
        identifier = RESOURCE_TYPE_BOOK;
    } else if([resourceType isEqualToString:(NSString*)LAY_RESOURCE_TYPE_NAME_FILE]) {
        identifier = RESOURCE_TYPE_FILE;
    } else  {
        MWLogError(_classObj, @"Unknown type of resource:%@", resourceType);
    }
    return identifier;
}

@end
