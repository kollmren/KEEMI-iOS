//
//  LayTestDataHelper.m
//  Lay
//
//  Created by Rene Kollmorgen on 14.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayTestDataHelper.h"
#import "MWLogging.h"
#import "LayDataStoreUtilities.h"
#import "Answer+Utilities.h"
#import "AnswerItem+Utilities.h"
#import "Media+Utilities.h"

@implementation LayTestDataHelper

+(NSData*) getDataByPathTemplate:(NSString*)pathTemplate fileName:(NSString*)fileName andType:(NSString*)type
{
    NSString *filePath = [NSString stringWithFormat:pathTemplate, fileName];
    return [LayTestDataHelper getDataOfFile:filePath andType:type];
}

+(NSData*) getDataOfFile:(NSString*)file andType:(NSString*)type {
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *pathTolFile = [bundle pathForResource:file ofType:type];
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    BOOL fileExists = [fileMngr fileExistsAtPath:pathTolFile];
    NSData *contentOfFile = nil;
    if(fileExists) {
        contentOfFile = [fileMngr contentsAtPath:pathTolFile];
    } else {
        MWLogError([LayTestDataHelper class], @"Could not load content of file:%@", pathTolFile);
    }
    
    return contentOfFile;  
}

+(void)addFileAsMediaToAnswer:(Answer*)answer file:(NSString*)filePath type:(NSString*)type {
    [self addFileAsMediaToAnswer:answer file:filePath type:type linkedWith:nil];
}

+(void)addFileAsMediaToAnswer:(Answer*)answer file:(NSString*)filePath type:(NSString*)type linkedWith:(AnswerItem*)answerItem {
    NSData *data = [LayTestDataHelper getDataOfFile:filePath andType:type];
    LayMediaType mediaType = [LayMediaTypeClass typeByExtension:type];
    LayMediaFormat mediaFormat = [LayMediaTypeClass formatByExtension:type];
    Media *mediaItem = [LayDataStoreUtilities insertDomainObject:LayMedia :answer.managedObjectContext];
    mediaItem.name = filePath;
    mediaItem.catalogID = filePath; // only for test-data generation
    [mediaItem setMediaData:data type:mediaType format:mediaFormat];
    [answer addMedia:mediaItem linkedWith:answerItem];
}

+(void)addFileAsMediaToAnswerItem:(AnswerItem*)answerItem file:(NSString*)filePath type:(NSString*)type {
    NSData *data = [LayTestDataHelper getDataOfFile:filePath andType:type];
    LayMediaType mediaType = [LayMediaTypeClass typeByExtension:type];
    LayMediaFormat mediaFormat = [LayMediaTypeClass formatByExtension:type];
   Media *mediaItem = [LayDataStoreUtilities insertDomainObject:LayMedia :answerItem.managedObjectContext];
    mediaItem.name = filePath;
    mediaItem.catalogID = filePath; // only for test-data generation
    [mediaItem setMediaData:data type:mediaType format:mediaFormat];
    [answerItem setMediaItem:mediaItem];
}

@end
