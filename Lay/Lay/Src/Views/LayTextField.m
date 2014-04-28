//
//  LayTextField.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 23.04.14.
//  Copyright (c) 2014 Rene. All rights reserved.
//

#import "LayTextField.h"

#import "LayStyleGuide.h"
#import "LayImage.h"

@implementation LayTextField

@synthesize isCorrect;

+(CGFloat)textFieldHeight {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    UIFont *textFieldFont = [styleGuide getFont:NormalPreferredFont];
    const CGFloat heightTextFields = textFieldFont.lineHeight * 2.0f;
    return heightTextFields;
}

-(id)initWithPosition:(CGPoint)position andWidth:(CGFloat)width {
    const CGFloat height = [LayTextField textFieldHeight];
    const CGRect frame = CGRectMake(position.x, position.y, width, height);
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupTextField];
        [self setupLayer];
    }
    return self;
}

-(void)setIsCorrect:(BOOL)isCorrect_ {
    isCorrect = isCorrect_;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    if(isCorrect) {
        self->leftLayer.backgroundColor = [styleGuide getColor:AnswerCorrect].CGColor;
    } else {
        self->leftLayer.backgroundColor = [styleGuide getColor:AnswerWrong].CGColor;
        CGImageRef iconInCorrect = [[LayImage imageWithId:LAY_IMAGE_CANCEL] CGImage];
        [self->correctIconLayer setContents:(__bridge id)(iconInCorrect)];
    }
    self->leftLayer.hidden = NO;
    self->correctIconLayer.hidden = NO;
    self->textField.enabled = NO;
}

//
// Private
//
-(void)setupTextField {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    UIFont *textFieldFont = [styleGuide getFont:NormalPreferredFont];
    const CGFloat heightTextFields = self.frame.size.height;
    const CGFloat hBorderWidth = [styleGuide getHorizontalScreenSpace];
    const CGFloat textFieldWidth = self.frame.size.width - 2* hBorderWidth;
    const CGRect textFieldRect = CGRectMake(hBorderWidth, 0.0f, textFieldWidth, heightTextFields);
    self->textField = [[UITextField alloc]initWithFrame:textFieldRect];
    self->textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self->textField.layer.borderWidth = [styleGuide getBorderWidth:NormalBorder];
    self->textField.font = textFieldFont;
    self->textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self addSubview:self->textField];
}

-(void)setupLayer {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat borderHeight = [styleGuide getBorderWidth:NormalBorder];
    self->leftLayer = [[CALayer alloc]init];
    self->leftLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
    self->leftLayer.position = CGPointMake(0.0f, 0.0f);
    self->leftLayer.bounds = CGRectMake(0.0f, 0.0f, borderHeight * 5.0f, self.frame.size.height);
    self->leftLayer.backgroundColor = [styleGuide getColor:ClearColor].CGColor;
    self->leftLayer.zPosition = 1;
    self->leftLayer.hidden = YES;
    [self.layer addSublayer:self->leftLayer];
    //
    const CGFloat indent = 6.0f;
    CGSize iconButtonSize = [styleGuide iconButtonSize];
    CGFloat iconHeight = iconButtonSize.width;
    CGFloat iconWidth = iconButtonSize.height;
    CGImageRef iconCorrect = [[LayImage imageWithId:LAY_IMAGE_DONE] CGImage];
    self->correctIconLayer = [[CALayer alloc]init];
    self->correctIconLayer.bounds = CGRectMake(0.0f, 0.0f, iconWidth, iconHeight);
    self->correctIconLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
    const CGPoint correctIconLayerPos = CGPointMake(self.frame.size.width - iconWidth - indent, (self.frame.size.height - iconHeight) / 2.0f);
    self->correctIconLayer.position = correctIconLayerPos;
    self->correctIconLayer.contentsGravity = kCAGravityResizeAspect;
    self->correctIconLayer.zPosition = 100;
    [self->correctIconLayer setContents:(__bridge id)(iconCorrect)];
    [self->correctIconLayer setHidden:YES];
    [self.layer addSublayer:self->correctIconLayer];
}

@end
