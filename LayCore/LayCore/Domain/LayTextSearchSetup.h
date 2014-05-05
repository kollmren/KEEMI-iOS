//
//  LayTextSearchSetup.h
//  LayCore
//
//  Created by Rene Kollmorgen on 19.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Question, Explanation;

@interface LayTextSearchSetup : NSObject

+(void)clearSearchWordRelationCache;

+(void)setupTextSearchForQuestion:(Question*)question andStopWordSet:(NSSet*)stopWordSet;

+(void)setupTextSearchForExplanation:(Explanation*)explanation andStopWordSet:(NSSet*)stopWordSet;

@end
