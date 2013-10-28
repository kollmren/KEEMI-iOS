//
//  LaySectionView.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 19.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LaySectionView.h"
#import "LayImageRibbon.h"
#import "LayStyleGuide.h"
#import "LayMediaData.h"
#import "LayFrame.h"

#import "Section+Utilities.h"
#import "Media+Utilities.h"

static const NSInteger TAG_SECTION_TITLE = 1001;
static const NSInteger TAG_SECTION_ITEM_TEXT = 1003;
static const NSInteger TAG_SECTION_ITEM_MEDIA_LIST = 1004;

@implementation LaySectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame andSectionList:(NSArray*)sectionList {
    self = [self initWithFrame:frame];
    if(self) {
        [self setupViewWithSectionList:sectionList];
        [self layoutView];
    }
    return self;
}

-(void)setupViewWithSectionList:(NSArray*)sectionList {
    for (Section* section in sectionList) {
        [self addSectionToView:section];
    }
}

-(void)addSectionToView:(Section*)section {
    if(section.title) {
        const CGRect sectionTitleRect = CGRectMake(0.0f, 0.0f, self.frame.size.width, 0.0f);
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        UILabel *sectionTitle = [[UILabel alloc]initWithFrame:sectionTitleRect];
        sectionTitle.tag = TAG_SECTION_TITLE;
        sectionTitle.textColor = [styleGuide getColor:TextColor];
        sectionTitle.font = [styleGuide getFont:SubHeaderPreferredFont];
        sectionTitle.backgroundColor = [UIColor clearColor];
        sectionTitle.text = section.title;
        sectionTitle.numberOfLines = [styleGuide numberOfLines];
        [sectionTitle sizeToFit];
        [self addSubview:sectionTitle];
    }
    
    NSArray *sectionGroupList = [section sectionGroupList];
    for (NSObject* sectionGroup in sectionGroupList) {
        if([sectionGroup isKindOfClass:[LaySectionTextList class]]) {
            [self addSectionTextList:(LaySectionTextList*)sectionGroup];
        } else if([sectionGroup isKindOfClass:[LaySectionMediaList class]]) {
            [self addSectionMediaList:(LaySectionMediaList*)sectionGroup];
        }
    }
}

-(void)addSectionTextList:(LaySectionTextList*)sectionTextList {
    const CGRect sectionTextRect = CGRectMake(0.0f, 0.0f, self.frame.size.width, 0.0f);
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    for (SectionText *sectionText in sectionTextList.textList) {
        UILabel *sectionTextLabel = [[UILabel alloc]initWithFrame:sectionTextRect];
        sectionTextLabel.tag = TAG_SECTION_ITEM_TEXT;
        sectionTextLabel.textColor = [styleGuide getColor:TextColor];
        sectionTextLabel.font = [styleGuide getFont:NormalPreferredFont];
        sectionTextLabel.backgroundColor = [UIColor clearColor];
        sectionTextLabel.numberOfLines = [styleGuide numberOfLines];
        sectionTextLabel.text = sectionText.text;
        [sectionTextLabel sizeToFit];
        [self addSubview:sectionTextLabel];
    }
}

-(void)addSectionMediaList:(LaySectionMediaList*)sectionMediaList {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat maxRibbonHeight = [styleGuide maxRibbonHeight];
    const CGSize maxRibbonEntrySize = [styleGuide maxRibbonEntrySize];
    const CGRect ribbonFrame = CGRectMake(0.0f, 0.0f, self.frame.size.width, maxRibbonHeight);
    if(sectionMediaList && [sectionMediaList.mediaList count] > 0) {
        LayImageRibbon *imageRibbon = [[LayImageRibbon alloc]initWithFrame:ribbonFrame entrySize:maxRibbonEntrySize andOrientation:HORIZONTAL];
        imageRibbon.tag = TAG_SECTION_ITEM_MEDIA_LIST;
        imageRibbon.pageMode = YES;
        imageRibbon.entriesInteractive = YES;
        imageRibbon.animateTap = NO;
        for (SectionMedia *sectionMedia in sectionMediaList.mediaList) {
            LayMediaData *mediaData = [LayMediaData byMediaObject:sectionMedia.mediaRef];
            [imageRibbon addEntry:mediaData withIdentifier:0];
        }
        if([imageRibbon numberOfEntries]>0) {
            [imageRibbon layoutRibbon];
        }
        [imageRibbon fitHeightOfRibbonToEntryContent];
        [self addSubview:imageRibbon];
    }
}

-(void)layoutView {
    const CGFloat additionalSpaceAfterTitle = -5.0f;
    const CGFloat vSpace = 10.0f;
    CGFloat yPos = 0.0f;
    for (UIView* subview in [self subviews]) {
        [LayFrame setYPos:yPos toView:subview];
        yPos += subview.frame.size.height + vSpace;
        if(subview.tag == TAG_SECTION_TITLE || subview.tag == TAG_SECTION_ITEM_MEDIA_LIST) {
            yPos += additionalSpaceAfterTitle;
        }
    }
    [LayFrame setHeightWith:yPos toView:self animated:NO];
}

@end
