//
//  LayCatalogImportReport.h
//  LayCore
//
//  Created by Rene Kollmorgen on 20.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

enum LayCatalogImportType {
    NEW,
    UPDATE
};

@class LayError;
@class Catalog;
@interface LayCatalogImportReport : NSObject

-(id) init;

@property(nonatomic) BOOL imported;

@property(nonatomic) enum LayCatalogImportType type;

@property(nonatomic) NSString* titleOfCatalog;

@property(nonatomic) int numberOfQuestions;

@property(nonatomic) LayError* error;

@property(nonatomic) Catalog* importedCatalog;

@end
