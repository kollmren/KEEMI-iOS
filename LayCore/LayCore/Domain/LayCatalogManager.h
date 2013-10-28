//
//  LayCatalogManager.h
//  LayCore
//
//  Created by Rene Kollmorgen on 22.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"

@interface LayCatalogManager : NSObject

@property (nonatomic) Catalog* currentSelectedCatalog;
@property (nonatomic) Question* currentSelectedQuestion;
@property (nonatomic) NSArray* selectedQuestions;
@property (nonatomic) NSArray* selectedExplanations;
@property (nonatomic) BOOL currentCatalogIsUsedInQuestionSession;
@property (nonatomic) BOOL currentCatalogShouldBeOpenedDirectly;
@property (nonatomic) BOOL currentCatalogShouldBeQueriedDirectly;
@property (nonatomic) BOOL currentCatalogShouldBeLearnedDirectly;
@property (nonatomic) BOOL pendingCatalogToImport;

+(LayCatalogManager*) instance;

+(void)deleteFile:(NSURL*)url;

+(void)cleanupInboxAndTmpDir;

+(void)cleanupTmpDir;

-(void)resetAllProperties;

-(void)cleanupTmpDir;

-(void)deleteFile:(NSURL*)url;

@end
