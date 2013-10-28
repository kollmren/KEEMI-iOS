//
//  UGCStatistic.h
//  LayCore
//
//  Created by Rene Kollmorgen on 25.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UGCStatistic : NSManagedObject

@property (nonatomic, retain) NSNumber * wrong;
@property (nonatomic, retain) NSNumber * correct;
@property (nonatomic, retain) NSManagedObject *catalogRef;

@end
