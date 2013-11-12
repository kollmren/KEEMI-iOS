//
//  LayAppConfiguration.h
//  Lay
//
//  Created by Rene Kollmorgen on 03.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

//extern const NSString* const NAME_OF_LOG_FILE;

@interface LayAppConfiguration : NSObject

+(BOOL) configureApp;

+(NSData*) contentOfLogFile;

+(NSData*) contentBackupedOfLogFile;

+(BOOL)configureLogging;

@end
