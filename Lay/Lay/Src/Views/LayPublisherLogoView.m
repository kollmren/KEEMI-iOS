//
//  LayPublisherLogoView.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 27.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayPublisherLogoView.h"
#import "LayStyleGuide.h"

@implementation LayPublisherLogoView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        [styleGuide makeRoundedBorder:self withBackgroundColor:WhiteTransparentBackground andBorderColor:WhiteTransparentBackground];
        self.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

@end
