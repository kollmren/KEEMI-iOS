//
//  Question+Utilities.h
//  LayCore
//
//  Created by Rene Kollmorgen on 04.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Question.h"
#import "LayAnswerType.h"

@class Topic, SectionQuestion;

@interface Question (Utilities)

-(Answer*)answerInstance;
-(void)setAnswer:(Answer*)answer;

-(Introduction*)introductionInstance;


-(NSNumber*)questionNumber;
-(void)setQuestionNumber:(NSUInteger)number;

-(void)setQuestionType:(NSUInteger)type;
-(LayAnswerTypeIdentifier) questionType;

-(NSUInteger)numberAsPrimitive;

-(BOOL)isChecked;
-(void)setIsChecked:(BOOL)checked;

-(void)setTopic:(Topic*)topic;

-(NSUInteger)caseNumberPrimitive;
-(void)setCaseNumberPrimitive:(NSUInteger )caseNumber;

-(NSArray*)resourceList;
-(BOOL)hasLinkedResources;

-(NSArray*)noteList;
-(BOOL)hasLinkedNotes;

-(BOOL)isFavourite;
-(void)markQuestionAsFavourite;
-(void)unmarkQuestionAsFavourite;

-(NSArray*)imageMediaList;

-(BOOL)hasThumbnails;
-(NSArray*)orderedThumbnailList;
-(NSArray*)orderedThumbnailListAsMediaData;

@end
