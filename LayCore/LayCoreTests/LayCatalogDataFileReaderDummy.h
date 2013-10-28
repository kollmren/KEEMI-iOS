//
//  LayCatalogDataFileDummy.h
//  LayCore
//
//  Created by Rene Kollmorgen on 20.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LayCatalogFileReader.h"

#import "LayDataFileDummy.h"

@interface LayCatalogDataFileReaderDummy : NSObject<LayCatalogFileReader> 

-(id) initWithDataFileDummy:(id<LayDataFileDummy>)dataFileDummy;

@end
