//
//  SearchWord.h
//  LayCore
//
//  Created by Rene Kollmorgen on 18.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SearchWordRelation;

@interface SearchWord : NSManagedObject

@property (nonatomic, retain) NSString * languageId;
@property (nonatomic, retain) NSString * word;
@property (nonatomic, retain) NSSet *searchWordRelation;
@end

@interface SearchWord (CoreDataGeneratedAccessors)

- (void)addSearchWordRelationObject:(SearchWordRelation *)value;
- (void)removeSearchWordRelationObject:(SearchWordRelation *)value;
- (void)addSearchWordRelation:(NSSet *)values;
- (void)removeSearchWordRelation:(NSSet *)values;

@end
