//
//  Question.h
//  LayCore
//
//  Created by Rene Kollmorgen on 17.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Answer, Catalog, Resource, Topic, Thumbnail;

@interface Question : NSManagedObject

@property (nonatomic, retain) NSNumber * caseNumber;
@property (nonatomic, retain) NSNumber * favourite;
@property (nonatomic, retain) NSNumber * checked;
@property (nonatomic, retain) NSString * hint;
@property (nonatomic, retain) NSString * introduction;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * question;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Answer *answerRef;
@property (nonatomic, retain) Catalog *catalogRef;
@property (nonatomic, retain) Topic *topicRef;
@property (nonatomic, retain) NSSet *resourceRef;
@property (nonatomic, retain) NSSet *thumbnailRef;
@end

@interface Question (CoreDataGeneratedAccessors)

- (void)addResourceRefObject:(Resource *)value;
- (void)removeResourceRefObject:(Resource *)value;
- (void)addResourceRef:(NSSet *)values;
- (void)removeResourceRef:(NSSet *)values;

- (void)addThumbnailRefObject:(Thumbnail *)value;
- (void)removeThumbnailRefObject:(Thumbnail *)value;
- (void)addThumbnailRef:(NSSet *)values;
- (void)removeThumbnailRef:(NSSet *)values;

@end
