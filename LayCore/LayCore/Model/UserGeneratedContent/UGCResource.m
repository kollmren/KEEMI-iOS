//
//  UGCResource.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 09.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "UGCResource.h"
#import "UGCCatalog.h"
#import "UGCExplanation.h"
#import "UGCQuestion.h"


@implementation UGCResource

@dynamic link;
@dynamic title;
@dynamic type;
@dynamic created;
@dynamic catalogRef;
@dynamic questionRef;
@dynamic explanationRef;
@dynamic isbn;
@dynamic text;

-(void)awakeFromInsert {
    [super awakeFromInsert];
    self.created = [NSDate date];
}

@end
