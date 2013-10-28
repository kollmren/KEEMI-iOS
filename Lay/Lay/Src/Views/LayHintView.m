//
//  LayHintView.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 05.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayHintView.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"

@interface LayHintView() {
    UIView *superView;
    id target;
    SEL action;
}
@end


@implementation LayHintView

@synthesize duration;

- (id)initWithWidth:(CGFloat)width view:(UIView*)superView_ target:(id)target_ andAction:(SEL)action_
{
    const CGRect frame = CGRectMake(0.0f, 0.0f, width, 0.0f);
    self = [super initWithFrame:frame];
    if (self) {
        self->superView = superView_;
        self->target = target_;
        self->action = action_;
        self.duration = 0.5f;
    }
    return self;
}

-(void) showHint:(NSString*)hint withBorderColor:(LayStyleGuideColor)borderColor {
    static const CGFloat vSpace = 10.0f;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGRect viewFrame = self.frame;
    const CGRect statusMessageFrame = CGRectMake(hSpace, 0.0f, viewFrame.size.width-2*hSpace, 0.0);
    UIView *hintContainer = [[UIView alloc]initWithFrame:statusMessageFrame];
    UILabel *deletedCatalogHint = [[UILabel alloc]initWithFrame:statusMessageFrame];
    deletedCatalogHint.numberOfLines = 10;
    deletedCatalogHint.font = [styleGuide getFont:HintFont];
    deletedCatalogHint.text = hint;
    [deletedCatalogHint sizeToFit];
    [hintContainer addSubview:deletedCatalogHint];
    const CGSize hintLabelSize = deletedCatalogHint.frame.size;
    const CGFloat heightOfHint = hintLabelSize.height + 2*vSpace;
    const CGFloat widthOfHint = hintLabelSize.width + 2*hSpace;
    [LayFrame setSizeWith:CGSizeMake(widthOfHint, heightOfHint) toView:hintContainer];
    [LayFrame setYPos:vSpace toView:deletedCatalogHint];
    [styleGuide makeBorder:hintContainer withBackgroundColor:WhiteBackground andBorderColor:borderColor];
    [self addSubview:hintContainer];
    UIWindow *window = self->superView.window;
    hintContainer.center = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
    if(window) {
        [window addSubview:self];
        [NSTimer scheduledTimerWithTimeInterval:self.duration target:self selector:@selector(fadeOut) userInfo:nil repeats:NO];
    }
}

-(void)fadeOut {
    CABasicAnimation *animation = [CABasicAnimation
                                   animationWithKeyPath:@"opacity"];
    [animation setFromValue:[NSNumber numberWithFloat:1.0f]];
    const CGFloat toOpacityValueFloat = 0.0f;
    NSNumber *toOpacityValue = [NSNumber numberWithFloat:toOpacityValueFloat];
    [animation setToValue:toOpacityValue];
    [animation setDuration:0.5f];
    CALayer *layer = self.layer;
    [CATransaction begin];
    [CATransaction setCompletionBlock:^(void)
     {
         [self removeFromSuperview];
         if(self->target) {
             [self->target performSelector:self->action];
         }
     }];
    layer.opacity = 0.0f;
    [layer addAnimation:animation forKey:@"hide"];
    [CATransaction commit];
}

@end
