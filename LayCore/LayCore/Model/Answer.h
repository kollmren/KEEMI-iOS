//
//  Answer.h
//  LayCore
//
//  Created by Rene Kollmorgen on 05.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AnswerItem, AnswerMedia, Explanation, Question;

@interface Answer : NSManagedObject
@property (nonatomic, retain) NSNumber * correctAnsweredByUser;
@property (nonatomic, retain) NSString * style;
@property (nonatomic, retain) NSString * sessionAnswer;
@property (nonatomic, retain) NSNumber * shuffleAnswers;
@property (nonatomic, retain) NSNumber * sessionGivenByUser;
@property (nonatomic, retain) NSNumber * numberOfVisibleChoices;
@property (nonatomic, retain) NSSet *answerItemRef;
@property (nonatomic, retain) NSSet *answerMediaRef;
@property (nonatomic, retain) Explanation *explanationRef;
@property (nonatomic, retain) Question *questionRef;
@end

@interface Answer (CoreDataGeneratedAccessors)

- (void)addAnswerItemRefObject:(AnswerItem *)value;
- (void)removeAnswerItemRefObject:(AnswerItem *)value;
- (void)addAnswerItemRef:(NSSet *)values;
- (void)removeAnswerItemRef:(NSSet *)values;

- (void)addAnswerMediaRefObject:(AnswerMedia *)value;
- (void)removeAnswerMediaRefObject:(AnswerMedia *)value;
- (void)addAnswerMediaRef:(NSSet *)values;
- (void)removeAnswerMediaRef:(NSSet *)values;

@end
