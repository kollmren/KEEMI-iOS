//
//  Media+Utilities.m
//  LayCore
//
//  Created by Rene Kollmorgen on 10.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Media+Utilities.h"
#import "LayImageUtilities.h"

#import "MWLogging.h"

@implementation Media (Utilities)

-(void)setMediaData:(NSData*)data_ type:(LayMediaType)mediaType format:(LayMediaFormat)mediaFormat {
    self.data = data_;
    self.type = [NSNumber numberWithUnsignedInteger:mediaType];
    self.format = [NSNumber numberWithUnsignedInteger:mediaFormat];
    UIImage *image = [UIImage imageWithData:data_];
    CGSize imageSize = [image size];
    self.imgWidth = [NSNumber numberWithFloat:imageSize.width];
    self.imgHeight = [NSNumber numberWithFloat:imageSize.height];
}

-(LayMediaType)mediaType {
    LayMediaType mediaType = [self.type unsignedIntegerValue];
    return mediaType;
}

-(LayMediaFormat)mediaFormat {
    LayMediaFormat mediaFormat = [self.format unsignedIntegerValue];
    return mediaFormat;
}

-(void)setMediaFormat:(LayMediaFormat)mediaFormat {
    self.format = [NSNumber numberWithUnsignedInteger:mediaFormat];
}

-(void)setMediaType:(LayMediaType)mediaType {
    self.type = [NSNumber numberWithUnsignedInteger:mediaType];
}

-(BOOL)isImage {
    BOOL isImage = NO;
    LayMediaType mediaType = [self.type unsignedIntegerValue];
    if(LAY_MEDIA_IMAGE == mediaType) {
        isImage = YES;
    }
    return isImage;
}

@end
