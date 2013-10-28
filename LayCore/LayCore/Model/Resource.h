//
//  Resource.h
//  LayCore
//
//  Created by Rene Kollmorgen on 17.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Catalog, Explanation, Question;

@interface Resource : NSManagedObject

@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * isbn;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Catalog *catalogRef;
@property (nonatomic, retain) NSSet *explanationRef;
@property (nonatomic, retain) NSSet *questionRef;
@end

@interface Resource (CoreDataGeneratedAccessors)

- (void)addExplanationRefObject:(Explanation *)value;
- (void)removeExplanationRefObject:(Explanation *)value;
- (void)addExplanationRef:(NSSet *)values;
- (void)removeExplanationRef:(NSSet *)values;

- (void)addQuestionRefObject:(Question *)value;
- (void)removeQuestionRefObject:(Question *)value;
- (void)addQuestionRef:(NSSet *)values;
- (void)removeQuestionRef:(NSSet *)values;

@end
