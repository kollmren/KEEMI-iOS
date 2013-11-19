//
//  LayMediaTypes.m
//  LayCore
//
//  Created by Rene Kollmorgen on 07.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayMediaTypes.h"
#import "MWLogging.h"

typedef struct KnownMediaTypeItem_ {
    const char* extension;
    LayMediaType type;
    LayMediaFormat format;
} KnownMediaTypeItem;

KnownMediaTypeItem knownMediaTypes[] = {
    {"jpg", LAY_MEDIA_IMAGE, LAY_FORMAT_JPG},
    {"jpeg", LAY_MEDIA_IMAGE, LAY_FORMAT_JPG},
    {"png", LAY_MEDIA_IMAGE, LAY_FORMAT_PNG},
    {"svg", LAY_MEDIA_XML, LAY_FORMAT_SVG},
    {"html", LAY_MEDIA_XML, LAY_FORMAT_HTML}
};

@implementation LayMediaTypeClass

static Class _classObj = nil;

+(void) initialize {
    _classObj = [LayMediaTypeClass class];
}
+(LayMediaType) typeByExtension:(NSString*)extension_ {
    LayMediaType mediaType = LAY_MEDIA_UNDEFINED;
    const char* extension = [extension_ UTF8String];
    for(size_t knownTypeIdx=0; knownTypeIdx < sizeof(knownMediaTypes)/sizeof(KnownMediaTypeItem); ++knownTypeIdx) {
        KnownMediaTypeItem knownMediaType = knownMediaTypes[knownTypeIdx];
        int compare = strcasecmp( extension, knownMediaType.extension );
        if(0==compare) {
            mediaType = knownMediaType.type;
        }
    }
    
    if(mediaType==LAY_MEDIA_UNDEFINED) {
        MWLogError([LayMediaTypeClass class], @"No type mapping for extension:%s", extension);
    }
    
    return mediaType;
}

+(LayMediaFormat) formatByExtension:(NSString*)type {
    LayMediaFormat mediaFormat = LAY_FORMAT_UNDEFINED;
    if(type && [type length] > 0) {
        const char* extension = [type UTF8String];
        for(size_t knownTypeIdx=0; knownTypeIdx < sizeof(knownMediaTypes)/sizeof(KnownMediaTypeItem); ++knownTypeIdx) {
            KnownMediaTypeItem knownMediaType = knownMediaTypes[knownTypeIdx];
            int compare = strcasecmp( extension, knownMediaType.extension );
            if(0==compare) {
                mediaFormat = knownMediaType.format;
            }
        }

    }
    return mediaFormat;
}

+(NSString*) extensionFromFileName:(NSString*)fileName {
    NSString *fileExtension = nil;
    NSRange idxDot = [fileName rangeOfString:@"." options:NSBackwardsSearch];
    if(idxDot.location!=NSNotFound) {
        if(idxDot.location >= [fileName length]) {
            MWLogError(_classObj, @"Given param:%@ contains no extension!", fileName);
        } else {
            fileExtension = [fileName  substringFromIndex:idxDot.location + 1];
            MWLogDebug(_classObj, @"Extension of file:%@!", fileExtension);
        }
    } else {
        MWLogError(_classObj, @"Given param:%@ contains no dot!", fileName);
    }
    return fileExtension;
}

+(LayMediaType) typeByString:(NSString*)descriptor {
    LayMediaType mediaType = LAY_MEDIA_UNDEFINED;
    if([descriptor isEqualToString:@"image"]) {
        mediaType = LAY_MEDIA_IMAGE;
    } else if([descriptor isEqualToString:@"html"]) {
        mediaType = LAY_MEDIA_XML;
    } else if([descriptor isEqualToString:@"xml"]) {
        mediaType = LAY_MEDIA_XML;
    } else {
        MWLogError([LayMediaTypeClass class], @"Unknown descriptor:%@ for media!", descriptor);
    }
    
    return mediaType;
}

@end
