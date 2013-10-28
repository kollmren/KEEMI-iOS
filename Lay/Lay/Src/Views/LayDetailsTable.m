//
//  LayTwoColumnTable.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 20.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayDetailsTable.h"
#import "LayFrame.h"
#import "LayVBoxLayout.h"
#import "LayStyleGuide.h"
#import "LayPair.h"


static const CGFloat DEFAULT_INDENT = 5.0f;
static const CGFloat DEFAULT_H_SPACE = 15.0f;
static const CGFloat DEFAULT_V_SPACE = 5.0f;

@interface LayDetailsTable() {
    UIFont *font;
    UIView *detailTable;
}

@end

@implementation LayDetailsTable

@synthesize hColumnSpace, vRowSpace;

-(id) initWithDictionary:(NSDictionary*)details frame:(CGRect)frame andFont:(UIFont*)font_ {
    const NSUInteger numberOfEntries = [[details allKeys]count];
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:numberOfEntries];
    for (NSString* key in [details allKeys]) {
        LayPair *pair = [LayPair new];
        pair.first = key;
        pair.second = [details objectForKey:key];
        [list addObject:pair];
    }
    return [self initWithArray:list frame:frame andFont:font_];
}

-(id)initWithArray:(NSArray*)tableData frame:(CGRect)frame andFont:(UIFont*)font_ {
    self = [super initWithFrame:frame];
    if(self) {
        self->font = font_;
        hColumnSpace = DEFAULT_H_SPACE;
        self.vRowSpace = DEFAULT_V_SPACE;
        [self setupView:tableData];
        [self layoutView];
    }
    return self;
}

//
// Private
//

-(void)setupView:(NSArray*)detailList {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGSize tableFrameSize = self.frame.size;
    // Data / At first setup the views styles and data and calculate the proper size
    const CGFloat widthOfBorder = [styleGuide getBorderWidth:NormalBorder];
    self.layer.borderColor = [styleGuide getColor:ButtonBorderColor].CGColor;
    self.layer.borderWidth = widthOfBorder;
    const CGFloat widthOfDetailTable = tableFrameSize.width-2*widthOfBorder;
    const CGRect detailTableFrame = CGRectMake(widthOfBorder, 0.0f, widthOfDetailTable, 0.0f);
    const CGRect detailRowFrame = CGRectMake(0.0f, 0.0f, widthOfDetailTable, 0.0f);
    const CGRect defaultLabelFrame = CGRectMake(DEFAULT_INDENT, 0.0f, widthOfDetailTable, 0.0f);
    self->detailTable = [[UIView alloc]initWithFrame:detailTableFrame];
    BOOL firstRow = YES;
    CGFloat highestWidthForDetail = 0.0f;
    for (LayPair* pair in detailList) {
        // dont show empty values
        if(!pair.second) continue;
        
        UIView *row = [[UIView alloc]initWithFrame:detailRowFrame];
        UILabel* detail = [[UILabel alloc]initWithFrame:defaultLabelFrame];
        [self applyStyle:detail];
        detail.text = pair.first;
        [detail sizeToFit];
        if(detail.frame.size.width > highestWidthForDetail) {
            highestWidthForDetail = detail.frame.size.width;
        }
        UILabel* value = [[UILabel alloc]initWithFrame:defaultLabelFrame];
        [self applyStyle:value];
        value.text = pair.second;
        value.numberOfLines = [styleGuide numberOfLines];
        [row addSubview:detail];
        [row addSubview:value];
        if(firstRow) {
            row.backgroundColor = [styleGuide getColor:ListsFirstRowColor];
        } else {
            row.backgroundColor = [styleGuide getColor:ListsSecondRowColor];
        }
        [self->detailTable addSubview:row];
        firstRow = !firstRow;
    }
    [self adjustSizeOfColumnsTo:self->detailTable with:highestWidthForDetail];
    [self addSubview:self->detailTable];
}

-(void)adjustSizeOfColumnsTo:(UIView*)table with:(CGFloat)highestWidthForDetail {
    for (UIView* row in [table subviews]) {
        [self layoutRow:row withWidthOfFirstColumn:highestWidthForDetail];
    }
}

-(void)layoutRow:(UIView*)row withWidthOfFirstColumn:(CGFloat)firstColumnWidth {
    const CGFloat xPosSecondColumn = firstColumnWidth + self.hColumnSpace;
    const CGFloat widthOfValueColumn = row.frame.size.width - xPosSecondColumn;
    BOOL firstColumn = YES;
    const CGFloat vMargin = 4.0f;
    UIView *detailColumn = nil;
    for (UIView* column in [row subviews]) {
        if(!firstColumn) {
            [LayFrame setWidthWith:widthOfValueColumn toView:column];
            UILabel *value = (UILabel*)column;
            [value sizeToFit];
            const CGFloat newRowHeight = value.frame.size.height + 2*vMargin;
            [LayFrame setHeightWith:newRowHeight toView:row animated:NO];
            [LayFrame setYPos:vMargin toView:detailColumn];
            [LayFrame setYPos:vMargin toView:value];
            [LayFrame setXPos:xPosSecondColumn toView:column];
        } else {
            detailColumn = column;
        }
        firstColumn = !firstColumn;
    }
}

-(void)layoutView {
    CGFloat neededHeightOfTable = [LayVBoxLayout layoutSubviewsOfView:self->detailTable withSpace:0.0f];
    [LayFrame setHeightWith:neededHeightOfTable toView:self->detailTable animated:NO];
    CGFloat neededHeightOfView = [LayVBoxLayout layoutSubviewsOfView:self withSpace:0.0f];
    [LayFrame setHeightWith:neededHeightOfView toView:self animated:NO];
}

-(void)applyStyle:(UILabel*)label {
    label.font = self->font;
    label.backgroundColor = [UIColor clearColor];
}

@end
