//
//  UGCExplanation.h
//  LayCore
//
//  Created by Rene Kollmorgen on 14.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UGCCatalog, UGCNote, UGCResource;

@interface UGCExplanation : NSManagedObject

@property (nonatomic, retain) NSNumber * favourite;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) UGCCatalog *catalogRef;
@property (nonatomic, retain) NSSet *resourceRef;
@property (nonatomic, retain) NSSet *noteRef;
@end

@interface UGCExplanation (CoreDataGeneratedAccessors)

- (void)addResourceRefObject:(UGCResource *)value;
- (void)removeResourceRefObject:(UGCResource *)value;
- (void)addResourceRef:(NSSet *)values;
- (void)removeResourceRef:(NSSet *)values;

- (void)addNoteRefObject:(UGCNote *)value;
- (void)removeNoteRefObject:(UGCNote *)value;
- (void)addNoteRef:(NSSet *)values;
- (void)removeNoteRef:(NSSet *)values;

@end
