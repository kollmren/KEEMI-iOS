//
//  LaySectionViewMetaInfo.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 02.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LayTableSectionView;
@interface LaySectionViewMetaInfo : NSObject

@property (nonatomic) LayTableSectionView *sectionView;
@property (nonatomic) NSUInteger sectionInxdexInTable;
@property (nonatomic) NSString* title;
@property (nonatomic) NSUInteger numberOfRowsInSection;

+(LaySectionViewMetaInfo*)viewMetaInfo:(LayTableSectionView*)view index:(NSUInteger)index rows:(NSUInteger)rows title:(NSString*)title;

@end