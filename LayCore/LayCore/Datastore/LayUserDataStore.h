//
//  LayCore
//
//  Created by Rene Kollmorgen on 14.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LayModelObject.h"

typedef enum LayUserModelObject_ {
    UGC_OBJECT_CATALOG,
    UGC_OBJECT_QUESTION,
    UGC_OBJECT_EXPLANATION,
    UGC_OBJECT_RESOURCE,
    UGC_OBJECT_NOTE
} LayUserModelObject;


@class UGCCatalog;
@class UGCQuestion;
@interface LayUserDataStore : NSObject {
    @public
    NSManagedObjectContext *managedObjectContext;
}

+ (LayUserDataStore*) store;

-(BOOL) deleteAllCatalogsFromStore;

-(UGCCatalog*)findCatalogByTitle:(NSString*)titleOfCatalog andPublisher:(NSString*)nameOfPublisher;

-(UGCQuestion*)findQuestionWithName:(NSString*)name in:(UGCCatalog*)catalog;

-(id) insertObject:(LayUserModelObject)identifier;

- (BOOL)saveChanges;

@end
