//
//  UGCCase3.h
//  LayCore
//
//  Created by Rene Kollmorgen on 25.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UGCCase3 : NSManagedObject

@property (nonatomic, retain) NSManagedObject *boxRef;
@property (nonatomic, retain) NSSet *questionRef;
@end

@interface UGCCase3 (CoreDataGeneratedAccessors)

- (void)addQuestionRefObject:(NSManagedObject *)value;
- (void)removeQuestionRefObject:(NSManagedObject *)value;
- (void)addQuestionRef:(NSSet *)values;
- (void)removeQuestionRef:(NSSet *)values;

@end
