//
//  LaySectionView.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 01.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayTableSectionView.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"

@interface LayTableSectionView() {
    CALayer *topLine;
    CALayer *bottomLine;
    CGFloat titleWidth;
}
@end


//
// LaySectionView
//
static NSInteger TAG_LABEL =102;

@implementation LayTableSectionView

@synthesize borderColor, title;

- (id)initWithTitle:(NSString*)title_ andBorderColor:(LayStyleGuideColor)borderColor_
{
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat screenWidth = [[UIApplication sharedApplication] statusBarFrame].size.width;
    const CGRect frame = CGRectMake(0.0f, 0.0f, screenWidth, [styleGuide heightOfSection]);
    self = [super initWithFrame:frame];
    if (self) {
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
        self->titleWidth = self.frame.size.width - 8*hSpace;
        [self setupView];
        self.borderColor = borderColor_;
        self.title = title_;
    }
    return self;
}

-(void)setTitle:(NSString *)title_ {
    title = title_;
    UILabel *label = (UILabel*)[self viewWithTag:TAG_LABEL];
    [LayFrame setWidthWith:self->titleWidth toView:label];
    label.text = title;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    label.font = [styleGuide getFont:NormalPreferredFont];
    CGSize neededSize = [label sizeThatFits:label.frame.size];
    if(neededSize.width < label.frame.size.width) {
        [label sizeToFit];
    }
    label.center = CGPointMake(self.frame.size.width/2.0f, self.frame.size.height/2.0f);
    [self adjustLines];
}

-(void)adjustToNewPreferredFont {
    [self setTitle:self.title];
}

-(void)setupView {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat vSpace = 5.0f;
    const CGFloat height = [styleGuide heightOfSection] - 2 * vSpace;
    UILabel *label =
    [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self->titleWidth, height)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [styleGuide getColor:TextColor];
    label.font = [styleGuide getFont:NormalPreferredFont];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = TAG_LABEL;
    [self addSubview:label];
    self.backgroundColor = [styleGuide getColor:WhiteTransparentBackground];
}

-(void)adjustLines {
    if(!self->topLine) {
        self->topLine = [CALayer new];
        self->bottomLine = [CALayer new];
        [self.layer addSublayer:self->topLine];
        [self.layer addSublayer:self->bottomLine];
    }
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    UILabel *label = (UILabel*)[self viewWithTag:TAG_LABEL];
    const CGFloat labelWidth = label.frame.size.width;
    const CGFloat lineWidth = ((self.frame.size.width - labelWidth) / 2.0f) - 2*hSpace;
    UIColor *lineColor = [styleGuide getColor:self.borderColor];;
    const CGFloat lineHeight = [styleGuide getBorderWidth:NormalBorder];
    const CGRect lineBounds = CGRectMake(0.0f, 0.0f, lineWidth, lineHeight);
    const CGFloat yPos = self.frame.size.height / 2.0f;
    self->topLine.bounds = lineBounds;
    self->topLine.anchorPoint = CGPointMake(0.0f, 0.5f);
    self->topLine.backgroundColor = lineColor.CGColor;
    self->topLine.position = CGPointMake(hSpace, yPos);
    self->bottomLine.bounds = lineBounds;
    self->bottomLine.anchorPoint = CGPointMake(0.0f, 0.5f);
    self->bottomLine.backgroundColor = lineColor.CGColor;
    const CGFloat yPosRightLine = label.frame.origin.x + labelWidth + hSpace;
    self->bottomLine.position = CGPointMake(yPosRightLine, yPos);
}


@end
