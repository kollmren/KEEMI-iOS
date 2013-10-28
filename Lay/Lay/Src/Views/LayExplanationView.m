//
//  LayExplanationView.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 19.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayExplanationView.h"
#import "LaySectionView.h"
#import "LayFrame.h"
#import "LayStyleGuide.h"

#import "Explanation+Utilities.h"
#import "Section+Utilities.h"

static const CGFloat V_SPACE_TITLE = 15.0f;

@implementation LayExplanationView

-(id)initWithFrame:(CGRect)frame andExplanation:(Explanation*)explanation;
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView:explanation];
    }
    return self;
}

-(void)setupView:(Explanation*)explanation {
    const CGFloat vIndent = 15.0f;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGRect titleFrame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 0.0f);
    UILabel *title = [[UILabel alloc]initWithFrame:titleFrame];
    title .numberOfLines = [styleGuide numberOfLines];
    title.backgroundColor = [UIColor clearColor];
    title.font = [styleGuide getFont:HeaderPreferredFont];
    title.text = explanation.title;
    title.textAlignment = NSTextAlignmentLeft;
    [title sizeToFit];
    [self addSubview:title];
    // add content
    CGFloat currentYPos = title.frame.origin.y + title.frame.size.height + vIndent;
    const CGRect sectionViewRect = CGRectMake(0.0f, currentYPos, self.frame.size.width, 0.0f);
    NSArray *sectionList = [explanation sectionList];
    LaySectionView *sectionView = [[LaySectionView alloc]initWithFrame:sectionViewRect andSectionList:sectionList];
    [self addSubview:sectionView];
    currentYPos += sectionView.frame.size.height;
    [LayFrame setHeightWith:currentYPos toView:self animated:NO];
}

@end
