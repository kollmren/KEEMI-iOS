//
//  LayCoreTestCatalogInfos.m
//  LayCore
//
//  Created by Rene Kollmorgen on 14.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayCoreTestCatalogInfoManager.h"

@implementation LayCoreTestCatalogInfoManager

+(LayCoreTestCatalogInfoManager*)instance {
    static LayCoreTestCatalogInfoManager* instance_ = nil;
    @synchronized(self)
    {
        if (instance_ == NULL) {
            instance_= [[self alloc] init];
        }
    }
    return(instance_);
}

-(LayCoreTestCatalogInfo*)infoForCatalog:(LayCoreInfoTestCatalogId)testCatalog {
    LayCoreTestCatalogInfo *catalogInfo = nil;
    switch (testCatalog) {
        case INFO_TEST_CATALOG_CITIZENSHIPTEST1:
            catalogInfo = [LayCoreTestCatalogInfo new];
            [self populateInfosForReferenceCatalog:catalogInfo];
            break;
            
        default:
            break;
    }
    return catalogInfo;
}

-(void)populateInfosForReferenceCatalog:(LayCoreTestCatalogInfo*)catalogInfo {
    catalogInfo.expectedNumberOfExplanations = 10;
    catalogInfo.nameOfFirstExplanation = @"deutscheWappen";
    catalogInfo.nameOfSecondExplanation = @"berlinerWappen";
    catalogInfo.nameOfThirdExplanation = @"bundeskanzler";
    // title
    catalogInfo.titleOfFirstExplanation = @"Wappen der Bundesrepublik Deutschland";
    catalogInfo.titleOfSecondExplanation = @"Wappen von Berlin";
    catalogInfo.titleOfThirdExplanation = @"Ehemalige Bundeskanzler";
}

@end

//
//
//
@implementation LayCoreTestCatalogInfo

@synthesize expectedNumberOfExplanations, nameOfFirstExplanation, nameOfSecondExplanation, nameOfThirdExplanation;
@synthesize titleOfFirstExplanation, titleOfSecondExplanation, titleOfThirdExplanation;

@end
