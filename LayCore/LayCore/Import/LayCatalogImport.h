//
//  LayCatalogImport.h
//  LayCore
//
//  Created by Rene Kollmorgen on 19.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LayCatalogFileReader.h"
#import "LayImportProgressDelegate.h"

extern const NSInteger LayCatalogImportProgressPartIdentifierImport;
extern const NSInteger LayCatalogImportProgressPartIdentifierCreatingThumbnails;

@class LayCatalogImportReport;
@interface LayCatalogImport : NSObject {
    @private
    id<LayCatalogFileReader> dataFileReader;
}

-(id) initWithDataFileReader:(id<LayCatalogFileReader>) dataFile;

// Returns nil if an error occurres.
-(LayCatalogImportReport*) import;

-(LayCatalogImportReport*) importWithStateDelegate:(id<LayImportProgressDelegate>)stateDelegate;

@end
