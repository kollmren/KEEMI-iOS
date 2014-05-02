//
//  LayGithubCatalog.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 02.05.14.
//  Copyright (c) 2014 Rene. All rights reserved.
//

#import "LayGithubCatalog.h"


@implementation LayGithubCatalog

+(LayGithubCatalog*) catalogWithTitle:(NSString*)title cover:(NSData*)cover owner:(NSString*)owner url:(NSString*)url andVersion:(NSString*)version {
    LayGithubCatalog *catalog = [LayGithubCatalog new];
    catalog->title = title;
    catalog->cover = cover;
    catalog->owner = owner;
    catalog->version = version;
    catalog->url = url;
    return catalog;
}

@end