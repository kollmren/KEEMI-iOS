//
//  LayImportStateView.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 29.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayImportStateView.h"
#import "LayFrame.h"
#import "LayButton.h"
#import "LayVBoxLayout.h"
#import "LayStyleGuide.h"

#import "MWLogging.h"

static const NSInteger TAG_STATE_VIEW_CONTAINER = 3002;
static const NSInteger TAG_STATE_LABEL = 3004;
static const NSInteger TAG_STATE_ABORT_BUTTON = 3005;
static const NSInteger TAG_ICON = 3006;

@implementation LayImportStateView

@synthesize delegate, progressView;

- (id)initWithWidth:(CGFloat)width icon:(UIImage *)icon andButtonText:(NSString *)buttonText
{
    const CGRect viewRect = CGRectMake(0.0f, 0.0f, width, 0.0f);
    self = [super initWithFrame:viewRect];
    if (self) {
        self->imgLabelHspace = 10.0f;
        self->unzipStateViewLabelWidth = 0.0f;
        [self setupStateViewWithIcon:icon andButtonText:buttonText];
    }
    return self;
}

-(void)setLabelText:(NSString*)text {
    [self updateLabelUnzipStateWith:text];
    UIView *unzipStateView = [self viewWithTag:TAG_STATE_VIEW_CONTAINER];
    const CGFloat vSpace = 15.0f;
    CGFloat height = [LayVBoxLayout layoutSubviewsOfView:unzipStateView withSpace:vSpace];
    [LayFrame setHeightWith:height toView:unzipStateView animated:NO];
}

-(void)setIcon:(UIImage *)icon {
    UIImageView *imageView = (UIImageView*)[self viewWithTag:TAG_ICON];
    if(imageView) {
        imageView.image = icon;
    }
}

-(void)showErrorStateWithText:(NSString*)text {
    if(progressView) {
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        
        progressView.progressTintColor = [styleGuide getColor:AnswerWrong];
        progressView.trackTintColor = [styleGuide getColor:AnswerWrong];
        
        [self updateLabelUnzipStateWith:text];
        
        UIView *abortButton_ = [self viewWithTag:TAG_STATE_ABORT_BUTTON];
        abortButton_.hidden = NO;
        const CGFloat vSpace = 15.0f;
        UIView *container = abortButton_.superview;
        CGFloat currentOffsetY = 0.0f;
        for (UIView *subview in [container subviews]) {
            if(!subview.hidden) {
                CGRect subViewFrame = subview.frame;
                if(subview.tag == TAG_STATE_ABORT_BUTTON) {
                    currentOffsetY += 2*vSpace;
                }
                subViewFrame.origin.y = currentOffsetY;
                subview.frame = subViewFrame;
                currentOffsetY += subview.frame.size.height + vSpace;
            }
        }
        [LayFrame setHeightWith:currentOffsetY toView:container animated:NO];
        [LayFrame setHeightWith:currentOffsetY toView:self animated:NO];
    }
}

//
// Private
//

-(void)setupStateViewWithIcon:(UIImage*)icon andButtonText:(NSString *)buttonText {
    const CGRect viewFrame = self.frame;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGFloat viewWidth = viewFrame.size.width - 2*hSpace;
    const CGRect containerRect = CGRectMake(hSpace, 0.0f, viewWidth, 0.0f);
    //
    UIImageView *imgViewUnpack = [[UIImageView alloc]initWithImage:icon];
    imgViewUnpack.tag = TAG_ICON;
    imgViewUnpack.contentMode = UIViewContentModeScaleAspectFit;
    //
    UIFont *labelFont = [styleGuide getFont:NormalPreferredFont];
    self->unzipStateViewLabelWidth = viewWidth - imgViewUnpack.frame.size.width - imgLabelHspace;
    const CGFloat xPosLabel = imgViewUnpack.frame.size.width + imgLabelHspace;
    const CGRect labelRect = CGRectMake(xPosLabel, 0.0f, unzipStateViewLabelWidth, 0.0f);
    UILabel *label = [[UILabel alloc]initWithFrame:labelRect];
    label.tag = TAG_STATE_LABEL;
    label.numberOfLines = 2;
    label.font = labelFont;
    label.textColor = [styleGuide getColor:TextColor];
    label.textAlignment = NSTextAlignmentLeft;
    const CGRect labelImgContainerRect = CGRectMake(0.0, 0.0f, 0.0f, 0.0f);
    UIView *labelImgContainer = [[UIView alloc]initWithFrame:labelImgContainerRect];
    [labelImgContainer addSubview:imgViewUnpack];
    [labelImgContainer addSubview:label];
    //
    const CGFloat progressViewHeight = 10.0f;
    const CGRect progressViewRect = CGRectMake(hSpace, 0.0f, viewWidth - 2 * hSpace, progressViewHeight);
    progressView = [[UIProgressView alloc]initWithFrame:progressViewRect];
    progressView.progressTintColor = [styleGuide getColor:ButtonSelectedColor];
    //
    const CGSize buttonSize = CGSizeMake(viewFrame.size.width-2*hSpace, [styleGuide getDefaultButtonHeight]);
    const CGRect buttonFrame = CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height);
    NSString *abortLabel = buttonText;
    LayButton *abortButton_ = [[LayButton alloc]initWithFrame:buttonFrame label:abortLabel font:[styleGuide getFont:NormalPreferredFont] andColor:[styleGuide getColor:ClearColor]];
    abortButton_.hidden = YES;
    abortButton_.tag = TAG_STATE_ABORT_BUTTON;
    [abortButton_ fitToContent];
    [abortButton_ addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    const CGFloat xPosButton = (viewWidth - abortButton_.frame.size.width) / 2.0f;
    [LayFrame setXPos:xPosButton toView:abortButton_];
    //
    UIView *container = [[UIView alloc]initWithFrame:containerRect];
    container.tag = TAG_STATE_VIEW_CONTAINER;
    [container addSubview:labelImgContainer];
    [container addSubview:progressView];
    [container addSubview:abortButton_];
    const CGFloat vSpace = 15.0f;
    CGFloat height = [LayVBoxLayout layoutSubviewsOfView:container withSpace:vSpace];
    [LayFrame setHeightWith:height toView:container animated:NO];
    [LayFrame setHeightWith:height toView:self animated:NO];
    [self addSubview:container];
}

-(void)updateLabelUnzipStateWith:(NSString*)text {
    UILabel *unzipStateLabel = (UILabel *)[self viewWithTag:TAG_STATE_LABEL];
    [LayFrame setWidthWith:unzipStateViewLabelWidth toView:unzipStateLabel];
    unzipStateLabel.text = text;
    [unzipStateLabel sizeToFit];
    
    UIView *imgLabelContainer = unzipStateLabel.superview;
    CGFloat xPos = 0.0f;
    for (UIView *subView in [imgLabelContainer subviews]) {
        [LayFrame setXPos:xPos toView:subView];
        xPos += subView.frame.size.width + imgLabelHspace;
    }
    xPos -= imgLabelHspace;
    UIView *unzipStateView = imgLabelContainer.superview;
    [LayFrame setWidthWith:xPos toView:imgLabelContainer];
    const CGFloat newXPosImgLabelContainer = (unzipStateView.frame.size.width - xPos) / 2.0f;
    [LayFrame setXPos:newXPosImgLabelContainer toView:imgLabelContainer];
    const CGFloat newImgLabelContainerHeight = fmax(imgLabelContainer.frame.size.height, unzipStateLabel.frame.size.height);
    [LayFrame setHeightWith:newImgLabelContainerHeight toView:imgLabelContainer animated:NO];
    // center img and label vertically
    UIView *unzipIcon = [self viewWithTag:TAG_ICON];
    CGFloat newYPos = (newImgLabelContainerHeight - unzipIcon.frame.size.height) / 2.0f;
    [LayFrame setYPos:newYPos toView:unzipIcon];
    newYPos = (newImgLabelContainerHeight - unzipStateLabel.frame.size.height) / 2.0f;
    [LayFrame setYPos:newYPos toView:unzipStateLabel];
}

//
// Action handlers
//
-(void) buttonPressed {
    if(self.delegate) {
        [self.delegate buttonPressed];
    }
}

@end
