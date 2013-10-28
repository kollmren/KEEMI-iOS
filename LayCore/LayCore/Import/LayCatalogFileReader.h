//
//  LayCatalogDataFile.h
//  LayCore
//
//  Created by Rene Kollmorgen on 20.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LayMediaTypes.h"
#import "LayXmlNode.h"
#import "LayImportProgressDelegate.h"

@interface LayCatalogDetail : NSObject
@property (nonatomic) NSString* value;
@property (nonatomic) NSString* label; // translated label
@end
//
// LayCatalogFileInfo
//
@class LayError;
@interface LayCatalogFileInfo : NSObject

@property (nonatomic) NSURL* url;
@property (nonatomic) NSString* nameOfFile;
@property (nonatomic) BOOL isAnUpdate;

@property (nonatomic) NSString* catalogTitle;
@property (nonatomic) NSString* catalogDescription;
@property (nonatomic) NSString* catalogInstrcution;
@property (nonatomic) NSData* cover;
@property (nonatomic) LayMediaType coverMediaType;
@property (nonatomic) LayMediaFormat coverMediaFormat;
@property (nonatomic) LayXmlNode *aboutNode;

@property (nonatomic) NSString* format;

// keys:author, publisher, numberOfQuestions, language, version, topic
-(NSString*)detailForKey:(NSString*)key;
-(void)setDetail:(NSString*)value forKey:(NSString*)key;
-(NSString*)detailLabelForKey:(NSString*)key;
-(NSArray*)allDetailKeys;
-(NSArray*)labelDataList;
-(void)removeDetailWithKey:(NSString*)key;

@end

//
// LayCatalogDataFileReader
//
@class LayError;
@class Catalog;
@protocol LayCatalogFileReader <NSObject>

@required

// Informations like the title, file url, version are accessed before readinf the entire catalog
-(LayCatalogFileInfo*)metaInfo;

// The catalog is alreay instantiated and must be used to created the other entities
-(BOOL) readCatalog:(Catalog *)catalog :(LayError**) error;

-(LayError*)readError;

@optional

-(BOOL)readMetaInfoWithStateDelegate:(id<LayImportProgressDelegate>)stateDelegate;

-(BOOL) readCatalog:(Catalog *)catalog :(LayError**) error andImportStateDelegate:(id<LayImportProgressDelegate>)stateDelegate;

@end
