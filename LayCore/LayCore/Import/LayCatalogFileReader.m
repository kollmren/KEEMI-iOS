//
//  LayCatalogDataFile.h
//  LayCore
//
//  Created by Rene Kollmorgen on 20.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayCatalogFileReader.h"
#import "LayPair.h"

#import "MWLogging.h"

@interface LayCatalogFileInfo() {
    NSMutableDictionary *details;
    NSMutableArray *allowedKeyList;
}
@end

@implementation LayCatalogFileInfo

@synthesize url, nameOfFile, isAnUpdate,
catalogTitle, catalogDescription, catalogInstrcution, cover, coverMediaFormat, coverMediaType, aboutNode;

-(id)init {
    self = [super init];
    if(self) {
        [self initDetails];
    }
    return self;
}

// keys:author, publisher, numberOfQuestions, language, version, topic
-(NSString*)detailForKey:(NSString*)key {
    LayCatalogDetail *detail = [self->details objectForKey:key];
    return detail.value;
}

-(void)setDetail:(NSString*)value forKey:(NSString*)key {
    if( value.length > 0) {
        LayCatalogDetail *detail = [self->details objectForKey:key];
        if(detail) {
            detail.value = value;
        }
    } else {
        MWLogDebug([LayCatalogFileInfo class], @"Ignore value setting for key:%@, value is empty!", key );
    }
}

-(void)removeDetailWithKey:(NSString*)key {
    [self->details removeObjectForKey:key];
}

-(NSString*)detailLabelForKey:(NSString*)key {
    LayCatalogDetail *detail = [self->details objectForKey:key];
    return detail.label;
}

-(NSArray*)allDetailKeys {
    return [self->details allKeys];
}

-(NSArray*)labelDataList {
    const NSUInteger numberOfDetails = [self->allowedKeyList count];
    NSMutableArray *labelDataList = [NSMutableArray arrayWithCapacity:numberOfDetails];
    for (NSString* key in self->allowedKeyList) {
        NSString *label = [self detailLabelForKey:key];
        NSString *value = [self detailForKey:key];
        LayPair *pair = [LayPair new];
        pair.first = label;
        pair.second = value;
        [labelDataList addObject:pair];
    }
    return labelDataList;
}

// private
-(void)initDetails {
    self->allowedKeyList = [NSMutableArray arrayWithCapacity:6];
    self->details = [NSMutableDictionary dictionaryWithCapacity:6];
    LayCatalogDetail *detail = [LayCatalogDetail new];
    detail.label = NSLocalizedString(@"CatalogDetailLabelPublisher", nil);
    [self->details setObject:detail forKey:@"publisher"];
    [self->allowedKeyList addObject:@"publisher"];
    
    detail = [LayCatalogDetail new];
    detail.label = NSLocalizedString(@"CatalogDetailLabelLink", nil);
    [self->details setObject:detail forKey:@"websitePublisher"];
    [self->allowedKeyList addObject:@"websitePublisher"];
    
    detail = [LayCatalogDetail new];
    detail.label = NSLocalizedString(@"CatalogDetailLabelPublisherEmail", nil);
    [self->details setObject:detail forKey:@"emailPublisher"];
    [self->allowedKeyList addObject:@"emailPublisher"];
    
    detail = [LayCatalogDetail new];
    detail.label = NSLocalizedString(@"CatalogDetailLabelAuthor", nil);
    [self->details setObject:detail forKey:@"author"];
    [self->allowedKeyList addObject:@"author"];
    
    detail = [LayCatalogDetail new];
    detail.label = NSLocalizedString(@"CatalogDetailLabelAuthorEmail", nil);
    [self->details setObject:detail forKey:@"emailAuthor"];
    [self->allowedKeyList addObject:@"emailAuthor"];
    
    detail = [LayCatalogDetail new];
    detail.label = NSLocalizedString(@"CatalogDetailLabelNumberOdQuestions", nil);
    [self->details setObject:detail forKey:@"numberOfQuestions"];
    [self->allowedKeyList addObject:@"numberOfQuestions"];
    
    detail = [LayCatalogDetail new];
    detail.label = NSLocalizedString(@"CatalogDetailLabelNumberOdExplanations", nil);
    [self->details setObject:detail forKey:@"numberOfExplanations"];
    [self->allowedKeyList addObject:@"numberOfExplanations"];
    
    detail = [LayCatalogDetail new];
    detail.label = NSLocalizedString(@"CatalogDetailLabelTopic", nil);
    [self->details setObject:detail forKey:@"topic"];
    [self->allowedKeyList addObject:@"topic"];
    
    detail = [LayCatalogDetail new];
    detail.label = NSLocalizedString(@"CatalogDetailLabelSource", nil);
    [self->details setObject:detail forKey:@"source"];
    [self->allowedKeyList addObject:@"source"];
    
    detail = [LayCatalogDetail new];
    detail.label = NSLocalizedString(@"CatalogDetailLabelLanguage", nil);
    [self->details setObject:detail forKey:@"language"];
    [self->allowedKeyList addObject:@"language"];
    
    detail = [LayCatalogDetail new];
    detail.label = NSLocalizedString(@"CatalogDetailLabelVersion", nil);
    [self->details setObject:detail forKey:@"version"];
    [self->allowedKeyList addObject:@"version"];
}

@end

@implementation LayCatalogDetail
@synthesize value, label;
@end