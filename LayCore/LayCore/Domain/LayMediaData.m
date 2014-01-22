//
//  LayMediaData.m
//  Lay
//
//  Created by Rene Kollmorgen on 07.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayMediaData.h"
#import "Media+Utilities.h"
#import "Thumbnail.h"

#import "MWLogging.h"

@interface LayMediaData() {
    UIImage *image;
}
@end

const NSString* const SHOW_LABEL_BEFORE_EVALUATED = @"yes";

@implementation LayMediaData
@synthesize type, format, data, name, label, showLabel;


- (NSString *)description {
    NSString* className = NSStringFromClass([LayMediaData class]);
    NSString *description = [NSString stringWithFormat:@"%@, type:%d, format:%d", className, self.type, self.format];
    return description;
}

-(void)setUIImage:(UIImage*)image_ {
    self->image = image_;
}

-(UIImage*)uiimage {
    UIImage *uiimage = nil;
    if(self->image!=nil) {
        uiimage = image;
    } else {
        //uiimage = [UIImage imageWithData:self.data scale:2.0];
        uiimage = [UIImage imageWithData:self.data];
        uiimage = [UIImage imageWithCGImage:uiimage.CGImage scale:2.0f orientation:uiimage.imageOrientation];
        if(!uiimage) MWLogError([LayMediaData class], @"Cant create UIImage by media-data!");
    }
    return uiimage;
}

+(LayMediaData*) byUIImage:(UIImage*)image {
    LayMediaData *mediaData = [LayMediaData new];
    [mediaData setUIImage:image];
    mediaData.type = LAY_MEDIA_IMAGE;
    return mediaData;
}

+(LayMediaData*) byMediaObject:(Media*)media {
    LayMediaType type = [media mediaType];
    LayMediaFormat format = [media mediaFormat] ;
    LayMediaData *mediaData = [LayMediaData byData:media.data type:type andFormat:format];
    mediaData.name = media.name;
    mediaData.label = media.label;
    mediaData.showLabel = media.showLabel;
    return mediaData;
}

+(LayMediaData*) byMediaObjectsThumbnailData:(Media*)media {
    LayMediaType type = [media mediaType];
    LayMediaFormat format = [media mediaFormat] ;
    LayMediaData *mediaData = nil;
    if(media.thumbnailRef) {
        mediaData = [LayMediaData byData:media.thumbnailRef.data type:type andFormat:format];
        mediaData.name = media.name;
        mediaData.label = media.label;
        mediaData.showLabel = media.showLabel;
    }
    return mediaData;
}

+(LayMediaData*) byData:(NSData*)data type:(LayMediaType)type andFormat:(LayMediaFormat)format {
    LayMediaData *mediaData = [LayMediaData new];
    mediaData.data = data;
    mediaData.type = type;
    mediaData.format = format;
    return mediaData;
}

@end
