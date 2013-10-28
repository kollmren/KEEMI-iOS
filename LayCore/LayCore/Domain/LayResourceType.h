//
//  LayResourceType.h
//  LayCore
//
//  Created by Rene Kollmorgen on 17.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum LayResourceTypeIdentifier_ {
    RESOURCE_TYPE_WEB = 1,
    RESOURCE_TYPE_BOOK,
    RESOURCE_TYPE_FILE,
    RESOURCE_TYPE_UNKNOWN
} LayResourceTypeIdentifier;

@interface LayResourceType : NSObject

+(LayResourceTypeIdentifier)resourceTypeByString:(NSString*)resourceType;

@end
