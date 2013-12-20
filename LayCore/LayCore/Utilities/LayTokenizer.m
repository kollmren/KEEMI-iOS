//
//  LayRandomExplanationDataSource.h
//  LayCore
//
//  Created by Rene Kollmorgen on 16.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayTokenizer.h"


// For singleton implementation
static LayTokenizer* __tokenizer = nil;


@implementation LayTokenizer

+ (LayTokenizer*)sharedTokenizer
{
	if (!__tokenizer)
	{
		__tokenizer = [[LayTokenizer alloc] init];
	}
	return __tokenizer;
}


// Returns the set of stop words for FTS (from MySQL)
-(NSSet*)setupStopWordListFromFile:(NSString*)path
{
	if (stopWords) return stopWords;
    
    stopWords = [[NSSet alloc] initWithArray:[NSArray arrayWithContentsOfFile:path]];
    
	return stopWords;
}


- (NSCharacterSet*)splitChars
{
	if (splitChars) return splitChars;

	NSCharacterSet* cs = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz0123456789'"];
    splitChars = [cs invertedSet];
	return splitChars;
}


- (NSMutableSet*)tokenize:(NSString*)string
{
	// Remove diacritics and convert to lower case
	string = [string stringByFoldingWithOptions:kCFCompareCaseInsensitive|kCFCompareDiacriticInsensitive locale:[NSLocale systemLocale]];

	// Split on [^a-z0-9']
	NSArray* a = [string componentsSeparatedByCharactersInSet:[self splitChars]];

	// Convert to a set, remove stopwords (including the empty string), and return
	NSMutableSet* s = [NSMutableSet setWithArray:a];
	[s minusSet:[self stopWords]];
	return s;
}


- (NSString*)findLastToken:(NSString*)string position:(NSInteger*)position
{
	// Default
	if (position) *position = NSNotFound;
	
	// Remove diacritics and convert to lower case
	string = [string stringByFoldingWithOptions:kCFCompareCaseInsensitive|kCFCompareDiacriticInsensitive locale:[NSLocale systemLocale]];
	
	// Split on [^a-z0-9']
	NSArray* a = [string componentsSeparatedByCharactersInSet:[self splitChars]];

	// Find the position of the last non-empty keyword candidate
	for (NSInteger i = [a count]-1; i >= 0; i--)
	{
		NSString* s = [a objectAtIndex:i];
		if (![s length]) continue;
		
		if (position) *position = [string rangeOfString:s options:NSBackwardsSearch].location;
		return s;
	}
	
	// Default
	return nil;
}

-(NSSet*)stopWords {
    return stopWords;
}


@end
