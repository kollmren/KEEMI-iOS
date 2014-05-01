//
//  LayCatalogListItem.m
//  Lay
//
//  Created by Rene Kollmorgen on 07.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayMyCatalogListItem.h"
#import "LayMediaView.h"
#import "LayStyleGuide.h"
#import "LayMediaData.h"
#import "LayFrame.h" 

#import "Media+Utilities.h"


static const NSInteger TAG_MEDIA_VIEW = 1111;
static const NSInteger TAG_LINE = 1112;

@implementation LayMyCatalogListItem

@synthesize catalogTitle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

-(void)setCatalogTitle:(UILabel *)catalogTitle_ {
    catalogTitle = catalogTitle_;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    catalogTitle.font = [styleGuide getFont:NormalFont];
    catalogTitle.textColor = [styleGuide getColor:TextColor];
    //
    self->catalogPublisher = [[UILabel alloc]initWithFrame:catalogTitle.frame];
    self->catalogPublisher.numberOfLines = 1;
    self->catalogPublisher.font = [styleGuide getFont:SubInfoFont];
    self->catalogPublisher.textColor = [UIColor darkGrayColor];
    [self addSubview:self->catalogPublisher];
    //
    self->importDate = [[UILabel alloc]initWithFrame:catalogTitle.frame];
    self->importDate.numberOfLines = 1;
    self->importDate.font = [styleGuide getFont:SubInfoFont];
    self->importDate.textColor = [UIColor darkGrayColor];
    [self addSubview:self->importDate];

    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    UIColor *selectedColor = [styleGuide getColor:ButtonSelectedBackgroundColor];
    UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    selectedBackgroundView.backgroundColor = selectedColor;
    [self setSelectedBackgroundView:selectedBackgroundView];
}

-(void)setCover:(Media *)cover title:(NSString *)title publisher:(NSString *)publisher andNumberOfQuestions:(NSString*)numberOfQuestions {
    LayMediaData *coverMediaData = [LayMediaData byMediaObject:cover];
    [self setCoverWithMediaData:coverMediaData title:title publisher:publisher andNumberOfQuestions:numberOfQuestions];
}

-(void)setCoverWithMediaData:(LayMediaData *)cover title:(NSString *)title publisher:(NSString *)publisher andNumberOfQuestions:(NSString*)numberOfQuestions {
    UIView *subview = [self viewWithTag:TAG_MEDIA_VIEW];
    if(subview) {
        [subview removeFromSuperview];
    }
    subview = [self viewWithTag:TAG_LINE];
    if(subview) {
        [subview removeFromSuperview];
    }
    
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    // Cover
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGFloat yPosCover = 0.0f;
    const CGSize coverSize = [styleGuide coverMediaSize];
    const CGRect coverMediaRect = CGRectMake(hSpace, yPosCover, coverSize.width, coverSize.height);
    LayMediaView *mediaView = [[LayMediaView alloc]initWithFrame:coverMediaRect andMediaData:cover];
    mediaView.scaleToFrame = YES;
    mediaView.ignoreEvents = YES;
    mediaView.zoomable = NO;
    mediaView.tag = TAG_MEDIA_VIEW;
    [mediaView layoutMediaView];
    [self addSubview:mediaView];
    //
    self->catalogPublisher.text = publisher;
    self->importDate.text = numberOfQuestions;
    [LayFrame setWidthWith:self->catalogPublisher.frame.size.width toView:self->catalogTitle];
    self.catalogTitle.text = title;
    [self.catalogTitle sizeToFit];
    
    const CGFloat vSpace = 3.0f;
    CGFloat yPos = 4.0f;
    [LayFrame setYPos:yPos toView:self->catalogPublisher];
    yPos += self->catalogPublisher.frame.size.height + vSpace;
    [LayFrame setYPos:yPos toView:self->catalogTitle];
    yPos += self->catalogTitle.frame.size.height + vSpace;
    [LayFrame setYPos:yPos toView:self->importDate];
    //
    const CGFloat xPosLine = self->catalogPublisher.frame.origin.x;
    const CGFloat lineWidth = self->catalogPublisher.frame.size.width;
    const CGFloat lineHeight = [styleGuide getBorderWidth:NormalBorder];;
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(xPosLine, coverSize.height - lineHeight, lineWidth, lineHeight)];
    line.tag = TAG_LINE;
    line.backgroundColor = [styleGuide getColor:GrayTransparentBackground];
    [self addSubview:line];
}

@end
