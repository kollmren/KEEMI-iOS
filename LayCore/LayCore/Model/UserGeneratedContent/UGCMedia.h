//
//  UGCMedia.h
//  LayCore
//
//  Created by Rene Kollmorgen on 28.10.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UGCNote;

@interface UGCMedia : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) UGCNote *noteRef;
@property (nonatomic, retain) NSDate * created;


@end
