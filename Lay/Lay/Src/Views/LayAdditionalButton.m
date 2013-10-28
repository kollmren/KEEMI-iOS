//
//  LayAdditionalButton.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 11.09.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayAdditionalButton.h"
#import "LayFrame.h"
#import "LayStyleGuide.h"

const CGSize additionalButtonSize = { 50.0f, 30.0f };

@implementation LayAdditionalButton

- (id)initWithPosition:(CGPoint)position
{
    const CGRect additionalInfoButtonFrame = CGRectMake(position.x, position.y, additionalButtonSize.width,
                                                        additionalButtonSize.height);
    self = [super initWithFrame:additionalInfoButtonFrame];
    if (self) {
        [self setupButtonWithPosition:position];
    }
    return self;
}

-(void)setupButtonWithPosition:(CGPoint)position {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    self->button = [UIButton buttonWithType:UIButtonTypeCustom];
    self->button .titleLabel.font = [styleGuide getFont:SmallFont];
    [self->button setTitle:@"..." forState:UIControlStateNormal];
    [self->button  setTitleColor:[styleGuide getColor:TextColor] forState:UIControlStateNormal];
    [LayFrame setSizeWith:self.frame.size toView:self->button];
    self->button.center = CGPointMake(additionalButtonSize.width/2.0f, additionalButtonSize.height/2.0f);
    [self addSubview:self->button];
    [styleGuide makeRoundedBorder:self withBackgroundColor:GrayTransparentBackground andBorderColor:ClearColor];
}

@end
