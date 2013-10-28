//
//  LayMInimizeAnimator.m
//  Lay
//
//  Created by Luis Remirez on 10.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayMinimizeAnimator.h"

@implementation LayMinimizeAnimator

-(id) initWithView:(UIView*)view_ andMinimizedView:(UIView*)minimizedView_ andMaximizedView:(UIView*)maximizedView_ duration:(float)duration_ isMaximized:(bool)maximized_ {
    self = [super initWithView:view_ andDuration:duration_];
    minimizedView = minimizedView_;
    maximizedView = maximizedView_;
    minimizedSize = minimizedView.frame;
    maximizedSize = maximizedView_.frame;
    maximized = maximized_;
    if(maximized) {
        minimizedView.alpha = 0.0;
        maximizedView.alpha = 1.0;
    } else {
        minimizedView.alpha = 1.0;
        maximizedView.alpha = 0.0;        
    }
    return self;
}

-(void) rescan {
    minimizedSize = minimizedView.frame;
    maximizedSize = maximizedView.frame;
    maximized = maximizedView.alpha == 1.0;
}

-(void) doStart {
    if(maximized) {
        maximizedView.frame = minimizedSize;
    }
}

-(bool) beforeStartAnimation {
    return maximized;
}

-(void) startAnimationCompleted {
    if(maximized) {
        minimizedView.alpha = 1.0;
        maximizedView.alpha = 0.0;
        CGRect frame = view.frame;
        frame.size = minimizedSize.size;
        view.frame = frame;
        maximized = false;
    }
    //[super performSelector:@selector(startAnimationCompleted)];
}

-(bool) beforeEndAnimation {
    if(!maximized) {
        minimizedView.alpha = 0.0;
        maximizedView.alpha = 1.0;
    }
    return !maximized;
}

-(void) doEnd {
    if(!maximized) {
        maximizedView.frame = maximizedSize;
    }
}

-(void) endAnimationCompleted {
    if(!maximized) {
        CGRect frame = view.frame;
        frame.size = maximizedSize.size;
        view.frame = frame;
        maximized = true;
    }
    //[super performSelector:@selector(endAnimationCompleted)];
}

@end
