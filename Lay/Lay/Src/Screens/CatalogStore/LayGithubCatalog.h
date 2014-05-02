//
//  LayGithubCatalog.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 02.05.14.
//  Copyright (c) 2014 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LayGithubCatalog : NSObject {
@public
    NSString *title;
    NSData *cover;
    NSString *owner;
    NSString *version;
    NSString *url;
    NSString *name;
    NSString *repoName;
    NSString *zipball_url;
}

+(LayGithubCatalog*) catalogWithTitle:(NSString*)title cover:(NSData*)cover owner:(NSString*)owner url:(NSString*)url  andVersion:(NSString*)version;

@end

