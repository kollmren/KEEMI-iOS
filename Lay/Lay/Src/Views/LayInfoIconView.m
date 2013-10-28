//
//  LayInfoIconView.m
//  Lay
//
//  Created by Rene Kollmorgen on 15.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayInfoIconView.h"
#import "LayImage.h"
#import "LayStyleGuide.h"

static const CGFloat BORDER = 3.0f;

@implementation LayInfoIconView

+ (LayInfoIconView*)iconWithBackground {
    return  [[LayInfoIconView alloc]init:YES];
}

+ (LayInfoIconView*)icon {
    return  [[LayInfoIconView alloc]init:NO];
}

- (id)init:(BOOL)withBackground {
    self = [super init];
    if(self) {
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        UIImage *iconImage = [LayImage imageWithId:LAY_IMAGE_INFO_HINT];
        CALayer *iconLayer  = [[CALayer alloc]init];
        iconLayer.contentsGravity = kCAGravityResizeAspect;
        CGImageRef iconRef = [iconImage CGImage];
        [iconLayer setContents:(__bridge id)(iconRef)];
        CGSize newViewSize = [styleGuide iconButtonSize];
        if(withBackground) {
            [self set:iconLayer frameSize:newViewSize x:BORDER/2 y:BORDER/2];
            CALayer *background = [[CALayer alloc]init];
            newViewSize = CGSizeMake(newViewSize.width + BORDER, newViewSize.height + BORDER );
            [self set:background frameSize:newViewSize];
            background.backgroundColor =  [styleGuide getColor:GrayTransparentBackground].CGColor;
            background.cornerRadius = 5.0f;
            [self.layer addSublayer:background];
        } else {
            [self set:iconLayer frameSize:newViewSize];
        }
        [self.layer addSublayer:iconLayer];
        CGRect viewFrame = self.frame;
        viewFrame.size = newViewSize;
        self.frame = viewFrame;
    }
    return self;
}

-(void)set:(CALayer*)layer frameSize:(CGSize)size {
    CGRect frame = layer.frame;
    frame.size = size;
    layer.frame = frame;
}

-(void)set:(CALayer*)layer frameSize:(CGSize)size x:(CGFloat)xPos y:(CGFloat)yPos {
    CGRect frame = layer.frame;
    frame.size = size;
    frame.origin.x = xPos;
    frame.origin.y = yPos;
    layer.frame = frame;
}

@end
