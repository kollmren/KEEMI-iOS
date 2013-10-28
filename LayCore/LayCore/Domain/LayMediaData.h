//
//  LayMediaData.h
//  Lay
//
//  Created by Rene Kollmorgen on 07.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LayMediaTypes.h"

extern const NSString* const SHOW_LABEL_BEFORE_EVALUATED;

@class Media;
@interface LayMediaData : NSObject

@property (nonatomic) LayMediaType type;
@property (nonatomic) LayMediaFormat format;
@property (nonatomic) NSData* data;
@property (nonatomic,copy) NSString* name;
@property (nonatomic) NSString* label;
@property (nonatomic) NSString* showLabel;
@property (nonatomic) BOOL isLargeMedia;

-(void)setUIImage:(UIImage*)image;
-(UIImage*)uiimage;

+(LayMediaData*) byUIImage:(UIImage*)image;;

+(LayMediaData*) byMediaObject:(Media*)media;

+(LayMediaData*) byMediaObjectsThumbnailData:(Media*)media;

+(LayMediaData*) byData:(NSData*)data type:(LayMediaType)type andFormat:(LayMediaFormat)format;

@end
