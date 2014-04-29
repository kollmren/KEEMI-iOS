//
//  LayAnswerStyle.h
//  LayCore
//
//  Created by Rene Kollmorgen on 29.04.14.
//  Copyright (c) 2014 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum LayAnswerStyleTypes_ {
    StyleColumn, // presents the button in a separate column, only in single- and multiple-choice answer-view
    NoStyle
} LayAnswerStyleType;

//
// LayAnswerItemStyle
//
@interface LayAnswerStyle : NSObject {
    
}

@property (nonatomic,readonly) NSString* plainStyleDescription;

+(id)styleWithString:(NSString*)styleDescription;
+(LayAnswerStyleType)styleTypeForDescription:(NSString*)description;

-(id)initWithStyleDescription:(NSString*)plainStyleDescription;

-(BOOL)hasStyle:(LayAnswerStyleType)style;

@end
