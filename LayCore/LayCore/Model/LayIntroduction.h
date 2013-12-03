//
//  LayIntroduction.h
//  LayCore
//
//  Created by Rene Kollmorgen on 03.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LayIntroduction : NSObject

@property (nonatomic, readonly) NSString* title;
@property (nonatomic, readonly) NSArray* sectionList;

-(id)initWithTitle:(NSString*)title andSectionList:(NSArray*)sectionList;

@end
