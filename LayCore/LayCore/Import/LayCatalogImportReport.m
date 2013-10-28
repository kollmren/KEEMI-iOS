//
//  LayCatalogImportReport.m
//  LayCore
//
//  Created by Rene Kollmorgen on 20.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayCatalogImportReport.h"
#import "MWLogging.h"

@implementation LayCatalogImportReport

@synthesize imported;
@synthesize type;
@synthesize titleOfCatalog, importedCatalog;
@synthesize numberOfQuestions;
@synthesize error;

static Class _classObj = nil;

-(id) init {
    if(nil == _classObj) _classObj = [LayCatalogImportReport class];
    
    if (!(self = [super init]))
    {
        MWLogError(_classObj, @"super init failed!");
        return nil;
    }
    
    self.imported = NO;
    
    return self;
}

@end
