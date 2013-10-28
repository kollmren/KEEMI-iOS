//
//  LayColorProgress.m
//  Lay
//
//  Created by Luis Remirez on 30.11.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayColorProgress.h"

@implementation LayColorProgress

-(id) initWithView:(UIView*)view amountOfQuestions:(int)amountQuestions
{
    if(!(self = [super init])) {
        return nil;
    }
    _size =  view.frame.size;
    _amountQuestions = amountQuestions;
    _amount = [[UIView alloc] init];
    _amount.frame = CGRectMake(0, 0, _size.width, _size.height/2);
    UIColor *color= [UIColor colorWithRed:0.0f green:0.0f blue:1.0f alpha:1.0f];
    _amount.backgroundColor = color;
    [view addSubview:_amount];

    _progress = [[UIView alloc] init];
    _progress.frame = CGRectMake(0, _size.height/2, _size.width, _size.height/2);
    [view addSubview:_progress];
    return self;
}

- (void)setCorrectAnswers:(int)amount {
    if(amount<0) amount=0;
    if(amount>_amountQuestions) amount=_amountQuestions;
    float factor = (float)amount/(float)_amountQuestions;
    _amount.frame = CGRectMake(0, 0, _size.width*factor, _size.height);
}

- (void)setRanking:(float)ranking {
    float red = 1.0;
    float green = 1.0;
    float limit = 0.75;
    if(ranking<limit) {
        green = sqrtf(ranking/limit);
    } else {
        red = sqrtf(sqrtf((1.0 - ranking)/(1.0-limit)));
    }
    UIColor *color= [UIColor colorWithRed:red green:green blue:0.0f alpha:1.0f];
    _progress.backgroundColor = color;
}

@end
