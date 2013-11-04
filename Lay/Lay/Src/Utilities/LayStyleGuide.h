//
//  LayStyleGuide.h
//  Lay
//
//  Created by Luis Remirez on 08.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NoColor,
    ClearColor,
    AdditionalInfoColor,
    WhiteBackground,
    WhiteTransparentBackground,
    GrayTransparentBackground,
    BlackBackground,
    ButtonBorderColor,
    ToolBarBackground,
    ButtonSelectedColor,
    ButtonSelectedBackgroundColor,
    InfoBackgroundColor,
    ListsFirstRowColor,
    ListsSecondRowColor,
    AnswerWrong,
    AnswerCorrect,
    MemoBad,
    MemoWell,
    MemoGood,
    TextColor,
    BackgroundColor
} LayStyleGuideColor;

typedef enum {
    NoFont,
    NormalFont, // for a question- and answer-text
    SubInfoFont,
    SmallFont, // for details of a catalog ...
    SectionFont,
    LabelFont,
    HintFont,
    AppTitleFont,
    NormalPreferredFont,
    TitlePreferredFont,
    HeaderPreferredFont,
    SubHeaderPreferredFont,
    SmallPreferredFont
} LayStyleGuideFont;

typedef enum {
    NoBorder,
    NormalBorder,
    SelectedButtonBorder,
} LayStyleGuideBorderWidth;

@interface LayStyleGuide : NSObject

+(LayStyleGuide*) instanceOf:(NSString*)type;

-(UIColor*) getColor:(LayStyleGuideColor)color;

-(UIFont*) getFont:(LayStyleGuideFont)font;

-(void)updatePreferredFonts;

-(CGFloat) getBorderWidth:(LayStyleGuideBorderWidth)borderStyle;

-(CGFloat) getHorizontalScreenSpace;

-(CGFloat)buttonIndentVertical;

-(CGFloat)getRoundedBorderRadius;

-(CGFloat)getDefaultButtonHeight;

-(void) makeBorder:(UIView*)view withBackgroundColor:(LayStyleGuideColor)color;
-(void) makeBorder:(UIView*)view withBackgroundColor:(LayStyleGuideColor)color andBorderColor:(LayStyleGuideColor)border;
-(void) makeRoundedBorder:(UIView*)view withBackgroundColor:(LayStyleGuideColor)color;
-(void) makeRoundedBorder:(UIView*)view withBackgroundColor:(LayStyleGuideColor)color andBorderColor:(LayStyleGuideColor)border;
-(void) makeRoundedBorder:(UIView*)view withBackgroundColor:(LayStyleGuideColor)color andBorderColor:(LayStyleGuideColor)border andRadius:(float)radius;

-(CGSize)buttonSize;

-(CGSize )iconButtonSize;

-(CGFloat) heightOfSection;

-(CGFloat) maxHeightOfAnswerButton;

-(NSUInteger)numberOfLines;

-(CGFloat)maxRibbonHeight;

-(CGSize)maxRibbonEntrySize;

-(CGSize)coverMediaSize;

-(CGFloat)heightOfStatusAnsNavigationBar;

-(CGFloat)screenwidth;

@end
