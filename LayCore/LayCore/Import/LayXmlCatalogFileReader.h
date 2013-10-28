//
//  LayZipDataFileReader.h
//  
//
//  Created by Rene Kollmorgen on 05.05.13.
//
//

#import <Foundation/Foundation.h>

#import "LayCatalogFileReader.h"
#import "LayImportProgressDelegate.h"

extern const NSString* const LAY_CATALOG_PACKAGE_EXTENSTION;

@interface LayXmlCatalogFileReader : NSObject<LayCatalogFileReader>

// Returns the URL to the unzipped catalog-directory
+(NSURL*)unzipCatalog:(NSURL*)catalogFileZipped;

+(NSURL*)unzipCatalog:(NSURL*)catalogFileZipped andStateDelegate:(id<LayImportProgressDelegate>)stateDelegate;

+(NSString*)getNameOfCatalogFile:(NSURL*)catalogDirectoryUnzipped;

//
-(id)initWithXmlFile:(NSURL*)catalogFile;

-(id)initWithXmlFileNotReadinCatalogInfo:(NSURL*)catalogFile;

-(id)initWithZippedFile:(NSURL*)catalogFileZipped;

-(BOOL)readMetaInfoWithStateDelegate:(id<LayImportProgressDelegate>)stateDelegate;

-(LayCatalogFileInfo*)metaInfo;


@end
