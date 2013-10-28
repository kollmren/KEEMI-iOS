//
//  LayManagedObjectContext.m
//  LayCore
//
//  Created by Rene Kollmorgen on 14.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayImportDataStore.h"
#import "LayDataStoreConfiguration.h"
#import "LayMainDataStore.h"
#import "LayDataStoreUtilities.h"
#import "MWLogging.h"

#import "Media+Utilities.h"

#import "Catalog+Utilities.h"


// globals
static Class g_classObj = nil;

@implementation LayImportDataStore

//
// Public
//

+ (LayImportDataStore*) store {
    static LayImportDataStore* importStore = nil;
    if (importStore == nil) {
        importStore = [LayImportDataStore initStore];
        if(importStore) {
            MWLogInfo(g_classObj, @"Setup import store successfully.");
            
        } else {
            MWLogError(g_classObj, @"Failure setting up main datastore!");
            importStore = nil;
        }
        
    }
    return importStore;
}

- (BOOL)saveChanges
{
    NSError *err = nil;
    BOOL successful = [self->managedObjectContext save:&err];
    if (!successful) {
        NSMutableString *errorMessage = [NSMutableString stringWithCapacity:200];
        NSDictionary *userInfo = [err userInfo];
        for (NSString *key in userInfo) {
            NSString *value = [userInfo objectForKey:key];
            NSString *message = [NSString stringWithFormat:@"%@:%@; ", key, value];
            [errorMessage appendString:message];
        }
        MWLogError(g_classObj, @"Error saving: %@", errorMessage);
    }
    
    return successful;
}

-(void)clearStore {
    // clear the context
    [self->managedObjectContext reset];
}

-(Catalog *)catalogToImportInstance {
    Catalog *catalog = [LayDataStoreUtilities insertDomainObject:LayCatalog :self->managedObjectContext];;
    return catalog;
}

/*-(NSManagedObjectContext*) managedContext {
    return self->managedObjectContext;
}*/

//
// Private
//

+ (void)initialize {
    g_classObj = [LayImportDataStore class];
}

+ (LayImportDataStore*) initStore {
    LayImportDataStore *datastore = nil;
    if(![LayDataStoreConfiguration isValid]) {
        MWLogError(g_classObj, @"Failure setting up datastore! Configuration is invalid!");
        return datastore;
    }
    
    NSPersistentStoreCoordinator *storeCoordinator = [LayDataStoreConfiguration storeCoordinator];
    if(storeCoordinator) {
        datastore = [[LayImportDataStore alloc]initWithStoreCoordinator:storeCoordinator];
    } else {
        MWLogError(g_classObj, @"Failure setting up datastore!");
        datastore = nil;
    }
	
    return datastore;
}

-(id) initWithStoreCoordinator:(NSPersistentStoreCoordinator *) storeCoordinator {
    if(nil == g_classObj) g_classObj = [LayImportDataStore class];
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
    return [LayImportDataStore initStore];
}


@end
