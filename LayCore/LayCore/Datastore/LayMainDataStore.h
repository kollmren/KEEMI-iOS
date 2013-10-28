//
//  LayManagedObjectContext.h
//  LayCore
//
//  Created by Rene Kollmorgen on 14.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LayModelObject.h"

@class Catalog;
@interface LayMainDataStore : NSObject {
    @private
    NSManagedObjectContext *managedObjectContext;
}

+ (LayMainDataStore*) store;

+(BOOL) deleteCatalogWithinNewCreatedContext:(Catalog*)catalog;

-(NSUInteger) numberOfCatalogs;

-(id) createDomainObject:(LayModelObject)identifier;

-(BOOL) deleteAllCatalogsFromStore;

-(NSArray *) findAllCatalogs;

-(NSArray *) findAllCatalogsOrderedByDateLastImportedFirst;

-(Catalog *)findCatalogByTitle:(NSString*)titleOfCatalog;

-(Catalog *)findCatalogByTitle:(NSString*)titleOfCatalog andPublisher:(NSString*)nameOfPublisher;

-(BOOL)catalogExistsWith:(NSString*)title and:(NSString*)publisher;

- (BOOL)saveChanges;

-(NSManagedObjectContext*)managedObjectContext;

@end
