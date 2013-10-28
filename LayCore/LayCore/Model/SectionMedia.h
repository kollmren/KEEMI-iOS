//
//  SectionMedia.h
//  LayCore
//
//  Created by Rene Kollmorgen on 16.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Media, Section;

@interface SectionMedia : NSManagedObject

@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) Section *sectionRef;
@property (nonatomic, retain) Media *mediaRef;
@property (nonatomic, retain) NSNumber * groupNumber;

@end



