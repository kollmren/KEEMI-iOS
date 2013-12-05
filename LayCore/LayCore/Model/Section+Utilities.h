//
//  Section+Utilities.h
//  LayCore
//
//  Created by Rene Kollmorgen on 16.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Section.h"

#import "SectionText.h"
#import "SectionMedia.h"
#import "SectionQuestion.h"

@interface LaySectionMediaList : NSObject
@property (nonatomic) NSArray* mediaList;
@property (nonatomic) NSNumber* groupNumber;
@end

@interface LaySectionTextList : NSObject
@property (nonatomic) NSArray* textList;
@property (nonatomic) NSNumber* groupNumber;
@end


@interface Section (Utilities)

-(NSArray*)sectionGroupList;

-(SectionText*)sectionTextInstance;

-(SectionMedia*)sectionMediaInstance;

-(SectionQuestion*)sectionQuestionInstance;

-(NSNumber*)newGroupNumber;

@end
