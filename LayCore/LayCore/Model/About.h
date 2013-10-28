//
//  About.h
//  LayCore
//
//  Created by Rene Kollmorgen on 19.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Catalog, Section;

@interface About : NSManagedObject

@property (nonatomic, retain) Catalog *catalogRef;
@property (nonatomic, retain) NSSet *sectionRef;
@property (nonatomic, retain) NSNumber * sectionCounter;

@end

@interface About (CoreDataGeneratedAccessors)

- (void)addSectionRefObject:(Section *)value;
- (void)removeSectionRefObject:(Section *)value;
- (void)addSectionRef:(NSSet *)values;
- (void)removeSectionRef:(NSSet *)values;

@end
