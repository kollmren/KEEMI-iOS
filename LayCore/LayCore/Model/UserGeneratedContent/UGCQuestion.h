//
//  UGCQuestion.h
//  LayCore
//
//  Created by Rene Kollmorgen on 14.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UGCCase1, UGCCase2, UGCCase3, UGCCase4, UGCCase5, UGCCatalog, UGCNote, UGCResource;

@interface UGCQuestion : NSManagedObject

@property (nonatomic, retain) NSNumber * favourite;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * question;
@property (nonatomic, retain) UGCCase1 *case1Ref;
@property (nonatomic, retain) UGCCase2 *case2Ref;
@property (nonatomic, retain) UGCCase3 *case3Ref;
@property (nonatomic, retain) UGCCase4 *case4Ref;
@property (nonatomic, retain) UGCCase5 *case5Ref;
@property (nonatomic, retain) UGCCatalog *catalogRef;
@property (nonatomic, retain) NSSet *resourceRef;
@property (nonatomic, retain) NSSet *noteRef;
@end

@interface UGCQuestion (CoreDataGeneratedAccessors)

- (void)addResourceRefObject:(UGCResource *)value;
- (void)removeResourceRefObject:(UGCResource *)value;
- (void)addResourceRef:(NSSet *)values;
- (void)removeResourceRef:(NSSet *)values;

- (void)addNoteRefObject:(UGCNote *)value;
- (void)removeNoteRefObject:(UGCNote *)value;
- (void)addNoteRef:(NSSet *)values;
- (void)removeNoteRef:(NSSet *)values;

@end
