//
//  LayCatalogImport.m
//  LayCore
//
//  Created by Rene Kollmorgen on 19.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayCatalogImport.h"
#import "LayCatalogImportReport.h"
#import "LayImportDataStore.h"
#import "LayMainDataStore.h"
#import "LayDataStoreUtilities.h"
#import "LayUserDataStore.h"
#import "LayError.h"
#import "Catalog+Utilities.h"
#import "UGCCatalog+Utilities.h"
#import "MWLogging.h"


const NSInteger LayCatalogImportProgressPartIdentifierImport = 101;
const NSInteger LayCatalogImportProgressPartIdentifierCreatingThumbnails = 102;

@implementation LayCatalogImport

static Class _classObj = nil;

+(void) initialize {
    _classObj = [LayCatalogImport class];
}

-(id) init {
    MWLogError(_classObj, @"The designated initializer from NSObject is not supported!");
    return nil;
}

-(void)dealloc {
    MWLogDebug(_classObj, @"dealloc");
}


-(id) initWithDataFileReader:(id<LayCatalogFileReader>) dataFile_ {
    if(nil == _classObj) _classObj = [LayCatalogImport class];
    if(nil == dataFile_) {
         MWLogError(_classObj, @"Invalid parameter dataFile!");
        return nil;
    }
    
    if (!(self = [super init]))
    {
        MWLogError(_classObj, @"super init failed!");
        return nil;
    }
    self->dataFileReader = dataFile_;
    return self;
}

-(LayCatalogImportReport*) import {
    return [self importWithStateDelegate:nil];
}

-(LayCatalogImportReport*) importWithStateDelegate:(id<LayImportProgressDelegate>)stateDelegate {
    LayCatalogImportReport *report = [[LayCatalogImportReport alloc]init];
    LayImportDataStore *datastore = [LayImportDataStore store];
    if(nil == datastore) {
        MWLogError(_classObj, @"Datastore is not setup!");
        report.error = [LayError withIdentifier:LayDatastoreInitError andMessage:@"Datastore is not setup!"];
        return report;
    }
    LayCatalogFileInfo *fileMetaInfo = [self->dataFileReader metaInfo];
    NSURL* fileUrl = fileMetaInfo.url;
    MWLogInfo(_classObj, @"Import catalog from file:%@", fileUrl );
    Catalog *importedCatalog = nil;
    if([fileMetaInfo isAnUpdate]) {
        [report setType:UPDATE];
        // TODO
    } else {
        [report setType:NEW];
        NSString *catalogTitle = [fileMetaInfo catalogTitle];
        MWLogInfo(_classObj, @"Try to import new catalog:%@.", catalogTitle );
        importedCatalog = [self importNewCatalog:report andImportStateDelegate:stateDelegate];
        if(importedCatalog) {
            MWLogInfo(_classObj, @"Imported catalog:%@ successfully.", catalogTitle );
        } else {
            MWLogError(_classObj, @"Could not import catalog:%@.", catalogTitle );
        }
    }
    
    if(importedCatalog) {
        report.imported = YES;
    } else {
        report.imported = NO;
    }
    
    return report;
}

-(Catalog*) importNewCatalog:(LayCatalogImportReport *)report andImportStateDelegate:(id<LayImportProgressDelegate>)stateDelegate {
    Catalog *importCatalog = nil;
    LayImportDataStore *importStore = [LayImportDataStore store];
    LayCatalogFileInfo *fileMetaInfo = [self->dataFileReader metaInfo];
    NSString *titleOfCatalog = [fileMetaInfo catalogTitle];
    NSString *nameOfPubsliher = [fileMetaInfo detailForKey:@"publisher"];
    LayMainDataStore *mainStore = [LayMainDataStore store];
    BOOL catalogFoundInMainStore = [mainStore catalogExistsWith:titleOfCatalog and:nameOfPubsliher];
    BOOL imported = NO;
    if(!catalogFoundInMainStore) {
        importCatalog = [importStore catalogToImportInstance];
        // Save the catalog at this point soon to get a permanent ID, the ID is used by Media objects to save Media
        // in the domain of the catalog uniquely.
        importCatalog.title = @"import catalog ...";
        imported = [importStore saveChanges];
        BOOL catalogHasTemporaryID = [[importCatalog objectID] isTemporaryID];
        if(imported && !catalogHasTemporaryID) {
            LayError *error = nil;
            imported = [self->dataFileReader readCatalog:importCatalog : &error andImportStateDelegate:stateDelegate];
            if(imported) {
                [self syncWithUserDataStore:importCatalog];
                imported = [importStore saveChanges];
                if(!imported) {
                    [self deleteTemporarySavedCatalog:importCatalog];
                } else {
                    // Create thumbnails
                    MWLogInfo(_classObj,@"Create thumbnails for catalog.");
                    if(stateDelegate) {
                        [stateDelegate startingNextProgressPartWithIdentifier:LayCatalogImportProgressPartIdentifierCreatingThumbnails];
                    }
                    NSUInteger numberOfCreatedThumbnails = [LayDataStoreUtilities createThumbnailsForImagesInCatalog:importCatalog withStateDelegate:stateDelegate];
                    if(numberOfCreatedThumbnails > 0) {
                        imported = [importStore saveChanges];
                        if(imported) {
                             MWLogInfo(_classObj, @"Saved created thumbnails!", titleOfCatalog);
                        } else {
                            [self deleteTemporarySavedCatalog:importCatalog];
                            MWLogError(_classObj, @"Could not save created thumbnails!", titleOfCatalog);
                        }
                    }
                }
            } else {
                MWLogError(_classObj,@"Error importing new catalog! Details:%@", error.details );
                report.error = error;
                [self deleteTemporarySavedCatalog:importCatalog];
            }
        } else {
            MWLogError(_classObj,@"Error saving new catalog!");
            [self deleteTemporarySavedCatalog:importCatalog];
        }
        
    } else {
        NSString *message = [NSString stringWithFormat:@"Catalog with title:%@ and publisher:%@ already stored!", titleOfCatalog, nameOfPubsliher];
        MWLogError(_classObj, message);
        report.error = [LayError withIdentifier:LayImportCatalogAlreadyInStoreError andMessage:message];
    }
    
    Catalog *catalogInMainStore = nil;
    if(importCatalog && imported) {
        catalogInMainStore = [mainStore findCatalogByTitle:titleOfCatalog andPublisher:nameOfPubsliher];
        if(!catalogInMainStore) {
            NSString *message = [NSString stringWithFormat:@"Upps! The catalog with title:%@ and publisher:%@ should be currently imported?!", titleOfCatalog, nameOfPubsliher];
            MWLogError(_classObj,message);
             report.error = [LayError withIdentifier:LayImportInternalError andMessage:message];
            catalogInMainStore = nil;
            [importStore clearStore];
        } else {
            report.importedCatalog = catalogInMainStore;
        }
    }
    
    [importStore clearStore];
    
    return catalogInMainStore;
}

-(void)deleteTemporarySavedCatalog:(Catalog*)catalog {
    MWLogDebug(_classObj,@"Delete temporary saved catalog!");
    BOOL deleted = [catalog deleteCatalog];
    if(!deleted) {
        MWLogError(_classObj,@"Could not delete temporary catalog!");
    } else {
        MWLogDebug(_classObj,@"Deleted temporary saved catalog!");
    }
}

-(void)syncWithUserDataStore:(Catalog*)catalog {
    NSString *titleOfCatalog = catalog.title;
    NSString *nameOfPublisher = [catalog publisher];
    LayUserDataStore *uStore = [LayUserDataStore store];
    UGCCatalog *uCatalog = [uStore findCatalogByTitle:titleOfCatalog andPublisher:nameOfPublisher];
    if(uCatalog) {
        MWLogInfo(_classObj, @"Sync user-data for catalog with title:%@", titleOfCatalog);
        [uCatalog syncUserQuestionState:[catalog questionListSortedByNumber]];
    }
}

@end
