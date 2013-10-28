//
//  AnswerItem.h
//  LayCore
//
//  Created by Rene Kollmorgen on 10.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Answer, AnswerMedia, Explanation, Media;

@interface AnswerItem : NSManagedObject

@property (nonatomic, retain) NSNumber * correct;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * sessionString;
@property (nonatomic, retain) NSNumber * setByUser;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * sessionNumber;
@property (nonatomic, retain) AnswerMedia *answerMediaRef;
@property (nonatomic, retain) Answer *answerRef;
@property (nonatomic, retain) Explanation *explanationRef;
@property (nonatomic, retain) Media *mediaRef;

@end
