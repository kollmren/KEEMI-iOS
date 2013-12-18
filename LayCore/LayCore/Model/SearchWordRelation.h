//
//  SearchWordRelation.h
//  LayCore
//
//  Created by Rene Kollmorgen on 18.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Explanation, Question, Resource, SearchWord;

@interface SearchWordRelation : NSManagedObject

@property (nonatomic, retain) NSString * catalogURI;
@property (nonatomic, retain) NSSet *searchWordRef;
@property (nonatomic, retain) Question *questionRef;
@property (nonatomic, retain) Explanation *explanationRef;
@property (nonatomic, retain) Resource *resourceRef;
@end

@interface SearchWordRelation (CoreDataGeneratedAccessors)

- (void)addSearchWordRefObject:(SearchWord *)value;
- (void)removeSearchWordRefObject:(SearchWord *)value;
- (void)addSearchWordRef:(NSSet *)values;
- (void)removeSearchWordRef:(NSSet *)values;

@end
