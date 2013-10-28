//
//  UGCNote.h
//  LayCore
//
//  Created by Rene Kollmorgen on 14.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UGCCatalog, UGCExplanation, UGCQuestion;

@interface UGCNote : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSSet *questionRef;
@property (nonatomic, retain) UGCCatalog *catalogRef;
@property (nonatomic, retain) NSSet *explanationRef;
@end

@interface UGCNote (CoreDataGeneratedAccessors)

- (void)addQuestionRefObject:(UGCQuestion *)value;
- (void)removeQuestionRefObject:(UGCQuestion *)value;
- (void)addQuestionRef:(NSSet *)values;
- (void)removeQuestionRef:(NSSet *)values;

- (void)addExplanationRefObject:(UGCExplanation *)value;
- (void)removeExplanationRefObject:(UGCExplanation *)value;
- (void)addExplanationRef:(NSSet *)values;
- (void)removeExplanationRef:(NSSet *)values;

@end
