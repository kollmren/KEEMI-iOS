//
//  LayTestDataHelper.h
//  Lay
//
//  Created by Rene Kollmorgen on 14.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Answer;
@class AnswerItem;
@interface LayTestDataHelper : NSObject

+(NSData*) getDataByPathTemplate:(NSString*)pathTemplate fileName:(NSString*)fileName andType:(NSString*)type;

+(NSData*) getDataOfFile:(NSString*)file andType:(NSString*)type;

+(void)addFileAsMediaToAnswer:(Answer*)answer file:(NSString*)filePath type:(NSString*)type linkedWith:(AnswerItem*)answerItem;

+(void)addFileAsMediaToAnswer:(Answer*)answer file:(NSString*)filePath type:(NSString*)type;

+(void)addFileAsMediaToAnswerItem:(AnswerItem*)answerItem file:(NSString*)filePath type:(NSString*)type;

@end
