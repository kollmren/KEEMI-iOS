//
//  UGCExplanationTextMarker.h
//  LayCore
//
//  Created by Rene Kollmorgen on 28.10.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UGCExplanation;

@interface UGCExplanationTextMarker : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * colorRGB;
@property (nonatomic, retain) NSNumber * markStart;
@property (nonatomic, retain) NSNumber * markEnd;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) UGCExplanation *explanationRef;

@end
