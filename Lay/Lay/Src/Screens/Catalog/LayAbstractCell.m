//
//  LayCatalogAbstractListCell.m
//  Lay
//
//  Created by Rene Kollmorgen on 23.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayAbstractCell.h"
#import "LayVBoxLayout.h"
#import "LayVBoxView.h"
#import "LayMediaView.h"
#import "LayMiniIconBar.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"

#import "Question+Utilities.h"
#import "Explanation+Utilities.h"
#import "Section+Utilities.h"
#import "Answer+Utilities.h"
#import "AnswerItem+Utilities.h"
#import "Media+Utilities.h"
#import "UGCCatalog+Utilities.h"

#import "MWLogging.h"

static const CGFloat g_VERTICAL_SPACE = 5.0f;
static const CGFloat g_VERTICAL_BORDER = 5.0f;

static const CGFloat g_FONT_SIZE_INTRO = 12.0f;
static const NSInteger g_NUMBER_OF_LINES_INTRO = 10;
static const CGFloat g_FONT_SIZE_QUESTION = 18.0f;
static const NSInteger g_NUMBER_OF_LINES_QUESTION = 5;

static CGFloat g_HEIGHT_NUMBER_LABEL = 15.0f;
static const CGFloat g_WIDTH_NUMBER_LABEL = 40.0f;

static const CGFloat g_HEIGHT_MEDIA_CONTAINER = 90.0f;

static const NSInteger MAX_MEDIA_IN_CONTAINER = 2;

static CGFloat g_cellWidth;

//
// LayVBoxView's
//
@interface HeaderLabel : UIView<LayVBoxView>
@property (nonatomic) CGFloat spaceAbove;
@property (nonatomic) BOOL keepWidth;
@property (nonatomic) CGFloat border;
@end

@interface IntroLabel : UILabel<LayVBoxView>
@property (nonatomic) CGFloat spaceAbove;
@property (nonatomic) BOOL keepWidth;
@property (nonatomic) CGFloat border;
@end

@interface AbstractCellQuestionLabel : UILabel<LayVBoxView>
@property (nonatomic) CGFloat spaceAbove;
@property (nonatomic) BOOL keepWidth;
@property (nonatomic) CGFloat border;
@end

@interface MediaViewContainer : UIView<LayVBoxView>
@property (nonatomic) CGFloat spaceAbove;
@property (nonatomic) BOOL keepWidth;
@property (nonatomic) CGFloat border;

+(CGFloat)addMediaData:(NSArray*)mediaDataArray toView:(UIView*)view;

-(void)resetContainer;

@end

//
// LayAbstractCell
//
@interface LayAbstractCell() {
    HeaderLabel* headerLabel;
    UILabel *numberLabel;
    LayMiniIconBar *miniIconBar;
    IntroLabel *introLabel;
    AbstractCellQuestionLabel *questionLabel;
    MediaViewContainer *mediaViewContainer;
}
@end


NSString* const abstractCellIdentifier = @"CellAbstract";

@implementation LayAbstractCell

@synthesize question, explanation;

+(void)initialize {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    g_cellWidth = screenWidth - 2*hSpace;
    g_HEIGHT_NUMBER_LABEL = [styleGuide getFont:SmallFont].lineHeight;
}

+(CGFloat) heightForQuestion:(Question*)question {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    CGFloat cellHeight = g_VERTICAL_BORDER * 2;
    cellHeight += g_HEIGHT_NUMBER_LABEL + g_VERTICAL_SPACE;
    if(question.title) {
        UIFont *font = [styleGuide getFont:SmallPreferredFont];
        CGFloat heightIntro =
        [LayFrame heightForText:question.title withFont:font maxLines:g_NUMBER_OF_LINES_INTRO andCellWidth:g_cellWidth ];
        cellHeight += heightIntro + g_VERTICAL_SPACE;
    }
    
    UIFont *font = [styleGuide getFont:NormalPreferredFont];
    CGFloat heightQuestion =
    [LayFrame heightForText:question.question withFont:font maxLines:g_NUMBER_OF_LINES_QUESTION andCellWidth:g_cellWidth];
    cellHeight += heightQuestion;
    if([question hasThumbnails]) {
        NSArray *thumbnailList = [question orderedThumbnailListAsMediaData];
        CGFloat highestThumbnail = [MediaViewContainer addMediaData:thumbnailList toView:nil];
        cellHeight += g_VERTICAL_SPACE + highestThumbnail + g_VERTICAL_SPACE;
    }
    
    return cellHeight;
}

+(CGFloat) heightForExplanation:(Explanation*)explanation {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    CGFloat cellHeight = g_VERTICAL_BORDER * 2;
    cellHeight += g_HEIGHT_NUMBER_LABEL + g_VERTICAL_SPACE;
    if(explanation.title) {
        UIFont *font = [styleGuide getFont:SmallPreferredFont];
        CGFloat heightIntro =
        [LayFrame heightForText:explanation.title withFont:font maxLines:g_NUMBER_OF_LINES_INTRO andCellWidth:g_cellWidth ];
        cellHeight += heightIntro + g_VERTICAL_SPACE;
    }
    
    
    NSString *explanationPreviewText = [LayAbstractCell previewTextForExplanation:explanation];
    if( explanationPreviewText ) {
        UIFont *font = [styleGuide getFont:NormalPreferredFont];
        CGFloat heightQuestion =
        [LayFrame heightForText:explanationPreviewText withFont:font maxLines:g_NUMBER_OF_LINES_QUESTION andCellWidth:g_cellWidth];
        cellHeight += heightQuestion;
    }
    return cellHeight;
}

+(NSString*)previewTextForExplanation:(Explanation*)explanation {
    NSString *explanationPreviewText = nil;
    NSArray *sectionList = [explanation sectionList];
    if([sectionList count] > 0) {
        for (Section *section in sectionList) {
            // Search for sample text to show as preview
            for ( NSObject *sectionItem in [section sectionGroupList] ) {
                if( [sectionItem isKindOfClass:[LaySectionTextList class]] ) {
                    LaySectionTextList *textList = (LaySectionTextList *)sectionItem;
                    if([textList.textList count] > 0) {
                        SectionText *sectionText = [textList.textList objectAtIndex:0];
                        explanationPreviewText = sectionText.text;
                        break;
                    } else {
                        MWLogError( [LayAbstractCell class], @"Internal Error! SectionTextList has no text-item!" );
                    }
                }
            }
            if(explanationPreviewText) break;
        }
    }
    return explanationPreviewText;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
        self->headerLabel = [[HeaderLabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, g_cellWidth, g_HEIGHT_NUMBER_LABEL)];
        [self setupLabel];
        [self.contentView addSubview:self->headerLabel];
        self->introLabel = [[IntroLabel alloc]initWithFrame:CGRectMake(hSpace, 0.0f, g_cellWidth, 0.0f)];
        [self->introLabel setHidden:YES];
        [self setPropertiesIntroLabel];
        [self.contentView addSubview:self->introLabel];
        self->questionLabel = [[AbstractCellQuestionLabel alloc]initWithFrame:CGRectMake(hSpace, 0.0f, g_cellWidth, 0.0f)];
        [self setPropertiesQuestionLabel];
        [self.contentView addSubview:self->questionLabel];
        self->mediaViewContainer = [[MediaViewContainer alloc]initWithFrame:CGRectMake(hSpace, 0.0f, g_cellWidth, g_HEIGHT_MEDIA_CONTAINER)];
        [self setPropertiesMediaContainer];
        [self->mediaViewContainer setHidden:YES];
        [self.contentView addSubview:self->mediaViewContainer];
        //
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIColor *selectedColor = [styleGuide getColor:ButtonSelectedBackgroundColor];
        UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        selectedBackgroundView.backgroundColor = selectedColor;
        [self setSelectedBackgroundView:selectedBackgroundView];
    }
    return self;
}

-(void)dealloc {
    MWLogDebug([LayAbstractCell class], @"dealloc");
}

-(void)setupLabel {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    self->numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, g_WIDTH_NUMBER_LABEL, g_HEIGHT_NUMBER_LABEL)];
    numberLabel.textColor = [styleGuide getColor:TextColor];
    numberLabel.font = [styleGuide getFont:SmallFont];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.textColor = [styleGuide getColor:TextColor];
    numberLabel.backgroundColor = [styleGuide getColor:GrayTransparentBackground];
    [self->headerLabel addSubview:numberLabel];
    self->miniIconBar = [[LayMiniIconBar alloc]initWithWidth:self.frame.size.width];
    self->miniIconBar.showDisabledIcons = NO;
    self->miniIconBar.positionId = MINI_POSITION_TOP;
    self->miniIconBar.showLearnStateIcon = YES;
    //self->miniIconBar.showExplanationIcon = YES;
    [self->headerLabel addSubview:self->miniIconBar];
    self->headerLabel.keepWidth = YES;
}

-(void)setPropertiesIntroLabel {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    self->introLabel.spaceAbove = g_VERTICAL_SPACE;
    self->introLabel.border = [styleGuide getHorizontalScreenSpace];
    self->introLabel.textAlignment = NSTextAlignmentLeft;
    self->introLabel.font = [styleGuide getFont:SmallPreferredFont];
    self->introLabel.textColor = [styleGuide getColor:TextColor];
    self->introLabel.backgroundColor = [UIColor clearColor];
    self->introLabel.numberOfLines = g_NUMBER_OF_LINES_INTRO;
}

-(void)setPropertiesQuestionLabel {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    self->questionLabel.spaceAbove = g_VERTICAL_SPACE;
    self->questionLabel.border = [styleGuide getHorizontalScreenSpace];
    self->questionLabel.textAlignment = NSTextAlignmentLeft;
    self->questionLabel.font = [styleGuide getFont:NormalPreferredFont];
    self->questionLabel.backgroundColor = [UIColor clearColor];
    self->questionLabel.numberOfLines = g_NUMBER_OF_LINES_QUESTION;
    self->questionLabel.textColor = [styleGuide getColor:TextColor];
}

-(void)setPropertiesMediaContainer {
    self->mediaViewContainer.spaceAbove = g_VERTICAL_SPACE;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    self->mediaViewContainer.border = [styleGuide getHorizontalScreenSpace];
}

-(void)showMediaItemsInContainer:(Question*)question_ {;
    [self resetMediaViewContainer];
    NSArray* thumbnailList = [question orderedThumbnailListAsMediaData];
    if([thumbnailList count]>0) {
        [MediaViewContainer addMediaData:thumbnailList toView:self->mediaViewContainer];
        [self->mediaViewContainer setHidden:NO];
    }
}

-(void)resetMediaViewContainer {
    [self->mediaViewContainer resetContainer];
    [self->mediaViewContainer setHidden:YES];
}

-(void)setQuestion:(Question *)question_ {
    question = question_;
    
    self->numberLabel.text = [[question questionNumber] stringValue];
    
    CGRect baseRect = CGRectMake(0.0f, 0.0f, g_cellWidth, 0.0f/**sizeToFit sets the proper height*/);
    if(question.title) {
        self->introLabel.frame = baseRect;
        self->introLabel.text = question.title;
        [self->introLabel setHidden:NO];
        [self->introLabel sizeToFit];
    } else {
        [self->introLabel setHidden:YES];
        self->introLabel.text = @"";
    }
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    UIFont *questionFont = [styleGuide getFont:NormalPreferredFont];
    self->questionLabel.font = questionFont;
    self->questionLabel.frame = baseRect;
    self->questionLabel.text = question.question;
    [self->questionLabel sizeToFit];
    
    [self showMediaItemsInContainer:question];
    [self showMiniIconsForQuestion];
    [self layoutCell];
}

-(void)setExplanation:(Explanation *)explanation_ {
    explanation = explanation_;
    
    self->numberLabel.text = [[explanation number] stringValue];
    
    CGRect baseRect = CGRectMake(0.0f, 0.0f, g_cellWidth, 0.0f/**sizeToFit sets the proper height*/);
    if(explanation.title) {
        self->introLabel.frame = baseRect;
        self->introLabel.text = explanation.title;
        [self->introLabel setHidden:NO];
        [self->introLabel sizeToFit];
    } else {
        [self->introLabel setHidden:YES];
        self->introLabel.text = @"";
    }
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    UIFont *questionFont = [styleGuide getFont:NormalPreferredFont];
    self->questionLabel.font = questionFont;
    self->questionLabel.frame = baseRect;
    NSString *explanationPreviewText = [LayAbstractCell previewTextForExplanation:explanation];
    self->questionLabel.text = explanationPreviewText;
    [self->questionLabel sizeToFit];
    [self showMiniIconsForExplanation];
    [self layoutCell];

}

-(void)layoutCell {
    [LayVBoxLayout layoutVBoxSubviewsInView:self.contentView];
}

-(void)showMiniIconsForQuestion {
    if([self->question isFavourite]) {
        [self->miniIconBar show:YES miniIcon:MINI_FAVOURITE];
    } else {
        [self->miniIconBar show:NO miniIcon:MINI_FAVOURITE];
    }
    
    if([self->question hasLinkedResources]) {
        [self->miniIconBar show:YES miniIcon:MINI_RESOURCE];
    } else {
        [self->miniIconBar show:NO miniIcon:MINI_RESOURCE];
    }
    
    if([self->question hasLinkedNotes]) {
        [self->miniIconBar show:YES miniIcon:MINI_NOTE];
    } else {
        [self->miniIconBar show:NO miniIcon:MINI_NOTE];
    }
    
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    if([self->question caseNumberPrimitive] == UGC_BOX_CASE_NOT_ANSWERED_QUESTION) {
        UIColor *learnStateColor = [styleGuide getColor:ButtonBorderColor];
        [self->miniIconBar setLearnStateIconColor:learnStateColor];
    } else if([self->question caseNumberPrimitive] == UGC_BOX_CASE1) {
        UIColor *learnStateColor = [styleGuide getColor:AnswerWrong];
        [self->miniIconBar setLearnStateIconColor:learnStateColor];
    } else if([self->question caseNumberPrimitive] == UGC_BOX_CASE2) {
        UIColor *learnStateColor = [styleGuide getColor:MemoBad];
        [self->miniIconBar setLearnStateIconColor:learnStateColor];
    } else if([self->question caseNumberPrimitive] == UGC_BOX_CASE3) {
        UIColor *learnStateColor = [styleGuide getColor:MemoWell];
        [self->miniIconBar setLearnStateIconColor:learnStateColor];
    } else if([self->question caseNumberPrimitive] == UGC_BOX_CASE4) {
        UIColor *learnStateColor = [styleGuide getColor:MemoGood];
        [self->miniIconBar setLearnStateIconColor:learnStateColor];
    } else if([self->question caseNumberPrimitive] == UGC_BOX_CASE5) {
        UIColor *learnStateColor = [styleGuide getColor:AnswerCorrect];
        [self->miniIconBar setLearnStateIconColor:learnStateColor];
    }
    
    [self->miniIconBar show:YES miniIcon:MINI_LEARN_STATE];
}

-(void)showMiniIconsForExplanation {
    if([self->explanation hasLinkedResources]) {
        [self->miniIconBar show:YES miniIcon:MINI_RESOURCE];
    } else {
        [self->miniIconBar show:NO miniIcon:MINI_RESOURCE];
    }
    
    if([self->explanation hasLinkedNotes]) {
        [self->miniIconBar show:YES miniIcon:MINI_NOTE];
    } else {
        [self->miniIconBar show:NO miniIcon:MINI_NOTE];
    }
}

@end

//
//
//
@implementation HeaderLabel
@synthesize spaceAbove, keepWidth, border;
@end

@implementation IntroLabel
@synthesize spaceAbove, keepWidth, border;
@end

@implementation AbstractCellQuestionLabel
@synthesize spaceAbove, keepWidth, border;
@end

@implementation MediaViewContainer

static const CGFloat SPACE_BETWEEN_MEDIA = 10.0f;
@synthesize spaceAbove, keepWidth, border;

-(id)initWithFrame:(CGRect)frame {
    self = [super  initWithFrame:frame];
    if(self) {
    }
    return self;
}

+(CGFloat)addMediaData:(NSArray*)mediaDataArray toView:(UIView*)view {
    CGFloat highestMedia = 0.0f;
    CGFloat widthInUse = 0.0f;
    for (LayMediaData* mediaData in mediaDataArray) {
        CGRect mediaFrame = CGRectMake(widthInUse, 0.0f, g_cellWidth, g_HEIGHT_MEDIA_CONTAINER);
        LayMediaView *mediaView = [[LayMediaView alloc]initWithFrame:mediaFrame andMediaData:mediaData];
        mediaView.ignoreEvents = YES;
        mediaView.fitToContent = YES;
        [mediaView layoutMediaView];
        CGFloat mediaViewWidth = mediaView.frame.size.width;
        if(widthInUse + SPACE_BETWEEN_MEDIA + mediaViewWidth <= g_cellWidth) {
            if(view) {
                [view addSubview:mediaView];
            }
            widthInUse += mediaViewWidth + SPACE_BETWEEN_MEDIA;
            if(highestMedia < mediaView.frame.size.height) {
                highestMedia = mediaView.frame.size.height;
            }
        } else {
            break;
        }
    }
    return highestMedia;
}

-(void)resetContainer {
    for (UIView* subView in self.subviews) {
        if([subView isKindOfClass:[LayMediaView class]]) {
            [subView removeFromSuperview];
        }
    }
}

-(void)layoutContainer {
    CGFloat xPosCurrentMiddle = g_cellWidth / [self.subviews count] + 1;
    for (UIView *subView in self.subviews) {
        CGRect frame = subView.frame;
        CGFloat xPosCurrent = xPosCurrentMiddle - frame.size.width/2;
        frame.origin.x = xPosCurrent;
        subView.frame = frame;
        xPosCurrentMiddle += xPosCurrentMiddle;
    }
}

@end
