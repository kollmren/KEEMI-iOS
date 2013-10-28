//
//  UGCCase2.h
//  LayCore
//
//  Created by Rene Kollmorgen on 25.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UGCQuestion;

@interface UGCCase2 : NSManagedObject

@property (nonatomic, retain) NSManagedObject *boxRef;
@property (nonatomic, retain) NSSet *questionRef;
@end

@interface UGCCase2 (CoreDataGeneratedAccessors)

- (void)addQuestionRefObject:(UGCQuestion *)value;
- (void)removeQuestionRefObject:(UGCQuestion *)value;
- (void)addQuestionRef:(NSSet *)values;
- (void)removeQuestionRef:(NSSet *)values;

@end
