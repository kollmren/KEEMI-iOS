//
//  LayImageUtilities.h
//  LayCore
//
//  Created by Rene Kollmorgen on 03.09.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "LayMediaTypes.h"

extern CGSize THUMBNAIL_SIZE;

//
// LayImageMetaData
//
@interface LayImageMetaData : NSObject

@property (nonatomic) NSData* data;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) LayMediaFormat format;

+(LayImageMetaData*)instanceWith:(NSData*)data width:(CGFloat)width height:(CGFloat)height andFormat:(LayMediaFormat)format;

@end

//
// LayImageUtilities
//
@interface LayImageUtilities : NSObject

+ (NSData*)pngDataFrom:(UIImage *)image withSize:(CGSize)newImageSize;

+(BOOL)mustBeThumbnaild:(NSData*)imageData;

+(LayImageMetaData*)thumbnail:(NSData*)imageData;

@end
