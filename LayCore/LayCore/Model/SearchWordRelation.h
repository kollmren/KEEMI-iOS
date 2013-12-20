//
//  SearchWordRelation.h
//  LayCore
//
//  Created by Rene Kollmorgen on 18.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Explanation, Question, Resource, SearchWord, Catalog;

@interface SearchWordRelation : NSManagedObject

@property (nonatomic, retain) NSString * catalogURI;
@property (nonatomic, retain) Catalog *catalogRef;
@property (nonatomic, retain) NSSet *explanationRef;
@property (nonatomic, retain) NSSet *questionRef;
@property (nonatomic, retain) NSSet *resourceRef;
@property (nonatomic, retain) SearchWord *searchWordRef;

@end

//

@interface SearchWordRelation (CoreDataGeneratedAccessors)

- (void)addExplanationRefObject:(Explanation *)value;
- (void)removeExplanationRefObject:(Explanation *)value;
- (void)addExplanationRef:(NSSet *)values;
- (void)removeExplanationRef:(NSSet *)values;

- (void)addQuestionRefObject:(Question *)value;
- (void)removeQuestionRefObject:(Question *)value;
- (void)addQuestionRef:(NSSet *)values;
- (void)removeQuestionRef:(NSSet *)values;

- (void)addResourceRefObject:(Resource *)value;
- (void)removeResourceRefObject:(Resource *)value;
- (void)addResourceRef:(NSSet *)values;
- (void)removeResourceRef:(NSSet *)values;


@end
