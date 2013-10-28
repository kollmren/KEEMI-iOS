//
//  AnswerMedia.h
//  LayCore
//
//  Created by Rene Kollmorgen on 12.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Answer, AnswerItem, Media;

@interface AnswerMedia : NSManagedObject

@property (nonatomic) int64_t number;
@property (nonatomic, retain) AnswerItem *answerItemRef;
@property (nonatomic, retain) Answer *answerRef;
@property (nonatomic, retain) Media *mediaRef;

@end
