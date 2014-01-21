//
//  AnswerItem+Utilities.h
//  LayCore
//
//  Created by Rene Kollmorgen on 04.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "AnswerItem.h"

//
// AnswerItem (Utilities)
//
@class LayMediaData;
@class Explanation;
@class Media;
@interface AnswerItem (Utilities)

-(Media*)mediaInstance;
-(Media*)media;

-(void)setMediaItem:(Media*)mediaItem;

-(BOOL)hasMedia;
-(LayMediaData*)mediaData;

-(NSNumber*)itemNumber;

-(AnswerMedia*) answerMedia;

-(Explanation*)explanationInstance;
-(BOOL) hasExplanation;
-(void)setExplanation:(Explanation*)explanation;
-(Explanation*) explanation;

-(void)deleteAnswerItem;

-(BOOL)belongsToGroup;

@end
