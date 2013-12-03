//
//  SectionQuestion.h
//  LayCore
//
//  Created by Rene Kollmorgen on 03.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Question, Section;

@interface SectionQuestion : NSManagedObject

@property (nonatomic, retain) NSNumber * groupNumber;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Question *questionRef;
@property (nonatomic, retain) Section *sectionRef;

@end
