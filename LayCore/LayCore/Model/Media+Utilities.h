//
//  Media+Utilities.h
//  LayCore
//
//  Created by Rene Kollmorgen on 10.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Media.h"

#import "LayMediaTypes.h"

@interface Media (Utilities)

-(void)setMediaData:(NSData*)data_ type:(LayMediaType)mediaType format:(LayMediaFormat)mediaFormat;

-(LayMediaFormat)mediaFormat;

-(LayMediaType)mediaType;

-(void)setMediaFormat:(LayMediaFormat)mediaFormat;

-(void)setMediaType:(LayMediaType)mediaType;

-(BOOL)isImage;

@end
