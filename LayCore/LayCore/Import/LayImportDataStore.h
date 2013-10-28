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
@interface LayImportDataStore : NSObject {
    @private
    NSManagedObjectContext *managedObjectContext;
}

+ (LayImportDataStore*)store;

-(Catalog *)catalogToImportInstance;

-(BOOL)saveChanges;

-(void)clearStore;

//-(NSManagedObjectContext*) managedContext;

@end
