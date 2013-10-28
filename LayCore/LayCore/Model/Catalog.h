//
//  Catalog.h
//  LayCore
//
//  Created by Rene Kollmorgen on 17.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Author, Explanation, Media, Publisher, Question, Resource, Topic, About;

@interface Catalog : NSManagedObject

@property (nonatomic, retain) NSString * catalogDescription;
@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * version;
@property (nonatomic, retain) Author *authorRef;
@property (nonatomic, retain) Media *coverRef;
@property (nonatomic, retain) NSSet *explanationRef;
@property (nonatomic, retain) Publisher *publisherRef;
@property (nonatomic, retain) NSSet *questionRef;
@property (nonatomic, retain) NSSet *topicRef;
@property (nonatomic, retain) NSSet *resourceRef;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSString * topic;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) About *aboutRef;
@property (nonatomic, retain) NSDate * imported;

@end

@interface Catalog (CoreDataGeneratedAccessors)

- (void)addExplanationRefObject:(Explanation *)value;
- (void)removeExplanationRefObject:(Explanation *)value;
- (void)addExplanationRef:(NSSet *)values;
- (void)removeExplanationRef:(NSSet *)values;

- (void)addQuestionRefObject:(Question *)value;
- (void)removeQuestionRefObject:(Question *)value;
- (void)addQuestionRef:(NSSet *)values;
- (void)removeQuestionRef:(NSSet *)values;

- (void)addTopicRefObject:(Topic *)value;
- (void)removeTopicRefObject:(Topic *)value;
- (void)addTopicRef:(NSSet *)values;
- (void)removeTopicRef:(NSSet *)values;

- (void)addResourceRefObject:(Resource *)value;
- (void)removeResourceRefObject:(Resource *)value;
- (void)addResourceRef:(NSSet *)values;
- (void)removeResourceRef:(NSSet *)values;

@end
