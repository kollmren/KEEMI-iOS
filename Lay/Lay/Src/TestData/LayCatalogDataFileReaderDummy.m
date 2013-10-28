//
//  LayCatalogDataFileDummy.m
//  LayCore
//
//  Created by Rene Kollmorgen on 20.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayCatalogDataFileReaderDummy.h"

@interface LayCatalogDataFileReaderDummy() {
    id<LayDataFileDummy> dataDummyFile;
}
@end


@implementation LayCatalogDataFileReaderDummy

static Class _classObj = nil;

+(void)initialize {
    _classObj = [LayCatalogDataFileReaderDummy class];
}

-(id) initWithDataFileDummy:(id<LayDataFileDummy>)dataFileDummy_ {
    self = [super init];
    if(self) {
        self->dataDummyFile = dataFileDummy_;
    }
    return self;
}


-(BOOL) readCatalog:(Catalog *) catalog : (LayError**) error {
    
    [self->dataDummyFile data:catalog];
       
    return YES;
}

-(LayCatalogFileInfo*)metaInfo {
    LayCatalogFileInfo *fileMetaInfo = [LayCatalogFileInfo new];
    fileMetaInfo.catalogTitle = [self->dataDummyFile titleOfCatalog];
    NSString *publisher = [self->dataDummyFile nameOfPublisher];
    [fileMetaInfo setDetail:publisher forKey:@"publisher"];
    return fileMetaInfo;
}

@end
