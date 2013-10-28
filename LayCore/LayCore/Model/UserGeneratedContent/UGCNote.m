//
//  UGCNote.m
//  LayCore
//
//  Created by Rene Kollmorgen on 14.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "UGCNote.h"
#import "UGCCatalog.h"
#import "UGCExplanation.h"
#import "UGCQuestion.h"


@implementation UGCNote

@dynamic text;
@dynamic image;
@dynamic thumbnail;
@dynamic created;
@dynamic questionRef;
@dynamic catalogRef;
@dynamic explanationRef;
@dynamic createdFrom;
@dynamic hashString;
@dynamic mediaRef;
@dynamic name;

-(void)awakeFromInsert {
    [super awakeFromInsert];
    self.created = [NSDate date];
}

@end
