//
//  LayPageControl.m
//  Lay
//
//  Created by Rene Kollmorgen on 05.04.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayPageControl.h"
#import "LayFrame.h"
#import "LayImage.h"
#import "LayStyleGuide.h"

static const CGFloat DEFAULT_H_SPACE = 5.0f;
static const NSInteger DEFAULT_NUMBER_OF_START_PAGE = 1;

//
// LayPageControl
//
@interface LayPageControl() {
    CALayer *topLine;
}
@end

@implementation LayPageControl

@synthesize numberOfPages, currentPage, hSpace, hidesForSinglePage;

+(CGFloat)requiredWidthFor:(NSInteger)numberOfPages height:(CGFloat)heightOfPageControl andSpace:(CGFloat)hSpace {
    const CGFloat widthOfPageIndicators = heightOfPageControl;
    // Pageinicatotrs are centered (space left and right)
    const CGFloat leftAndRightSpace = 2;
    CGFloat requiredWidth = numberOfPages * widthOfPageIndicators + numberOfPages * leftAndRightSpace * hSpace;
    return requiredWidth;
}

-(id)initWithPosition:(CGPoint)position height:(CGFloat)height andNumberOfPages:(NSInteger)numberOfPages_ {
    const CGFloat requiredWidth = [LayPageControl requiredWidthFor:numberOfPages_ height:height andSpace:DEFAULT_H_SPACE];
    const CGRect frame = CGRectMake(position.x, position.y, requiredWidth, height);
    self = [super initWithFrame:frame];
    if (self) {
        self->hSpace = DEFAULT_H_SPACE;
        self->hidesForSinglePage = YES;
        self.numberOfPages = numberOfPages_;
        self->currentPage = DEFAULT_NUMBER_OF_START_PAGE;
        self.backgroundColor = [UIColor clearColor];
        [self layoutView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    CGPoint position = CGPointMake(frame.origin.x, frame.origin.y);
    return [self initWithPosition:position height:frame.size.height andNumberOfPages:0];
}

-(void)setupLayer {
    CGSize buttonSize = self.frame.size;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat borderHeight = [styleGuide getBorderWidth:NormalBorder];
    self->topLine = [[CALayer alloc]init];
    self->topLine.bounds = CGRectMake(0.0f, 0.0f, buttonSize.width, borderHeight);
    self->topLine.anchorPoint = CGPointMake(0.0f, 0.5f);
    self->topLine.position = CGPointMake(0.0f, 0.0f);
    self->topLine.backgroundColor = [UIColor lightGrayColor].CGColor;
    self->topLine.zPosition = 1;
    [self.layer addSublayer:self->topLine];
}

-(CGPoint)midPositionOfPageIndicatorOfPage:(NSInteger)pageNumber {
    CGPoint midPositionOfageIndicatorForPage = {0.0f, 0.0f};
    NSUInteger pageIndicatorIdx = 0;
    for (UIView *subview in [self subviews]) {
        if(pageNumber == pageIndicatorIdx) {
            CGFloat xPosMid = subview.frame.origin.x + subview.frame.size.width / 2;
            CGFloat yPosMid = subview.frame.origin.y + subview.frame.size.height / 2;
            midPositionOfageIndicatorForPage = CGPointMake(xPosMid, yPosMid);
        }
        pageIndicatorIdx++;
    }
    return midPositionOfageIndicatorForPage;
}

-(void)setNumberOfPages:(NSInteger)numberOfPages_ {
    numberOfPages = numberOfPages_;
    if(numberOfPages==1 && self.hidesForSinglePage) {
        [self setHidden:YES];
    } else {
        [self setHidden:NO];
    }
    [self layoutView];
}

-(void)setCurrentPage:(NSInteger)currentPage_ {
    currentPage = currentPage_;
    NSString *currentPageText = [NSString stringWithFormat:@"%d",currentPage_+1];
    for (UIView *subview in [self subviews]) {
        UILabel *pageIndicatorLabel = (UILabel*)subview;
        if([pageIndicatorLabel.text isEqualToString:currentPageText]) {
            pageIndicatorLabel.textColor = [UIColor darkTextColor];
        } else {
            pageIndicatorLabel.textColor = [UIColor lightGrayColor];
        }
    }
}

-(void)setHSpace:(CGFloat)hSpace_ {
    hSpace = hSpace_;
    [self layoutView];
}

-(void)setHidesForSinglePage:(BOOL)hidesForSinglePage_ {
    hidesForSinglePage = hidesForSinglePage_;
    if(hidesForSinglePage) {
        [self setHidden:YES];
    } else {
        [self setHidden:NO];
    }
}

-(void) removeAllSubviews {
    for (UIView *subview in [self subviews]) {
        [subview removeFromSuperview];
    }
}

-(void)layoutView {
    [self removeAllSubviews];
    const CGFloat dimensionOfPageIndicator = self.frame.size.height;
    CGFloat xPosCurrentPageIndicator = self.hSpace;
    for (NSInteger pageIdx = 0; pageIdx < self.numberOfPages; ++pageIdx) {
        const CGRect pageIndicatorFrame = CGRectMake(xPosCurrentPageIndicator, 0.0f, dimensionOfPageIndicator, dimensionOfPageIndicator);
        UILabel *pageIndicator = [[UILabel alloc]initWithFrame:pageIndicatorFrame];
        pageIndicator.backgroundColor = [UIColor clearColor];
        pageIndicator.textAlignment = NSTextAlignmentCenter;
        pageIndicator.font = [UIFont fontWithName:@"Avenir-Heavy" size:dimensionOfPageIndicator];
        pageIndicator.text = [NSString stringWithFormat:@"%d",pageIdx+1];;
        [self addSubview:pageIndicator];
         xPosCurrentPageIndicator += self.hSpace + dimensionOfPageIndicator + self.hSpace;
    }
    [LayFrame setWidthWith:xPosCurrentPageIndicator toView:self];
}

@end

