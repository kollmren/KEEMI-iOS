//
//  Explanation.h
//  LayCore
//
//  Created by Rene Kollmorgen on 16.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Answer, AnswerItem, Catalog, Resource, Section, Topic, Thumbnail;

@interface Explanation : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *answerItemRef;
@property (nonatomic, retain) NSSet *answerRef;
@property (nonatomic, retain) Catalog *catalogRef;
@property (nonatomic, retain) NSSet *resourceRef;
@property (nonatomic, retain) Topic *topicRef;
@property (nonatomic, retain) NSNumber * sectionCounter;
@property (nonatomic, retain) NSSet *sectionRef;
@property (nonatomic, retain) NSSet *thumbnailRef;

@end

@interface Explanation (CoreDataGeneratedAccessors)

- (void)addAnswerItemRefObject:(AnswerItem *)value;
- (void)removeAnswerItemRefObject:(AnswerItem *)value;
- (void)addAnswerItemRef:(NSSet *)values;
- (void)removeAnswerItemRef:(NSSet *)values;

- (void)addAnswerRefObject:(Answer *)value;
- (void)removeAnswerRefObject:(Answer *)value;
- (void)addAnswerRef:(NSSet *)values;
- (void)removeAnswerRef:(NSSet *)values;

- (void)addResourceRefObject:(Resource *)value;
- (void)removeResourceRefObject:(Resource *)value;
- (void)addResourceRef:(NSSet *)values;
- (void)removeResourceRef:(NSSet *)values;

- (void)addSectionRefObject:(Section *)value;
- (void)removeSectionRefObject:(Section *)value;
- (void)addSectionRef:(NSSet *)values;
- (void)removeSectionRef:(NSSet *)values;

- (void)addThumbnailRefObject:(Thumbnail *)value;
- (void)removeThumbnailRefObject:(Thumbnail *)value;
- (void)addThumbnailRef:(NSSet *)values;
- (void)removeThumbnailRef:(NSSet *)values;

@end
