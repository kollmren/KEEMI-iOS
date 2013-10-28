//
//  Media.h
//  LayCore
//
//  Created by Rene Kollmorgen on 16.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AnswerItem, AnswerMedia, Catalog, Publisher, SectionMedia, Topic, Thumbnail, MediaImageMap;

@interface Media : NSManagedObject

@property (nonatomic, retain) NSString * catalogID;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSNumber * format;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * showLabel;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * imgHeight;
@property (nonatomic, retain) NSNumber * imgWidth;
@property (nonatomic, retain) NSSet *answerItemRef;
@property (nonatomic, retain) NSSet *answerMediaRef;
@property (nonatomic, retain) Catalog *catalogRef;
@property (nonatomic, retain) SectionMedia *sectionMediaRef;
@property (nonatomic, retain) Publisher *publisherRef;
@property (nonatomic, retain) NSSet *mediaImageMapRef;
@property (nonatomic, retain) NSSet *topicRef;
@property (nonatomic, retain) Thumbnail *thumbnailRef;
@property (nonatomic, retain) NSNumber * isLargeMedia;

@end

@interface Media (CoreDataGeneratedAccessors)

- (void)addAnswerItemRefObject:(AnswerItem *)value;
- (void)removeAnswerItemRefObject:(AnswerItem *)value;
- (void)addAnswerItemRef:(NSSet *)values;
- (void)removeAnswerItemRef:(NSSet *)values;

- (void)addAnswerMediaRefObject:(AnswerMedia *)value;
- (void)removeAnswerMediaRefObject:(AnswerMedia *)value;
- (void)addAnswerMediaRef:(NSSet *)values;
- (void)removeAnswerMediaRef:(NSSet *)values;

- (void)addTopicRefObject:(Topic *)value;
- (void)removeTopicRefObject:(Topic *)value;
- (void)addTopicRef:(NSSet *)values;
- (void)removeTopicRef:(NSSet *)values;

- (void)addMediaImageMapRefObject:(MediaImageMap *)value;
- (void)removeMediaImageMapRefObject:(MediaImageMap *)value;
- (void)addMediaImageMapRef:(NSSet *)values;
- (void)removeMediaImageMapRef:(NSSet *)values;

@end
