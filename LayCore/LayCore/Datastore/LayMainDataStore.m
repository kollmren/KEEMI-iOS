//
//  LayManagedObjectContext.m
//  LayCore
//
//  Created by Rene Kollmorgen on 14.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayMainDataStore.h"
#import "LayDataStoreConfiguration.h"
#import "LayDataStoreUtilities.h"
#import "MWLogging.h"

#import "Catalog+Utilities.h"


// globals
static Class g_classObj = nil;

@implementation LayMainDataStore 

//
// Public
//

+ (LayMainDataStore*) store {
    static LayMainDataStore* mainStore = nil;
    if (mainStore == nil) {
        mainStore = [LayMainDataStore initStore];
        if(mainStore) {
            MWLogInfo(g_classObj, @"Setup main store successfully.");
            
        } else {
            MWLogError(g_classObj, @"Failure setting up main datastore!");
            mainStore = nil;
        }
        
    }
    return mainStore;
}

+(BOOL) deleteCatalogWithinNewCreatedContext:(Catalog*)catalog_ {
    /*
     There was always ann error message if the deleteObject method was called from an context created within another thread.
     This class method created new context to delete the catalog.
     The error message was:
     2013-09-02 13:06:26.223 KEEMI[2037:907] *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'statement is still active'
     */
    BOOL deletedCatalog = NO;
    NSManagedObjectContext *managedObjContext_ = [LayMainDataStore createAnotherContext];
    if(managedObjContext_) {
        Catalog *catalog = [LayMainDataStore findCatalogByTitle:catalog_.title  andPublisher:[catalog_ publisher] with:managedObjContext_];
        if(catalog) {
            [managedObjContext_ deleteObject:catalog];
            NSError *err = nil;
            BOOL successful = [managedObjContext_ save:&err];
            if (!successful) {
                MWLogError(g_classObj, @"Error saving: %@", [err localizedDescription]);
            } else {
                MWLogInfo(g_classObj, @"Deleted catalog:%@, %@ successfully.", catalog_.title, [catalog_ publisher] );
                deletedCatalog = YES;
            }
            
            MWLogDebug(g_classObj, @"Cleanup data for optimizing search.");
            [LayMainDataStore cleanupDataForOptimizingSearchInContext:managedObjContext_];
            
        } else {
            MWLogError(g_classObj, @"Could not find catalog:(%@, %@) for deletion!", catalog_.title, [catalog_ publisher]);
        }
    } else {
        MWLogError(g_classObj, @"Could not create new managed object context!");
    }
    return deletedCatalog;
}

-(NSUInteger) numberOfCatalogs {
    return [[self findAllCatalogs] count];
}

+(void)cleanupDataForOptimizingSearchInContext:(NSManagedObjectContext *)managedObjContextToCleanup {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchWord"
                                              inManagedObjectContext:managedObjContextToCleanup];
    [fetchRequest setEntity:entity];
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"searchWordRelation.@count == 0"];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *allNoMoreReferencedSearchWords = [managedObjContextToCleanup executeFetchRequest:fetchRequest error:&error];
    if (allNoMoreReferencedSearchWords == nil) {
        MWLogError(g_classObj, @"Failure getting references to search words which are not referenced! Details:%@", [error description]);
    }
    
    if ([allNoMoreReferencedSearchWords count] == 0) {
        MWLogWarning(g_classObj, @"Got no references to search words which are not referenced!");
    }
    
    for (NSManagedObject* searchWord in allNoMoreReferencedSearchWords) {
        [managedObjContextToCleanup deleteObject:searchWord];
    }
    
    BOOL successful = [managedObjContextToCleanup save:&error];
    if (!successful) {
        MWLogError(g_classObj, @"Error saving cleaned up store! Details:%@", [error localizedDescription]);
    } else {
        MWLogInfo(g_classObj, @"Cleaned up store successfully.");
    }
}

-(BOOL) deleteAllCatalogsFromStore {
    BOOL allDeleted = NO;
    NSArray *allCatalogs = [self findAllCatalogs];
    for (Catalog *catalog in allCatalogs) {
        [self->managedObjectContext deleteObject:catalog];
    }
    NSError *error;
    allDeleted = [self->managedObjectContext save:&error];
    if(allDeleted) MWLogInfo(g_classObj, @"Deleted all catalogs from store!");
    else MWLogError(g_classObj, @"Failure deleting all catalogs:%@", [error description]);
    
    return allDeleted;
}

-(NSArray *) findAllCatalogs {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Catalog"
                                              inManagedObjectContext:self->managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *allCatalogs = [self->managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (allCatalogs == nil) {
        MWLogError(g_classObj, @"Failure getting all catalogs:%@ in ", [error description]);
    }
    return allCatalogs;
}

-(NSArray *) findAllCatalogsOrderedByDateLastImportedFirst {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Catalog"
                                              inManagedObjectContext:self->managedObjectContext];
    NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"imported" ascending:YES];
    dateSortDescriptor = [dateSortDescriptor reversedSortDescriptor];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:dateSortDescriptor, nil]];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *allCatalogs = [self->managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (allCatalogs == nil) {
        MWLogError(g_classObj, @"Failure getting all catalogs:%@ in ", [error description]);
    }
    return allCatalogs;
}

/*-(NSArray *) findAllQuestionsByCatalogTitle:(NSString*)titleOfCatalog {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Question"
                                              inManagedObjectContext:self->managedObjectContext];
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"number"
                            ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@",
                              titleOfCatalog];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sd]];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *allCatalogs = [self->managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (allCatalogs == nil) {
        MWLogError(g_classObj, @"Failure getting all catalogs:%@ in ", [error description]);
    }
    return allCatalogs;
}*/

-(Catalog *)findCatalogByTitle:(NSString*)titleOfCatalog {
    Catalog *catalog = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Catalog"
                                              inManagedObjectContext:self->managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@",
                              titleOfCatalog];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [self->managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        MWLogError(g_classObj, @"Failure executing fetch:%@", [error description]);
    } else if([fetchedObjects count] > 1) {
        catalog = [fetchedObjects objectAtIndex:0];
        MWLogWarning(g_classObj, @"There are two catalogs with the same title:%@ in the store!", titleOfCatalog);
    } else if([fetchedObjects count] == 1){
        catalog = [fetchedObjects objectAtIndex:0];
    }
    return catalog;
}

-(Catalog *)findCatalogByTitle:(NSString*)titleOfCatalog andPublisher:(NSString*)nameOfPublisher {
    Catalog *catalog = [LayMainDataStore findCatalogByTitle:titleOfCatalog andPublisher:nameOfPublisher with:self->managedObjectContext];
    return catalog;
}

-(BOOL)catalogExistsWith:(NSString*)title and:(NSString*)publisher {
    BOOL catalogExists = NO;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Catalog"
                                              inManagedObjectContext:self->managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@  AND publisherRef.name = %@",
                              title, publisher];
    
    //NSCompoundPredicate
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSUInteger numberOfCatalogsFound = [self->managedObjectContext countForFetchRequest:fetchRequest error:&error];
    if (numberOfCatalogsFound == NSNotFound) {
        MWLogError(g_classObj, @"Failure executing fetch:%@", [error description]);
    } else if(numberOfCatalogsFound > 1) {
        MWLogError(g_classObj, @"!!Internal error!! There are more than one catalogs with the same title/publisher in the store!", [error description]);
         catalogExists = YES;
    } else if(numberOfCatalogsFound == 1){
        catalogExists = YES;
    }
    return catalogExists;
}


-(id) createDomainObject:(LayModelObject)identifier {
    return [LayDataStoreUtilities insertDomainObject:identifier :self->managedObjectContext];
}

- (BOOL)saveChanges
{
    BOOL successful = YES;
    if([self->managedObjectContext hasChanges]) {
        NSError *err = nil;
        successful = [self->managedObjectContext save:&err];
        if (!successful) {
            MWLogError(g_classObj, @"Error saving: %@ , Details:%@", [err localizedDescription], [err userInfo]);
        }

    }
    return successful;
}

-(NSManagedObjectContext*)managedObjectContext {
    return self->managedObjectContext;
}

//
// Private
//
+ (void)initialize {
    g_classObj = [LayMainDataStore class];
}

+ (LayMainDataStore*) initStore {
    LayMainDataStore *datastore = nil;
    if(![LayDataStoreConfiguration isValid]) {
        MWLogError(g_classObj, @"Failure setting up datastore! Configuration is invalid!");
        return datastore;
    }
    
    NSPersistentStoreCoordinator *storeCoordinator = [LayDataStoreConfiguration storeCoordinator];
    if(storeCoordinator) {
        datastore = [[LayMainDataStore alloc]initWithStoreCoordinator:storeCoordinator];
    } else {
        MWLogError(g_classObj, @"Failure setting up datastore!");
        datastore = nil;
    }
	
    return datastore;
}

-(id) initWithStoreCoordinator:(NSPersistentStoreCoordinator *) storeCoordinator {
    if(nil == g_classObj) g_classObj = [LayMainDataStore class];
    if(nil==storeCoordinator) {
        MWLogError(g_classObj, @"Internal error! Store coordinator is not initialized!");
        return nil;
    }
    if (!(self = [super init]))
    {
        MWLogError(g_classObj, @"super init failed!");
        return nil;
    }

    self->managedObjectContext = [[NSManagedObjectContext alloc] init];
    [self->managedObjectContext setPersistentStoreCoordinator: storeCoordinator];
    return self;
}

+(NSManagedObjectContext*) createAnotherContext {
    NSManagedObjectContext *managaedObjectContext_ = nil;
    if(![LayDataStoreConfiguration isValid]) {
        MWLogError(g_classObj, @"Failure setting up datastore! Configuration is invalid!");
        return managaedObjectContext_;
    }
    NSPersistentStoreCoordinator *storeCoordinator = [LayDataStoreConfiguration storeCoordinator];
    if(storeCoordinator) {
        managaedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managaedObjectContext_ setPersistentStoreCoordinator: storeCoordinator];
    } else {
        MWLogError(g_classObj, @"Failure setting up datastore!");
    }
    return managaedObjectContext_;
}

+(Catalog *)findCatalogByTitle:(NSString*)titleOfCatalog andPublisher:(NSString*)nameOfPublisher with:(NSManagedObjectContext*)context {
    Catalog *catalog = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Catalog"
                                              inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@  AND publisherRef.name = %@",
                              titleOfCatalog, nameOfPublisher];
    
    //NSCompoundPredicate
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        MWLogError(g_classObj, @"Failure executing fetch:%@", [error description]);
    } else if([fetchedObjects count] > 1) {
        catalog = [fetchedObjects objectAtIndex:0];
        MWLogError(g_classObj, @"!!Internal error!! There are two catalogs with the same title/publisher in the store!", [error description]);
    } else if([fetchedObjects count] == 1){
        catalog = [fetchedObjects objectAtIndex:0];
    }
    return catalog;
}

-(id) init {
    NSPersistentStoreCoordinator *storeCoordinator = [LayDataStoreConfiguration storeCoordinator];
    return [self initWithStoreCoordinator:storeCoordinator];
}




@end
