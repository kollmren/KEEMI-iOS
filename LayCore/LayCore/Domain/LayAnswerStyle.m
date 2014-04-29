//
//  LayAnswerStyle.m
//  LayCore
//
//  Created by Rene Kollmorgen on 29.04.14.
//  Copyright (c) 2014 Rene. All rights reserved.
//

#import "LayAnswerStyle.h"

//
// LayAnswerItemStyle
//

@interface LayAnswerStyle() {
    NSArray* listWithPossibleStyles;
    NSMutableArray* styleList;
}

@end

static NSString* styleColumnDescription = @"column";

@implementation LayAnswerStyle

@synthesize plainStyleDescription;

static Class _classObj = nil;

+(void) initialize {
    _classObj = [LayAnswerStyle class];
}

+(id)styleWithString:(NSString*)styleDescription {
    LayAnswerStyle *style = [[LayAnswerStyle alloc]initWithStyleDescription:styleDescription];
    return style;
}

-(id)initWithStyleDescription:(NSString*)plainStyleDescription_ {
    self = [super init];
    if(self) {
        self->listWithPossibleStyles = [NSArray arrayWithObjects:styleColumnDescription, nil];
        self->styleList = [NSMutableArray arrayWithCapacity:4];
        plainStyleDescription = plainStyleDescription_;
        if([self processStyle:plainStyleDescription_]) {
            return self;
        } else {
            return nil;
        }
    }
    return nil;
}

-(BOOL)hasStyle:(LayAnswerStyleType)styleType {
    BOOL hasStyle = NO;
    NSNumber *styleTypeNumber = [NSNumber numberWithInteger:styleType];
    if([self->styleList containsObject:styleTypeNumber]) {
        hasStyle = YES;
    }
    return hasStyle;
}

-(BOOL)processStyle:(NSString*)plainStyleDescription_ {
    BOOL validStyle = YES;
    NSString* styleSeparator = @";";
    NSArray *styleDescriptionList = [plainStyleDescription_ componentsSeparatedByString:styleSeparator];
    for (NSString* possibleStyle in self->listWithPossibleStyles) {
        if([styleDescriptionList containsObject:possibleStyle]) {
            LayAnswerStyleType styleType = [LayAnswerStyle styleTypeForDescription:possibleStyle];
            NSNumber *styleTypeNumber = [NSNumber numberWithInteger:styleType];
            [self->styleList addObject:styleTypeNumber];
        }
    }
    return validStyle;
}

+(LayAnswerStyleType)styleTypeForDescription:(NSString*)description {
    LayAnswerStyleType styleType = NoStyle;
    if([description isEqualToString:styleColumnDescription]) {
        styleType = StyleColumn;
    }
    return styleType;
}

@end