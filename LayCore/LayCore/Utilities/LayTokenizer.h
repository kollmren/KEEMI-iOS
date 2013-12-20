//
//  LayRandomExplanationDataSource.h
//  LayCore
//
//  Created by Rene Kollmorgen on 16.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//
#import <Foundation/Foundation.h>


@interface LayTokenizer : NSObject
{
	NSSet*				stopWords;
	NSCharacterSet*		splitChars;
}

+ (LayTokenizer*)sharedTokenizer;

- (NSSet*)setupStopWordListFromFile:(NSString*)path;
- (NSCharacterSet*)splitChars;

- (NSMutableSet*)tokenize:(NSString*)string;
- (NSString*)findLastToken:(NSString*)string position:(NSInteger*)position;

@end
