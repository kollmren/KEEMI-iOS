//
//  LayErrorDomains.h
//  LayCore
//
//  Created by Rene Kollmorgen on 20.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum LayErrorIdentifier_ {
    LayInternalError = 0,
    // Datastore
    LayDatastoreConfigFilesError,
    LayDatastoreInitError,
    // Import
    LayImportCatalogAlreadyInStoreError = 10,
    LayImportCatalogParsingError,
    LayImportCatalogResourceError, // missing images etc.
    LayImportInternalError
    // Domain
} LayErrorIdentifier;


@interface LayError : NSObject

@property(nonatomic, readonly) NSString* details;

+(LayError*) withIdentifier:(LayErrorIdentifier)identifier_ andMessage:(NSString*)errorMessage;

-(id) initWithIdentifier:(LayErrorIdentifier)identifier_ andMessage:(NSString*)errorMessage;

-(void)addErrorWithIdentifier:(LayErrorIdentifier)errorIdentifier andMessage:(NSString*)errorMessage;

-(NSArray*)listOfErrorIdentifiers;

-(NSArray*)errorMessagesForErrorIdentifier:(LayErrorIdentifier)errorIdentifier;

-(void)addError:(LayError*)error;

-(BOOL)hasError:(LayErrorIdentifier)idenifier;

@end
