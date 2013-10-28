//
//  Thumbnail.h
//  LayCore
//
//  Created by Rene Kollmorgen on 04.09.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Explanation, Media, Question;

@interface Thumbnail : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * catalogID;
@property (nonatomic, retain) NSNumber * format;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) Media *mediaRef;
@property (nonatomic, retain) NSSet *questionRef;
@property (nonatomic, retain) NSSet *explanationRef;
@property (nonatomic, retain) NSString * name;

@end

@interface Thumbnail (CoreDataGeneratedAccessors)

- (void)addQuestionRefObject:(Question *)value;
- (void)removeQuestionRefObject:(Question *)value;
- (void)addQuestionRef:(NSSet *)values;
- (void)removeQuestionRef:(NSSet *)values;

- (void)addExplanationRefObject:(Explanation *)value;
- (void)removeExplanationRefObject:(Explanation *)value;
- (void)addExplanationRef:(NSSet *)values;
- (void)removeExplanationRef:(NSSet *)values;

@end
