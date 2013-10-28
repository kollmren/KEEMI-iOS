//
//  UGCCatalog.h
//  LayCore
//
//  Created by Rene Kollmorgen on 14.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UGCBox, UGCExplanation, UGCNote, UGCQuestion, UGCResource, UGCStatistic;

@interface UGCCatalog : NSManagedObject

@property (nonatomic, retain) NSString * nameOfPublisher;
@property (nonatomic, retain) NSNumber * numberOfQuestions;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) UGCBox *boxRef;
@property (nonatomic, retain) NSSet *explanationRef;
@property (nonatomic, retain) NSSet *questionsRef;
@property (nonatomic, retain) NSSet *resourceRef;
@property (nonatomic, retain) UGCStatistic *statisticRef;
@property (nonatomic, retain) NSSet *noteRef;
@end

@interface UGCCatalog (CoreDataGeneratedAccessors)

- (void)addExplanationRefObject:(UGCExplanation *)value;
- (void)removeExplanationRefObject:(UGCExplanation *)value;
- (void)addExplanationRef:(NSSet *)values;
- (void)removeExplanationRef:(NSSet *)values;

- (void)addQuestionsRefObject:(UGCQuestion *)value;
- (void)removeQuestionsRefObject:(UGCQuestion *)value;
- (void)addQuestionsRef:(NSSet *)values;
- (void)removeQuestionsRef:(NSSet *)values;

- (void)addResourceRefObject:(UGCResource *)value;
- (void)removeResourceRefObject:(UGCResource *)value;
- (void)addResourceRef:(NSSet *)values;
- (void)removeResourceRef:(NSSet *)values;

- (void)addNoteRefObject:(UGCNote *)value;
- (void)removeNoteRefObject:(UGCNote *)value;
- (void)addNoteRef:(NSSet *)values;
- (void)removeNoteRef:(NSSet *)values;

@end
