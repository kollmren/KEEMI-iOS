//
//  LayStyleGuide.m
//  Lay
//
//  Created by Luis Remirez on 08.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayStyleGuide.h"

static const CGSize LAY_BUTTON_SIZE = {44.0f , 44.0f};
static const CGFloat ROUNDED_BORDER_RADIUS = 10.0f;

@interface LayStyleGuide() {
    NSMutableDictionary* colors;
    NSMutableDictionary* fonts;
    NSMutableDictionary* borderWidths;
}

@end

@implementation LayStyleGuide

static LayStyleGuide *singleton = nil;

+ (LayStyleGuide *)instanceOf:(NSString*)type{
    if (singleton == nil) {
        singleton = [LayStyleGuide new];
        [singleton loadColors];
        [singleton loadFonts];
        [singleton loadBorderWidths];
    }
    return singleton;
}

-(void) loadColors {
    singleton->colors = [[NSMutableDictionary alloc] init];
    [singleton->colors setValue:[UIColor colorWithRed:0.91 green:0.48 blue:0.18 alpha:1.0] forKey:[[NSNumber numberWithInt:AdditionalInfoColor] stringValue]];
    [singleton->colors setValue:[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:0.9] forKey:[[NSNumber numberWithInt:ButtonBorderColor] stringValue]];
    [singleton->colors setValue:[UIColor colorWithRed:0.0 green:0.48 blue:0.71 alpha:1.0] forKey:[[NSNumber numberWithInt:ButtonSelectedColor] stringValue]];
    [singleton->colors setValue:[UIColor colorWithRed:0.0 green:0.48 blue:0.71 alpha:0.2] forKey:[[NSNumber numberWithInt:ButtonSelectedBackgroundColor] stringValue]];
    
    [singleton->colors setValue:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forKey:[[NSNumber numberWithInt:WhiteBackground] stringValue]];
    [singleton->colors setValue:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.8] forKey:[[NSNumber numberWithInt:GrayTransparentBackground] stringValue]];
 [singleton->colors setValue:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.95] forKey:[[NSNumber numberWithInt:WhiteTransparentBackground] stringValue]];
    [singleton->colors setValue:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6] forKey:[[NSNumber numberWithInt:BlackBackground] stringValue]];
    [singleton->colors setValue:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.6] forKey:[[NSNumber numberWithInt:ListsFirstRowColor] stringValue]];
    [singleton->colors setValue:[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.2] forKey:[[NSNumber numberWithInt:ListsSecondRowColor] stringValue]];
    [singleton->colors setValue:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.6] forKey:[[NSNumber numberWithInt:InfoBackgroundColor] stringValue]];
    [singleton->colors setValue:[UIColor colorWithRed:0.8 green:0.3 blue:0.3 alpha:7.0] forKey:[[NSNumber numberWithInt:AnswerWrong] stringValue]];
    [singleton->colors setValue:[UIColor colorWithRed:49.0/255.0  green:169.0/255.0 blue:13.0/255.0 alpha:7.0] forKey:[[NSNumber numberWithInt:AnswerCorrect] stringValue]];
    [singleton->colors setValue:[UIColor colorWithRed:0.91 green:0.48 blue:0.18 alpha:1.0] forKey:[[NSNumber numberWithInt:MemoBad] stringValue]];
    [singleton->colors setValue:[UIColor colorWithRed:0.42  green:0.80 blue:0.11 alpha:1.0] forKey:[[NSNumber numberWithInt:MemoGood] stringValue]];
    [singleton->colors setValue:[UIColor colorWithRed:0.69  green:0.57 blue:0.12 alpha:1.0] forKey:[[NSNumber numberWithInt:MemoWell] stringValue]];
    [singleton->colors setValue:[UIColor darkTextColor] forKey:[[NSNumber numberWithInt:TextColor] stringValue]];
    [singleton->colors setValue:[UIColor whiteColor] forKey:[[NSNumber numberWithInt:BackgroundColor] stringValue]];
}

-(void) loadFonts {
    singleton->fonts = [[NSMutableDictionary alloc] init];
    UIFont *font = [UIFont systemFontOfSize:28.0f];
    [singleton->fonts setValue:font forKey:[[NSNumber numberWithInt:HintFont] stringValue]];
    font = [UIFont systemFontOfSize:16.0f];
    [singleton->fonts setValue:font forKey:[[NSNumber numberWithInt:AppTitleFont] stringValue]];
    font = [UIFont systemFontOfSize:16.0f];
    [singleton->fonts setValue:font forKey:[[NSNumber numberWithInt:NormalFont] stringValue]];
    font = [UIFont systemFontOfSize:14.0f];
    [singleton->fonts setValue:font forKey:[[NSNumber numberWithInt:SubInfoFont] stringValue]];
    font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [singleton->fonts setValue:font forKey:[[NSNumber numberWithInt:NormalPreferredFont] stringValue]];
    font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    [singleton->fonts setValue:font forKey:[[NSNumber numberWithInt:SmallPreferredFont] stringValue]];
    font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    [singleton->fonts setValue:font forKey:[[NSNumber numberWithInt:TitlePreferredFont] stringValue]];
    font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [singleton->fonts setValue:font forKey:[[NSNumber numberWithInt:HeaderPreferredFont] stringValue]];
    font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [singleton->fonts setValue:font forKey:[[NSNumber numberWithInt:SubHeaderPreferredFont] stringValue]];
    font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    [singleton->fonts setValue:font  forKey:[[NSNumber numberWithInt:SmallFont] stringValue]];
    font = [UIFont systemFontOfSize:10.0f];
    [singleton->fonts setValue:font  forKey:[[NSNumber numberWithInt:LabelFont] stringValue]];
    font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    [singleton->fonts setValue:font  forKey:[[NSNumber numberWithInt:SectionFont] stringValue]];
}

-(void)updatePreferredFonts {
    // update NormalPreferredFont
    NSNumber *key = [NSNumber numberWithInt:NormalPreferredFont];
    [singleton->fonts removeObjectForKey:key];
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [singleton->fonts setValue:font forKey:[[NSNumber numberWithInt:NormalPreferredFont] stringValue]];
    //
    key = [NSNumber numberWithInt:TitlePreferredFont];
    [singleton->fonts removeObjectForKey:key];
    font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    [singleton->fonts setValue:font forKey:[[NSNumber numberWithInt:TitlePreferredFont] stringValue]];
    //
    key = [NSNumber numberWithInt:HeaderPreferredFont];
    [singleton->fonts removeObjectForKey:key];
    font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [singleton->fonts setValue:font forKey:[[NSNumber numberWithInt:HeaderPreferredFont] stringValue]];
    //
    key = [NSNumber numberWithInt:SubHeaderPreferredFont];
    [singleton->fonts removeObjectForKey:key];
    font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [singleton->fonts setValue:font forKey:[[NSNumber numberWithInt:SubHeaderPreferredFont] stringValue]];
    //
    key = [NSNumber numberWithInt:SmallPreferredFont];
    [singleton->fonts removeObjectForKey:key];
    font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    [singleton->fonts setValue:font forKey:[[NSNumber numberWithInt:SmallPreferredFont] stringValue]];
}

-(void)loadBorderWidths {
    singleton->borderWidths = [[NSMutableDictionary alloc] init];
    [singleton->borderWidths setValue:[NSNumber numberWithFloat:0.0f] forKey:[[NSNumber numberWithInt:NoBorder] stringValue]];
    [singleton->borderWidths setValue:[NSNumber numberWithFloat:1.0f] forKey:[[NSNumber numberWithInt:NormalBorder] stringValue]];
    [singleton->borderWidths setValue:[NSNumber numberWithFloat:2.0f] forKey:[[NSNumber numberWithInt:SelectedButtonBorder] stringValue]];
}


-(UIColor*) getColor:(LayStyleGuideColor)color {
    if(color == ClearColor) return [UIColor clearColor];
    
    NSString* key = [[NSNumber numberWithInt:color] stringValue];
    return [colors objectForKey:key];
}

-(UIFont*) getFont:(LayStyleGuideFont)font {
    if(font == NoFont) return nil;
    
    NSString* key = [[NSNumber numberWithInt:font] stringValue];
    UIFont* font_ = [fonts objectForKey:key];
    return font_;
}

-(CGFloat) getBorderWidth:(LayStyleGuideBorderWidth)borderStyle {
    NSString* key = [[NSNumber numberWithInt:borderStyle] stringValue];
    NSNumber *value = [borderWidths objectForKey:key];
    CGFloat valuePrimitive = [value floatValue];
    return valuePrimitive;
}

-(CGFloat) getHorizontalScreenSpace {
    const CGFloat horizontalScreenSpace = 8.0f;
    return horizontalScreenSpace;
}


-(CGFloat)getRoundedBorderRadius {
    return ROUNDED_BORDER_RADIUS;
}

-(CGFloat)getDefaultButtonHeight {
    return 50.0f;
}


-(void) makeBorder:(UIView*)view {
    [self makeRoundedBorder:view withBackgroundColor:NoColor andBorderColor:ButtonBorderColor andRadius:0.0];
}

-(void) makeBorder:(UIView*)view withBackgroundColor:(LayStyleGuideColor)color {
    [self makeRoundedBorder:view withBackgroundColor:color andBorderColor:ButtonBorderColor andRadius:0.0];
}

-(void) makeBorder:(UIView*)view withBackgroundColor:(LayStyleGuideColor)color andBorderColor:(LayStyleGuideColor)border {
    if(color!=NoColor) {
        view.backgroundColor = [self getColor:color];
    }
    view.layer.cornerRadius = 0.0f;
    view.layer.borderWidth = [self getBorderWidth:SelectedButtonBorder];
    view.layer.borderColor = [self getColor:border].CGColor;
}

-(void) makeRoundedBorder:(UIView*)view withBackgroundColor:(LayStyleGuideColor)color {
    [self makeRoundedBorder:view withBackgroundColor:color andBorderColor:ButtonBorderColor andRadius:ROUNDED_BORDER_RADIUS];
}

-(void) makeRoundedBorder:(UIView*)view withBackgroundColor:(LayStyleGuideColor)color andBorderColor:(LayStyleGuideColor)border {
    [self makeRoundedBorder:view withBackgroundColor:color andBorderColor:border andRadius:ROUNDED_BORDER_RADIUS];
}

-(void) makeRoundedBorder:(UIView*)view withBackgroundColor:(LayStyleGuideColor)color andBorderColor:(LayStyleGuideColor)border andRadius:(float)radius {
    if(color!=NoColor) {
        view.backgroundColor = [self getColor:color];
    }
    view.layer.cornerRadius = radius;
    view.layer.borderWidth = [self getBorderWidth:NormalBorder];
    view.layer.borderColor = [self getColor:border].CGColor;
}

-(CGSize)buttonSize {
    return LAY_BUTTON_SIZE;
}

-(CGFloat)buttonIndentVertical {
    return 15.0f;
}

-(CGSize )iconButtonSize {
    CGSize size = { 24.0f, 24.0f };
    return size;
}

-(CGFloat) heightOfSection {
    return 45.0f;
}

-(CGFloat) maxHeightOfAnswerButton {
    return 150.0f;
}

-(NSUInteger)numberOfLines {
    return 0;
}

-(CGFloat)maxRibbonHeight {
    static const CGFloat maxHeightOfRibbon = 190.0f;
    return maxHeightOfRibbon;
}

-(CGSize)maxRibbonEntrySize {
    // 304 = 320 -  2 * 8(styleGuide getHorizontalScreenSpace)
    const CGSize SIZE_RIBBON_ENTRY = {304, 170.0};
    return SIZE_RIBBON_ENTRY;
}

-(CGSize)coverMediaSize {
    return CGSizeMake(100.0f, 100.0f);
}

-(CGFloat)heightOfStatusAnsNavigationBar {
    return 20.0f + 44.0f;
}

-(CGFloat)heightOfNavigationBar {
    return 44.0f;
}

-(CGFloat)screenwidth {
    const CGFloat screenWidth = [[UIApplication sharedApplication] statusBarFrame].size.width;
    return screenWidth;
}

@end