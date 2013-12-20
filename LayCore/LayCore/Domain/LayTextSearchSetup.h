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

+(void)setupTextSearchForQuestion:(Question*)question;

+(void)setupTextSearchForExplanation:(Explanation*)explanation;

@end
