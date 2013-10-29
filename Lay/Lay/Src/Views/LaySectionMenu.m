//
//  LaySectionMenu.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 04.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LaySectionMenu.h"
#import "LaySectionViewMetaInfo.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"
#import "LayIconButton.h"
#import "LayTableSectionView.h"
#import "LayVBoxLayout.h"

#import "MWLogging.h"

static const CGFloat indent = 15.0f;
static const CGFloat vSpace = 20.0f;
static const CGFloat strapIndent = 5.0f;
static const NSUInteger TAG_SECTION_TITLE = 104;
static const NSUInteger TAG_TOP_BUTTON = 105;
static const NSInteger TAG_TITLE_LABEL = 106;

@implementation LaySectionMenu

@synthesize sectionViewMetaInfoList, menuDelegate;

-(id)initWithSectionViewMetaInfoList:(NSArray*)sectionViewMetaInfoList_ andTitle:(NSString *)title_ {
    const CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGRect frame = CGRectMake(0.0f, 0.0f, width - indent, 0.0f);
    self = [super initWithFrame:frame];
    if(self) {
        self.sectionViewMetaInfoList = sectionViewMetaInfoList_;
        self->title = title_;
        self->toTopButton = nil;
        [self setupSectionOverview];
    }
    return self;
}

-(void)dealloc {
    MWLogDebug([LaySectionMenu class], @"dealloc");
}

-(void)setWindow:(UIWindow*)window {
    if(!self.window) {
        self.layer.zPosition = 2.0f;
        self->sectionOverviewStrap.layer.zPosition = 1.0f;
        [window addSubview:self];
        CGPoint strapPos = [self strapFramePosition];
        [LayFrame setPos:strapPos toView:self->sectionOverviewStrap];
        [LayFrame setXPos:-(self->sectionOverviewStrap.frame.size.width) toView:self->sectionOverviewStrap];
        [window addSubview:self->sectionOverviewStrap];
        CALayer *sectionStrapLayer = self->sectionOverviewStrap.layer;
        [UIView animateWithDuration:0.2 animations:^{
            sectionStrapLayer.position = CGPointMake((sectionStrapLayer.bounds.size.width/2.0f)-strapIndent, sectionStrapLayer.position.y);
        }];
    }
}

-(void)hideSectionOverview:(BOOL)animated {
    const CGFloat width = self.frame.size.width;
    if(animated) {
        CALayer *sectionOverviewLayer = self.layer;
        CALayer *sectionStrapLayer = self->sectionOverviewStrap.layer;
        [UIView animateWithDuration:0.3 animations:^{
            sectionOverviewLayer.position = CGPointMake(-(width/2.0f), sectionOverviewLayer.position.y);
            sectionStrapLayer.position = CGPointMake((sectionStrapLayer.bounds.size.width/2.0f)-strapIndent, sectionStrapLayer.position.y);
        } completion:^(BOOL finished){
            [self->strapButtonLeft removeFromSuperview];
            self->strapButtonRight.center = CGPointMake(self->sectionOverviewStrap.frame.size.width/2.0f, self->sectionOverviewStrap.frame.size.height/2.0f);
            [self->sectionOverviewStrap addSubview:self->strapButtonRight];
        }];
    } else {
        const CGFloat width = self.frame.size.width;
        [LayFrame setXPos:-width toView:self];
    }
    
}

-(void)hideSectionOverviewAnimated {
    [self hideSectionOverview:YES];
}

-(void)showMenu {
    [self updateMenu];
    const CGFloat yPosMenu = self.window.frame.size.height - self.frame.size.height + 8.0f;
    [LayFrame setYPos:yPosMenu toView:self];
    CALayer *sectionOverviewLayer = self.layer;
    CALayer *sectionStrapLayer = self->sectionOverviewStrap.layer;
    sectionStrapLayer.position = CGPointMake((sectionStrapLayer.bounds.size.width/2.0f)-strapIndent, sectionStrapLayer.position.y);
    [UIView animateWithDuration:0.3 animations:^{
        sectionOverviewLayer.position = CGPointMake((self.frame.size.width/2.0f)-indent, sectionOverviewLayer.position.y);
        sectionStrapLayer.position = CGPointMake((sectionStrapLayer.position.x)+((self.frame.size.width)-indent),
                                                 sectionStrapLayer.position.y);
    } completion:^(BOOL finished){
        [self->strapButtonRight removeFromSuperview];
        self->strapButtonLeft.center = CGPointMake(self->sectionOverviewStrap.frame.size.width/2.0f, self->sectionOverviewStrap.frame.size.height/2.0f);
        [self->sectionOverviewStrap addSubview:self->strapButtonLeft];
    }];
}

-(BOOL)menuIsVisible {
    BOOL visible = YES;
    if(self.frame.origin.x < -indent) {
        visible = NO;
    }
    return visible;
}

-(void)closeMenu {
    // 1. hide the menu to set the hidden location of the frame
    [self hideSectionOverviewAnimated];
    // 2, remove the menu from the window
    [self removeFromSuperview];
    CALayer *sectionStrapLayer = self->sectionOverviewStrap.layer;
    sectionStrapLayer.position = CGPointMake((sectionStrapLayer.bounds.size.width/2.0f)-strapIndent, sectionStrapLayer.position.y);
    [UIView animateWithDuration:0.3 animations:^{
        sectionStrapLayer.position = CGPointMake(-(self.frame.size.width/2.0f),
                                                 sectionStrapLayer.position.y);
    } completion:^(BOOL finished){
        [self->sectionOverviewStrap removeFromSuperview];
    }];

    
}

//
// Private
//
-(CGPoint)strapFramePosition {
    const CGFloat yPosStrap = self.window.frame.size.height -  self->sectionOverviewStrap.frame.size.height;
    const CGFloat xPosStrap = self.frame.size.width +  self.frame.origin.x - strapIndent;
    CGPoint pos = CGPointMake(xPosStrap, yPosStrap);
    return pos;
}

-(void)updateMenu {
    //
    UILabel *menuTitle = (UILabel *)[self viewWithTag:TAG_TITLE_LABEL];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    menuTitle.font = [styleGuide getFont:HeaderPreferredFont];
    [menuTitle sizeToFit];
    UIView *titleContainer = menuTitle.superview;
    [titleContainer addSubview:menuTitle];
    const CGFloat vSpaceTitle = 15.0f;
    [LayFrame setHeightWith:menuTitle.frame.size.height + vSpaceTitle toView:titleContainer animated:NO];
    [LayFrame setYPos:10.0f toView:menuTitle];
    //
    [self fillSectionOverview];
    CGFloat newHeight = self->container.frame.size.height + 2 * vSpace;
    CGFloat newWidth = self->container.frame.origin.x + self->container.frame.size.width + indent;
    [LayFrame setHeightWith:newHeight toView:self animated:NO];
    [LayFrame setWidthWith:newWidth toView:self];
    [LayFrame setWidthWith:newWidth toView:titleContainer];
    [LayFrame setYPos:titleContainer.frame.size.height toView:container];
    const CGFloat newXPosTopButton = self->container.frame.origin.x + self->container.frame.size.width - toTopButton.frame.size.width - 10.0f;
    [LayFrame setXPos:newXPosTopButton toView:self->toTopButton];
    if(self->menuDelegate && [self->menuDelegate isOnTop]) {
        toTopButton.hidden = YES;
    } else {
        toTopButton.hidden = NO;
    }
    
}

-(void)setupSectionOverview {
    const CGFloat width = self.frame.size.width;
    [LayFrame setXPos:-width toView:self];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    [styleGuide makeRoundedBorder:self withBackgroundColor:WhiteBackground andBorderColor:ButtonBorderColor];
    //Strap
    const CGSize strapSize = CGSizeMake(50.0f, 30.0f);
    const CGRect strapFrame = CGRectMake(0.0f, 0.0f, strapSize.width, strapSize.height);
    self->sectionOverviewStrap = [[UIView alloc] initWithFrame:strapFrame];
    self->strapButtonRight = [LayIconButton buttonWithId:LAY_BUTTON_ARROW_EAST];
    strapButtonRight.center = self->sectionOverviewStrap.center;
    [strapButtonRight addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [self->sectionOverviewStrap addSubview:strapButtonRight];
    [styleGuide makeRoundedBorder:self->sectionOverviewStrap withBackgroundColor:WhiteTransparentBackground andBorderColor:ClearColor];
    
    self->strapButtonLeft = [LayIconButton buttonWithId:LAY_BUTTON_ARROW_WEST];
    strapButtonLeft.center = self->sectionOverviewStrap.center;
    [strapButtonLeft addTarget:self action:@selector(hideSectionOverviewAnimated) forControlEvents:UIControlEventTouchUpInside];
    
    const CGRect titleContainerFrame = CGRectMake(2*indent, 0.0f, width-3*indent, 0.0f);
    const CGFloat titleContainerWidth = titleContainerFrame.size.width;
    UIView *titleContainer = [[UIView alloc]initWithFrame:titleContainerFrame];
    titleContainer.tag = TAG_SECTION_TITLE;
    self->toTopButton = [LayIconButton buttonWithId:LAY_BUTTON_ARROW_NORTH];
    self->toTopButton.tag = TAG_TOP_BUTTON;
    [LayIconButton setContentMode:UIViewContentModeTop to:self->toTopButton];
    self->toTopButton.hidden = YES;
    [self->toTopButton addTarget:self action:@selector(toTop) forControlEvents:UIControlEventTouchUpInside];
    const CGFloat hSpaceTitleTopButton = 10.0f;
    const CGFloat topButtonWidth = self->toTopButton.frame.size.width;
    const CGFloat xPosTopButton = titleContainerFrame.size.width - topButtonWidth;
    [LayFrame setXPos:xPosTopButton toView:self->toTopButton];
    [LayFrame setYPos:10.0f toView:self->toTopButton];
    [titleContainer addSubview:self->toTopButton];
    const CGRect titleFrame = CGRectMake(0.0f, 0.0f, titleContainerWidth - topButtonWidth - hSpaceTitleTopButton, 0.0f);
    UILabel *menuTitle = [[UILabel alloc]initWithFrame:titleFrame];
    menuTitle.tag = TAG_TITLE_LABEL;
    menuTitle.text = self->title;
    menuTitle.textColor = [UIColor lightGrayColor];
    menuTitle.font = [styleGuide getFont:NormalPreferredFont];
    menuTitle.backgroundColor = [UIColor clearColor];
    menuTitle.textAlignment = NSTextAlignmentLeft;
    [menuTitle sizeToFit];
    [titleContainer addSubview:menuTitle];
    const CGFloat vSpaceTitle = 15.0f;
    [LayFrame setHeightWith:menuTitle.frame.size.height + vSpaceTitle toView:titleContainer animated:NO];
    [LayFrame setYPos:vSpaceTitle toView:menuTitle];
    [self addSubview:titleContainer];
    
    self->initialContainerWidth = width-3*indent;
    const CGRect containerFrame = CGRectMake(2*indent, titleContainer.frame.size.height, self->initialContainerWidth, 0.0f);
    self->container = [[UIScrollView alloc]initWithFrame:containerFrame];
    container.backgroundColor = [UIColor clearColor];
    [self addSubview:container];
    
}


-(void)fillSectionOverview {
    for(UIView *subview in [self->container subviews]) {
        if(subview.tag!=TAG_SECTION_TITLE) {
            [subview removeFromSuperview];
        }
    }
    
    [LayFrame setWidthWith:self->initialContainerWidth toView:self->container];
    
    if(self.sectionViewMetaInfoList) {
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        UIFont *font = [styleGuide getFont:NormalPreferredFont];
        const NSInteger TAG_LABEL = 4058;
        const CGFloat indicatorHeight = [font lineHeight];
        const CGFloat xPosLabel = indicatorHeight + 10.0f;
        const CGFloat rowWidth = self->container.frame.size.width;
        const CGFloat maxLabelWidth = self->container.frame.size.width - xPosLabel - 10.0f;
        const CGRect rowFrame = CGRectMake(0.0f, 0.0f, rowWidth, 0.0f);
        const CGRect labelFrame = CGRectMake(xPosLabel, 0.0f, maxLabelWidth, 0.0f);
        CGFloat newWidth = 0.0f;
        for ( LaySectionViewMetaInfo *sectionMetaInfo in self.sectionViewMetaInfoList) {
            LaySectionMenEntryButton *row = [LaySectionMenEntryButton buttonWithType:UIButtonTypeCustom];
            row.frame = rowFrame;
            row.tag = sectionMetaInfo.sectionInxdexInTable;
            [row addTarget:self action:@selector(sectionPressed:) forControlEvents:UIControlEventTouchUpInside];
            row.backgroundColor = [UIColor clearColor];
            UILabel *label = [[UILabel alloc]initWithFrame:labelFrame];
            label.tag = TAG_LABEL;
            label.font = font;
            if([sectionMetaInfo numberOfRowsInSection]==0) {
                label.enabled = NO;
                row.enabled = NO;
            }
            static NSString *labelWithNumberOfRows = @"%@ (%u)";
            NSString *titleWithRowNumber = [NSString stringWithFormat:labelWithNumberOfRows, sectionMetaInfo.title, sectionMetaInfo.numberOfRowsInSection];
            NSString *text = titleWithRowNumber;
            label.text = text;
            label.numberOfLines = [styleGuide numberOfLines];
            [label sizeToFit];
            const CGFloat rowHeight = label.frame.size.height + vSpace;
            const CGFloat yPos = (rowHeight-label.frame.size.height)/2.0f;
            [LayFrame setYPos:yPos toView:label];
            const CGRect indicatorFrame = CGRectMake(0.0f, yPos, indicatorHeight, indicatorHeight);
            UIView *indicator = [[UIView alloc]initWithFrame:indicatorFrame];
            UIColor *color = [styleGuide getColor:sectionMetaInfo.sectionView.borderColor];
            indicator.backgroundColor = color;
            [row addSubview:indicator];
            [LayFrame setXPos:xPosLabel toView:label];
            [LayFrame setHeightWith:rowHeight toView:row animated:NO];
            [row addSubview:label];
            [self->container addSubview:row];
            
            CGFloat labelDimension = label.frame.origin.x +  label.frame.size.width;
            if(labelDimension > newWidth) {
                newWidth = labelDimension;
            }
            
            if(newWidth > rowWidth) {
                newWidth = rowWidth;
            }
        }
        
        // update the row and label with
        for (UIView *row in [self->container subviews]) {
            [LayFrame setWidthWith:newWidth toView:row];
            UIView *label = [row viewWithTag:TAG_LABEL];
            const CGFloat newLabelWidth = newWidth-xPosLabel;
            [LayFrame setWidthWith:newLabelWidth toView:label];
        }
        
        const CGFloat neededHeight = [LayVBoxLayout layoutSubviewsOfView:container withSpace:0.0f];
        const CGFloat maxHeight = self.window.frame.size.height * 0.66f;
        if(neededHeight > maxHeight) {
            self->container.contentSize = CGSizeMake(newWidth, neededHeight);
            [LayFrame setHeightWith:maxHeight toView:container animated:NO];
            [LayFrame setWidthWith:newWidth toView:container];
        } else {
            self->container.contentSize = CGSizeMake(newWidth, neededHeight);
            [LayFrame setHeightWith:neededHeight toView:container animated:NO];
            [LayFrame setWidthWith:newWidth toView:container];
        }
    } else {
        MWLogError([LaySectionMenu class], @"metaSectionInfoList is nil!");
    }
}

//
// Action handlers
//
-(void)sectionPressed:(UIButton*)sender {
    if(self.menuDelegate && sender) {
        [self hideSectionOverviewAnimated];
        NSUInteger sectionIndex = sender.tag;
        [self->menuDelegate sectionSelected:sectionIndex];
    } else {
         MWLogError([LaySectionMenu class], @"delegate or sender is nil!");
    }
}

-(void)toTop {
    if(self.menuDelegate) {
        [self hideSectionOverviewAnimated];
        [self->menuDelegate scrollToTop];
    } else {
        MWLogError([LaySectionMenu class], @"delegate is nil!");
    }
}

@end


//
// LaySectionMenEntryButton
//
@implementation LaySectionMenEntryButton

-(void)highlight {
    CGRect buttonBounds = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    if(self->highlightLayer == nil) {
        self->highlightLayer = [CALayer new];
        self->highlightLayer.hidden = YES;
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        self->highlightLayer.backgroundColor = [styleGuide getColor:ButtonSelectedBackgroundColor].CGColor;
        [self.layer addSublayer:self->highlightLayer];
    }
    
    self->highlightLayer.bounds = buttonBounds;
    self->highlightLayer.position = CGPointMake(buttonBounds.size.width / 2.0f, buttonBounds.size.height / 2.0f);
    self->highlightLayer.hidden = !self->highlightLayer.hidden;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self highlight];
    [super touchesBegan:touches withEvent:event];
}

@end





