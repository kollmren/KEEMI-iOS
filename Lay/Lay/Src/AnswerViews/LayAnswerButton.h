//
//  LayAnswerButton.h
//  Lay
//
//  Created by Rene Kollmorgen on 12.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayAnswerButtonDelegate.h"

typedef enum LayButtonStyle_ {
    StyleColumnLeft,
    StyleColumnRight
} LayButtonStyle;


@class AnswerItem;
@interface LayAnswerButton : UIButton

@property (nonatomic,weak) id<LayAnswerButtonDelegate> answerButtonDelegate;

@property (nonatomic, readonly) AnswerItem* answerItem;

@property (nonatomic) CGFloat width;

@property (nonatomic) CGFloat height;

@property (nonatomic) CGFloat XPos;

@property (nonatomic) CGFloat YPos;

@property (nonatomic) BOOL showBorder;

@property (nonatomic) BOOL showInfoIconIfEvaluated;

@property (nonatomic) BOOL showCorrectnessIconIfEvaluated;

@property (nonatomic) BOOL showIfHighlighted;

@property (nonatomic) BOOL showMarkIndicator;

@property (nonatomic) LayButtonStyle buttonStyle;

- (id)initWithFrame:(CGRect)frame and:(AnswerItem*)answerItem;
- (id)initWithFrame:(CGRect)frame and:(AnswerItem*)answerItem_ andBorderForMedia:(BOOL)borderForMedia;

-(void)mark;

-(void)unmark;

-(void)showCorrectness;

-(void)adjustLayerTo:(CGRect)frame;

-(void)doTap;

@end
