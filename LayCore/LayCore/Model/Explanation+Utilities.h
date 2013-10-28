//
//  Explanation+Utilities.h
//  LayCore
//
//  Created by Rene Kollmorgen on 09.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Explanation.h"
//
// Explanation (Utilities)
//
@class Topic;
@interface Explanation (Utilities)

-(NSNumber*)numberForSection;
-(NSArray*)sectionList;

-(BOOL)hasRelatedQuestions;
-(NSArray*)relatedQuestionList;

-(void)setTopic:(Topic*)topic;

-(NSArray*)resourceList;
-(BOOL)hasLinkedResources;

-(NSArray*)noteList;
-(BOOL)hasLinkedNotes;

-(BOOL)isFavourite;
-(void)markExplanationAsFavourite;
-(void)unmarkExplanationAsFavourite;

@end
