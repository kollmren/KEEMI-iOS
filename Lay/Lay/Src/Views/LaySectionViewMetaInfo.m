//
//  LaySectionViewMetaInfo.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 02.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LaySectionViewMetaInfo.h"
#import "LayTableSectionView.h"

@implementation LaySectionViewMetaInfo

@synthesize sectionView, sectionInxdexInTable, numberOfRowsInSection, title;

+(LaySectionViewMetaInfo*)viewMetaInfo:(LayTableSectionView*)view index:(NSUInteger)index rows:(NSUInteger)rows title:(NSString*)title {
    LaySectionViewMetaInfo *viewMetaInfo = [LaySectionViewMetaInfo new];
    viewMetaInfo.sectionView = view;
    viewMetaInfo.sectionInxdexInTable = index;
    viewMetaInfo.title = title;
    viewMetaInfo.numberOfRowsInSection = rows;
    return viewMetaInfo;
}

-(void)setNumberOfRowsInSection:(NSUInteger)numberOfRowsInSection_ {
    numberOfRowsInSection = numberOfRowsInSection_;
    if(self.sectionView) {
        static NSString *labelWithNumberOfRows = @"%@ (%u)";
        NSString *titleWithRowNumber = [NSString stringWithFormat:labelWithNumberOfRows, self.title,numberOfRowsInSection];
        self.sectionView.title= titleWithRowNumber;
    }
}

@end
