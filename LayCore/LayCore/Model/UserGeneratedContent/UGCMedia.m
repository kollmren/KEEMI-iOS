//
//  UGCMedia.m
//  LayCore
//
//  Created by Rene Kollmorgen on 28.10.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "UGCMedia.h"
#import "UGCNote.h"


@implementation UGCMedia

@dynamic name;
@dynamic data;
@dynamic thumbnail;
@dynamic type;
@dynamic noteRef;
@dynamic created;

-(void)awakeFromInsert {
    [super awakeFromInsert];
    self.created = [NSDate date];
}

@end
