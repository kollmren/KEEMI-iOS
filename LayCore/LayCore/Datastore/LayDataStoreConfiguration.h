//
//  LayDataStoreConfiguration.h
//  LayCore
//
//  Created by Rene Kollmorgen on 27.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LayError;
@class LayMainDataStore;

@interface LayDataStoreConfiguration : NSObject

+(BOOL) configure:(NSURL*)urlToDataStoreFile andUrlToModel:(NSURL*) urlToDataStoreModel : (LayError**) error;

+(NSURL*) urlToDatastoreFile;

+(NSURL*) urlToDatastoreModel;

+(NSPersistentStoreCoordinator*) storeCoordinator;

+(BOOL)isValid;

+(void)cleanupDataStore;

@end
