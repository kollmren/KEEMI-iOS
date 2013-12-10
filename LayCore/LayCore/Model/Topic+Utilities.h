//
//  Topic+Utilities.h
//  LayCore
//
//  Created by Rene Kollmorgen on 19.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Topic.h"

@class Media;
@class Catalog;
@interface Topic (Utilities)

-(BOOL)hasMedia;
-(void)setMedia:(Media*)mediaItem;
-(Media*)media;

-(BOOL)isDefaultTopic;

-(void)setTopicNumber:(NSUInteger)number;
-(NSUInteger)numberPrimitive;

-(NSSet*)questionSet;
-(NSArray*)questionsOrderedByNumber;
-(NSUInteger)numberOfQuestions;

-(NSSet*)explanationSet;
-(NSUInteger)numberOfExplanations;

-(BOOL)topicIsSelected;
-(void)setTopicAsSelected;
-(void)setTopicAsNotSelected;

-(Catalog*)catalog;

-(BOOL)hasExplanations;
-(BOOL)hasQuestions;

@end
