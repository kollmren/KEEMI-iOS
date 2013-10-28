//
//  UGCCase5.h
//  LayCore
//
//  Created by Rene Kollmorgen on 01.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UGCBox, UGCQuestion;

@interface UGCCase5 : NSManagedObject

@property (nonatomic, retain) UGCBox *boxRef;
@property (nonatomic, retain) NSSet *questionRef;
@end

@interface UGCCase5 (CoreDataGeneratedAccessors)

- (void)addQuestionRefObject:(UGCQuestion *)value;
- (void)removeQuestionRefObject:(UGCQuestion *)value;
- (void)addQuestionRef:(NSSet *)values;
- (void)removeQuestionRef:(NSSet *)values;

@end
