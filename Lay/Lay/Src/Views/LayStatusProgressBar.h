//
//  LayStatusProgressBar.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 27.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LayStatusProgressBar : UIView

@property (nonatomic) NSUInteger numberTotal;
@property (nonatomic) NSUInteger numberCurrent;
@property (nonatomic) NSUInteger numberCurrentCorrectAnswers;
@property (nonatomic) NSUInteger numberCurrentIncorrectAnswers;
@property (nonatomic) NSUInteger counterGroupedQuestion;

-(id)initWithFrame:(CGRect)frame numberTotal:(NSUInteger)total andNumberCurrent:(NSUInteger)current;

@end
