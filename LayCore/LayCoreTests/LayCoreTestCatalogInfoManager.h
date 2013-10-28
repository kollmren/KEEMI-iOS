//
//  LayCoreTestCatalogInfos.h
//  LayCore
//
//  Created by Rene Kollmorgen on 14.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum LayCoreInfoTestCatalogId_ {
    INFO_TEST_CATALOG_CITIZENSHIPTEST1
} LayCoreInfoTestCatalogId;

//
//
//
@interface LayCoreTestCatalogInfo : NSObject
// Explanations
@property (nonatomic) NSUInteger expectedNumberOfExplanations;
@property (nonatomic) NSString *nameOfFirstExplanation;
@property (nonatomic) NSString *nameOfSecondExplanation;
@property (nonatomic) NSString *nameOfThirdExplanation;

@property (nonatomic) NSString *titleOfFirstExplanation;
@property (nonatomic) NSString *titleOfSecondExplanation;
@property (nonatomic) NSString *titleOfThirdExplanation;

@end

//
//
//
@interface LayCoreTestCatalogInfoManager : NSObject

+(LayCoreTestCatalogInfoManager*)instance;

-(LayCoreTestCatalogInfo*)infoForCatalog:(LayCoreInfoTestCatalogId)testCatalog;

@end
