//
//  LaySectionView.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 01.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayStyleGuide.h"

@interface LayTableSectionView : UIView

@property (nonatomic) NSString* title;
@property (nonatomic) LayStyleGuideColor borderColor;

- (id)initWithTitle:(NSString*)title andBorderColor:(LayStyleGuideColor)borderColor;

-(void)adjustToNewPreferredFont;

@end
