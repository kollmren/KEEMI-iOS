//
//  UGCBox.h
//  LayCore
//
//  Created by Rene Kollmorgen on 01.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UGCCase1, UGCCase2, UGCCase3, UGCCase4, UGCCase5, UGCCatalog;

@interface UGCBox : NSManagedObject

@property (nonatomic, retain) NSNumber * numberOfQuestions;
@property (nonatomic, retain) UGCCase1 *case1Ref;
@property (nonatomic, retain) UGCCase2 *case2Ref;
@property (nonatomic, retain) UGCCase3 *case3Ref;
@property (nonatomic, retain) UGCCatalog *catalogRef;
@property (nonatomic, retain) UGCCase4 *case4Ref;
@property (nonatomic, retain) UGCCase5 *case5Ref;

@end
