//
//  Catalog.m
//  LayCore
//
//  Created by Rene Kollmorgen on 17.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Catalog.h"
#import "Author.h"
#import "Explanation.h"
#import "Media.h"
#import "Publisher.h"
#import "Question.h"
#import "Resource.h"
#import "Topic.h"


@implementation Catalog

@dynamic catalogDescription;
@dynamic format;
@dynamic title;
@dynamic version;
@dynamic authorRef;
@dynamic coverRef;
@dynamic explanationRef;
@dynamic publisherRef;
@dynamic questionRef;
@dynamic topicRef;
@dynamic resourceRef;
@dynamic language;
@dynamic topic;
@dynamic source;
@dynamic aboutRef;
@dynamic imported;

-(void)awakeFromInsert {
    [super awakeFromInsert];
    self.imported = [NSDate date];
}

@end
