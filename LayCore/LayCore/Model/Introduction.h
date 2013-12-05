//
//  Introduction.h
//  LayCore
//
//  Created by Rene Kollmorgen on 05.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Question, Section;

@interface Introduction : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Question *questionRef;
@property (nonatomic, retain) NSSet *sectionRef;

@end

@interface Introduction (CoreDataGeneratedAccessors)

- (void)addSectionRefObject:(Section *)value;
- (void)removeSectionRefObject:(Section *)value;
- (void)addSectionRef:(NSSet *)values;
- (void)removeSectionRef:(NSSet *)values;

@end

