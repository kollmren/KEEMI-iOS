//
//  Section.h
//  LayCore
//
//  Created by Rene Kollmorgen on 16.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Explanation, SectionMedia, SectionText, About, SectionQuestion;

@interface Section : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) Explanation *explanationRef;
@property (nonatomic, retain) NSSet *sectionMediaRef;
@property (nonatomic, retain) NSSet *sectionTextRef;
@property (nonatomic, retain) NSNumber * sectionItemCounter;
@property (nonatomic, retain) NSNumber * sectionGroupCounter;
@property (nonatomic, retain) About *aboutRef;
@property (nonatomic, retain) SectionQuestion *sectionQuestionRef;


@end

@interface Section (CoreDataGeneratedAccessors)

- (void)addSectionMediaRefObject:(SectionMedia *)value;
- (void)removeSectionMediaRefObject:(SectionMedia *)value;
- (void)addSectionMediaRef:(NSSet *)values;
- (void)removeSectionMediaRef:(NSSet *)values;

- (void)addSectionTextRefObject:(SectionText *)value;
- (void)removeSectionTextRefObject:(SectionText *)value;
- (void)addSectionTextRef:(NSSet *)values;
- (void)removeSectionTextRef:(NSSet *)values;

@end
