//
//  LayMediaTypes.h
//  LayCore
//
//  Created by Rene Kollmorgen on 07.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum LayMediaType_ {
    LAY_MEDIA_IMAGE,
    LAY_MEDIA_AUDIO,
    LAY_MEDIA_VIDEO,
    LAY_MEDIA_XML,
    LAY_MEDIA_RICH_TEXT,
    LAY_MEDIA_UNDEFINED
} LayMediaType;

typedef enum LayMediaFormat_ {
    LAY_FORMAT_JPG,
    LAY_FORMAT_PNG,
    //
    LAY_FORMAT_SVG,
    LAY_FORMAT_HTML,
    //
    LAY_FORMAT_UNDEFINED
} LayMediaFormat;


@interface LayMediaTypeClass : NSObject

+(LayMediaType) typeByExtension:(NSString*)extension;

// valid strings: image, html, xml
+(LayMediaType) typeByString:(NSString*)descriptor;

+(LayMediaFormat) formatByExtension:(NSString*)type;

+(NSString*) extensionFromFileName:(NSString*)fileName;

@end
