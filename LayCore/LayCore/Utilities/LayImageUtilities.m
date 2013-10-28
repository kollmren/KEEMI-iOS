//
//  LayImageUtilities.m
//  LayCore
//
//  Created by Rene Kollmorgen on 03.09.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayImageUtilities.h"

#import "MWLogging.h"

static Class g_class = nil;

@implementation LayImageUtilities

// The actual size max. size of a thumbnail is 608 x 180
// we take a little bit smaler size here to be sure to fit into this size.
CGSize THUMBNAIL_SIZE = { 606.0f, 178.0f }; // in Pixel
static CGFloat scale = 1.0f;

+(void)initialize {
    g_class = [LayImageUtilities class];
    scale = [[UIScreen mainScreen] scale];
    THUMBNAIL_SIZE.height = THUMBNAIL_SIZE.height / scale;
    THUMBNAIL_SIZE.width = THUMBNAIL_SIZE.width / scale;
}

+ (NSData*)pngDataFrom:(UIImage *)image withSize:(CGSize)newImageSize {
    CGSize origImageSize = [image size];
    origImageSize.width = origImageSize.width  / scale;
    origImageSize.height = origImageSize.height  / scale;
    
    // The rectangle of the thumbnail
    CGRect newRect = CGRectMake(0, 0, newImageSize.width, newImageSize.height);
    
    // Figure out a scaling ratio to make sure we maintain the same aspect ratio
    float ratio = MIN(newRect.size.width / origImageSize.width,
                      newRect.size.height / origImageSize.height);
    
    // Scale the image exactly to the given size
    CGRect projectRect = { 0.0f, 0.0f, 0.0f, 0.0f };
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    
    // Create a transparent bitmap context with a scaling factor
    // equal to that of the screen
    UIGraphicsBeginImageContextWithOptions(projectRect.size, NO, 0.0f);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:projectRect
                                                    cornerRadius:0.0f];
    [path addClip];
    
    // Center the image in the thumbnail rectangle
    /*CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;*/
    
    // Draw the image on it
    [image drawInRect:projectRect];
    
    // Get the image from the image context, keep it as our thumbnail
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Get the PNG representation of the image and set it as our archivable data
    NSData *data = UIImagePNGRepresentation(smallImage);
    
    // Cleanup image context resources, we're done
    UIGraphicsEndImageContext();
    
    return data;
}

+(BOOL)mustBeThumbnaild:(NSData*)imageData {
    BOOL mustBeThumbnaild = NO;
    UIImage *image = [UIImage imageWithData:imageData];
    if(image) {
        CGSize origImageSize = [image size];
        origImageSize.width = origImageSize.width  / scale;
        origImageSize.height = origImageSize.height  / scale;
        if( origImageSize.width > THUMBNAIL_SIZE.width || origImageSize.height > THUMBNAIL_SIZE.height ) {
            mustBeThumbnaild = YES;
        }
    } else {
        MWLogError(g_class, @"Could not create image from data!");
    }
    return mustBeThumbnaild;
}

+(LayImageMetaData*)thumbnail:(NSData*)imageData {
    UIImage *image = [UIImage imageWithData:imageData];
    CGSize imageSize = [image size];
    NSData* thumbnail = [LayImageUtilities pngDataFrom:image withSize:THUMBNAIL_SIZE];
    LayImageMetaData *imageMetaData = [LayImageMetaData instanceWith:thumbnail width:imageSize.width height:imageSize.height andFormat:LAY_FORMAT_PNG];
    return imageMetaData;
}

@end

//
//
//
@implementation LayImageMetaData

@synthesize data, width, height, format;

+(LayImageMetaData*)instanceWith:(NSData*)data_ width:(CGFloat)width_ height:(CGFloat)height_ andFormat:(LayMediaFormat)format_ {
    LayImageMetaData *imageMetaData = [LayImageMetaData new];
    imageMetaData.data = data_;
    imageMetaData.width = width_;
    imageMetaData.height = height_;
    imageMetaData.format = format_;
    return imageMetaData;
}

@end
