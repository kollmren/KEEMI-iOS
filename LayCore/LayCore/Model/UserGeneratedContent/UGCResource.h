//
//  UGCResource.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 09.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UGCCatalog, UGCExplanation, UGCQuestion;

@interface UGCResource : NSManagedObject

@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) UGCCatalog *catalogRef;
@property (nonatomic, retain) NSSet *questionRef;
@property (nonatomic, retain) NSSet *explanationRef;
@property (nonatomic, retain) NSString * isbn;
@property (nonatomic, retain) NSString * text;

@end
