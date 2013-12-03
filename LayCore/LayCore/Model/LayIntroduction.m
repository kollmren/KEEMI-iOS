//
//  LayIntroduction.m
//  LayCore
//
//  Created by Rene Kollmorgen on 03.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayIntroduction.h"

@implementation LayIntroduction

@synthesize title, sectionList;

-(id)initWithTitle:(NSString*)title_ andSectionList:(NSArray*)sectionList_ {
    self = [super init];
    if(self) {
        title = title_;
        sectionList = sectionList_;
    }
    
    return self;
}

@end
