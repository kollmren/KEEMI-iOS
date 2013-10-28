//
//  LayCore
//
//  Created by Rene Kollmorgen on 14.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayUserDataStore.h"
#import "LayUserDataStoreConfiguration.h"
#import "MWLogging.h"

#import "UGCCatalog+Utilities.h"
#import "UGCBox.h"
#import "UGCCase1.h"
#import "UGCCase2.h"
#import "UGCCase3.h"
#import "UGCCase4.h"
#import "UGCCase5.h"


// globals
static Class g_classObj = nil;

@implementation LayUserDataStore 

//
// Public
//

+ (LayUserDataStore*) store {
    static LayUserDataStore* mainStore = nil;
    if (mainStore == nil) {
        mainStore = [LayUserDataStore initStore];
        if(mainStore) {
            MWLogInfo(g_classObj, @"Setup main store successfully.");
            
        } else {
            MWLogError(g_classObj, @"Failure setting up main datastore!");
            mainStore = nil;
        }
        
    }
    return mainStore;
}

-(BOOL) deleteAllCatalogsFromStore {
    BOOL allDeleted = NO;
    NSArray *allCatalogs = [self findAllCatalogs];
    for (UGCCatalog *catalog in allCatalogs) {
        [self->managedObjectContext deleteObject:catalog];
    }
    NSError *error;
    allDeleted = [self->managedObjectContext save:&error];
    if(allDeleted) MWLogInfo(g_classObj, @"Deleted all catalogs from store!");
    else MWLogError(g_classObj, @"Failure deleting all catalogs:%@", [error description]);
    
    return allDeleted;
}

-(UGCCatalog *)findCatalogByTitle:(NSString*)titleOfCatalog andPublisher:(NSString*)nameOfPublisher {
    UGCCatalog *catalog = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UGCCatalog"
                                              inManagedObjectContext:self->managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@  AND nameOfPublisher = %@",
                              titleOfCatalog, nameOfPublisher];
    
    //NSCompoundPredicate
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [self->managedObjectContext executeFetchRequest:fetchRequest error:&error];
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

- (BOOL)saveChanges
{
    NSError *err = nil;
    BOOL successful = [self->managedObjectContext save:&err];
    if (!successful) {
        MWLogError(g_classObj, @"Error saving: %@", [err localizedDescription]);
    }
    return successful;
}

-(NSArray *) findAllCatalogs {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UGCCatalog"
                                              inManagedObjectContext:self->managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *allCatalogs = [self->managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (allCatalogs == nil) {
        MWLogError(g_classObj, @"Failure getting all catalogs:%@ in ", [error description]);
    }
    return allCatalogs;
}

-(id) insertObject:(LayUserModelObject)identifier {
    id domainObject = nil;
    switch (identifier) {
        case UGC_OBJECT_CATALOG: {
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"UGCCatalog"
                                                         inManagedObjectContext:self->managedObjectContext];
            UGCBox *box = [NSEntityDescription insertNewObjectForEntityForName:@"UGCBox"
                                                   inManagedObjectContext:self->managedObjectContext];
            UGCCase1 *case1 = [NSEntityDescription insertNewObjectForEntityForName:@"UGCCase1"
                                                   inManagedObjectContext:self->managedObjectContext];
            UGCCase2 *case2 = [NSEntityDescription insertNewObjectForEntityForName:@"UGCCase2"
                                                   inManagedObjectContext:self->managedObjectContext];
            UGCCase3 *case3 = [NSEntityDescription insertNewObjectForEntityForName:@"UGCCase3"
                                                   inManagedObjectContext:self->managedObjectContext];
            UGCCase4 *case4 = [NSEntityDescription insertNewObjectForEntityForName:@"UGCCase4"
                                                            inManagedObjectContext:self->managedObjectContext];
            UGCCase5 *case5 = [NSEntityDescription insertNewObjectForEntityForName:@"UGCCase5"
                                                            inManagedObjectContext:self->managedObjectContext];
            UGCStatistic *statistic = [NSEntityDescription insertNewObjectForEntityForName:@"UGCStatistic"
                                                                    inManagedObjectContext:self->managedObjectContext];
            box.case1Ref = case1;
            box.case2Ref = case2;
            box.case3Ref = case3;
            box.case4Ref = case4;
            box.case5Ref = case5;
            
            if(domainObject) {
                UGCCatalog *c = (UGCCatalog*)domainObject;
                c.boxRef = box;
                c.statisticRef = statistic;
            }
            
            break;
        }
        case UGC_OBJECT_QUESTION:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"UGCQuestion"
                                                         inManagedObjectContext:self->managedObjectContext];
            break;
        case UGC_OBJECT_EXPLANATION:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"UGCExplanation"
                                                         inManagedObjectContext:self->managedObjectContext];
            break;
        case UGC_OBJECT_RESOURCE:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"UGCResource"
                                                         inManagedObjectContext:self->managedObjectContext];
            break;
        case UGC_OBJECT_NOTE:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"UGCNote"
                                                         inManagedObjectContext:self->managedObjectContext];
            break;
        default:
            MWLogError(g_classObj, @"!!!! Identifier:%d has no mapping !!!!", identifier);
            ;            break;
    }
    return domainObject;
}

-(UGCQuestion*)findQuestionWithName:(NSString*)name in:(UGCCatalog *)catalog{
    UGCQuestion *question = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UGCQuestion"
                                              inManagedObjectContext:self->managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@ AND catalogRef = %@",
                              name, catalog];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [self->managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        MWLogError(g_classObj, @"Failure executing fetch:%@", [error description]);
    } else if([fetchedObjects count] > 1) {
        question = [fetchedObjects objectAtIndex:0];
        MWLogWarning(g_classObj, @"There are two questions with the same name:%@ in the store!", name);
    } else if([fetchedObjects count] == 1){
        question = [fetchedObjects objectAtIndex:0];
    }
    return question;
}

//
// Private
//
+ (void)initialize {
    g_classObj = [UGCCatalog class];
}

+ (LayUserDataStore*) initStore {
    LayUserDataStore *datastore = nil;
    if(![LayUserDataStoreConfiguration isValid]) {
        MWLogError(g_classObj, @"Failure setting up datastore! Configuration is invalid!");
        return datastore;
    }
    
    NSPersistentStoreCoordinator *storeCoordinator = [LayUserDataStoreConfiguration storeCoordinator];
    if(storeCoordinator) {
        datastore = [[LayUserDataStore alloc]initWithStoreCoordinator:storeCoordinator];
    } else {
        MWLogError(g_classObj, @"Failure setting up datastore!");
        datastore = nil;
    }
	
    return datastore;
}

-(id) initWithStoreCoordinator:(NSPersistentStoreCoordinator *) storeCoordinator {
    if(nil == g_classObj) g_classObj = [LayUserDataStore class];
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

-(id) init {
    NSPersistentStoreCoordinator *storeCoordinator = [LayUserDataStoreConfiguration storeCoordinator];
    return [self initWithStoreCoordinator:storeCoordinator];
}


@end
