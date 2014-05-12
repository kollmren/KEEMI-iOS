//
//  Answer+Utilities.h
//  LayCore
//
//  Created by Rene Kollmorgen on 04.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Answer.h"
#import "LayMediaData.h"
#import "LayAnswerStyle.h"

//
// Answer
//
@class AnswerItem;
@class Explanation;
@interface Answer (Utilities)

-(NSArray*)answerItemRespectingLearnState;

-(NSArray*)answerItemListOrdered;

-(NSArray*)answerItemListSessionOrderPreserved;

-(NSArray*)completeAnswerItemListSessionOrderPreserved;

-(AnswerItem*)answerItemInstance;

-(void)addAnswerItem:(AnswerItem*)answerItem;

-(NSArray*)mediaList;

-(NSArray*)answerMediaList;

-(void)addMedia:(Media*)mediaItem;

-(void)addMedia:(Media*)mediaItem linkedWith:(AnswerItem*)answerItem;

-(void)setExplanation:(Explanation*)explanation;
-(BOOL) hasExplanation;
-(Explanation*) explanation;

-(BOOL)answeredByUser;

-(LayAnswerStyleType)styleType;

-(NSArray*)answerItemListWithGroupName:(NSString*)groupName;

@end
