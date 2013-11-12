//
//  LayDataStoreConfiguration.m
//  LayCore
//
//  Created by Rene Kollmorgen on 27.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayUserDataStoreConfiguration.h"
#import "LayError.h"
#import "MWLogging.h"


static NSPersistentStoreCoordinator *g_persistentStoreCoordinator = nil;
static NSManagedObjectModel *g_managedObjectModel = nil;
static NSURL* g_urlToDataStoreFile = nil;
static NSURL* g_urlToDataStoreModel = nil;
static BOOL g_isvalid = NO;

static Class g_classObj = nil;

@implementation LayUserDataStoreConfiguration

+(void) initialize {
    g_classObj = [LayUserDataStoreConfiguration class];
}


+(BOOL) configure:(NSURL*)urlToDataStoreFile andUrlToModel:(NSURL*) urlToDataStoreModel : (LayError**) error {
    if(g_isvalid) {
        MWLogDebug(g_classObj, @"Configuring the datastore several times is not allowed! Call with %@, %@ is ignored!",
                   urlToDataStoreFile, urlToDataStoreModel);
        return NO;
    }
    
    MWLogDebug(g_classObj, @"Configure datastore with:%@, %@", urlToDataStoreFile, urlToDataStoreModel);
    if(urlToDataStoreFile == nil || urlToDataStoreModel == nil) {
        NSString *message =  @"Invalid arguments! At least one parameter is nil!";
        MWLogError(g_classObj, message);
        *error = [[LayError alloc] initWithIdentifier:LayDatastoreConfigFilesError andMessage:message];
        return g_isvalid;
    }
    
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    if(![fileMngr fileExistsAtPath:[urlToDataStoreModel path]]) {
        NSString *message = [NSString stringWithFormat:@"File to model:%@ does not exist!", [urlToDataStoreModel path]];
        MWLogError(g_classObj, message );
        *error = [[LayError alloc] initWithIdentifier:LayDatastoreConfigFilesError andMessage:message];
    } else {
        g_isvalid = YES;
        g_urlToDataStoreFile = urlToDataStoreFile;
        g_urlToDataStoreModel = urlToDataStoreModel;
    }

    if(g_isvalid) g_isvalid = [self setupStoreCoordniator];
    
    return g_isvalid;
}

+(NSURL*) urlToDatastoreFile {
    return g_urlToDataStoreFile;
}

+(NSURL*) urlToDatastoreModel {
    return g_urlToDataStoreModel;
}

+(NSPersistentStoreCoordinator*) storeCoordinator {
    return g_persistentStoreCoordinator;
}

+(BOOL)isValid {
    return g_isvalid;
}

//
// Private
//

+(BOOL) setupStoreCoordniator {
    BOOL retVal = NO;
    if(nil == g_managedObjectModel) {
        g_managedObjectModel = [[NSManagedObjectModel alloc]initWithContentsOfURL:g_urlToDataStoreModel];
        if(nil == g_managedObjectModel) {
            MWLogError(g_classObj, @"Cant instantiate NSManagedObjectModel with model file:%@ !", g_urlToDataStoreModel );
        }
    }
    
    if(g_managedObjectModel) {
        g_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: g_managedObjectModel];
        if(nil != g_persistentStoreCoordinator) {
            NSError *error = nil;
            NSPersistentStore *store =
            [g_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:g_urlToDataStoreFile options:nil error:&error];
            if (nil == store) {
                MWLogError(g_classObj, @"Could not add persistent store! Error is:%@", [error description]);
            } else {
                retVal = YES;
            }
        } else {
            MWLogError(g_classObj, @"Cant instantiate NSPersistentStoreCoordinator!");
        }
    }
    return retVal;
}

@end
