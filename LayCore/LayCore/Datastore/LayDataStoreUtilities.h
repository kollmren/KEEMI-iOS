//
//  LayDataStoreUtilities.h
//  LayCore
//
//  Created by Rene Kollmorgen on 06.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LayModelObject.h"

#import "LayImportProgressDelegate.h"

@class Media;
@class Explanation;
@class Catalog;
@class Thumbnail;
@interface LayDataStoreUtilities : NSObject

+(id) insertDomainObject:(LayModelObject)identifier : (NSManagedObjectContext *) managedObjectContext;

+(Media *)findMediaInCatalog:(Catalog*)catalog
                      byName:(NSString*)nameOfMedia
                   inContext:(NSManagedObjectContext*)managedObjectContext;

+(NSUInteger)createThumbnailsForImagesInCatalog:(Catalog*)catalog withStateDelegate:(id<LayImportProgressDelegate>)stateDelegate;

+(Thumbnail *)findThumbnailInCatalog:(Catalog*)catalog
                              byName:(NSString*)nameOfThumbnail
                           inContext:(NSManagedObjectContext*)managedObjectContext;

@end
