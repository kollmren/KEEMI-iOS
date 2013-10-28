//
//  Answer+Utilities.h
//  LayCore
//
//  Created by Rene Kollmorgen on 04.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Answer.h"
#import "LayMediaData.h"

typedef enum LayAnswerStyleTypes_ {
    StyleColumn, // presents the button in a separate column, only in single- and multiple-choice answer-view
    NoStyle
} LayAnswerStyleType;

//
// LayAnswerItemStyle
//
@interface LayAnswerStyle : NSObject {
@private
    NSArray* listWithPossibleStyles;
    NSMutableArray* styleList;
}

@property (nonatomic,readonly) NSString* plainStyleDescription;

+(id)styleWithString:(NSString*)styleDescription;
+(LayAnswerStyleType)styleTypeForDescription:(NSString*)description;

-(id)initWithStyleDescription:(NSString*)plainStyleDescription;

-(BOOL)hasStyle:(LayAnswerStyleType)style;

@end

//
// Answer
//
@class AnswerItem;
@class Explanation;
@interface Answer (Utilities)

-(NSArray*)answerItemListRandom;

-(NSArray*)answerItemListOrderedByNumber;

-(NSArray*)answerItemListSessionOrderPreserved;

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

@end
