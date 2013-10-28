//
//  LYAnimatorBase.m
//  AdvancedTableViewCells
//
//  Created by Luis Remirez on 30.01.13.
//
//

#import "LayAnimator.h"

@implementation LayAnimator

static BOOL __animationIsEnabled = TRUE;

@synthesize duration;

+(void) enableAnimation:(BOOL)enable {
    __animationIsEnabled = enable;
}

-(id) initWithView:(UIView*)_view {
    return [self initWithView:_view andDuration:1.0];
}

-(id) initWithView:(UIView*)_view andDuration:(float)_duration {
    self = [super init];
    self->view = _view;
    self.duration = _duration;
    self->parallelAnimator = [NSMutableArray new];
    self.removeViewAfterOperation = false;
    return self;
} 

-(bool) beforeStartAnimation {
    return true;
}

-(void) startAnimation {
    if([self beforeStartAnimation]) {
        if(__animationIsEnabled) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:self.duration];
        }
        
        [self doStart];
        
        for(LayAnimator* sibling in self->parallelAnimator) {
            [sibling doStart];
        }
        if(__animationIsEnabled) {
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(startAnimationCompleted)];
            [UIView commitAnimations];
        } else {
            [self startAnimationCompleted];
        }
    }
}

-(void) startAnimationCompleted {
    if(afterAnimation!=nil) {
        [afterAnimation startAnimation];
    }
}

-(bool) beforeEndAnimation {
    return true;
}

-(void) endAnimation {
    if([self beforeEndAnimation]) {
        if(__animationIsEnabled) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:self.duration];
        }
        
        [self doEnd];
        for(LayAnimator* sibling in self->parallelAnimator) {
            [sibling doEnd];
        }
        
        if(__animationIsEnabled) {
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(endAnimationCompleted)];
            [UIView commitAnimations];
        } else {
            [self endAnimationCompleted];
        }
    }
}

-(void) endAnimationCompleted {
    if(self->afterAnimation) {
        [self->afterAnimation endAnimation];
    }
    if(self.removeViewAfterOperation) {
        [view removeFromSuperview];
    }
}

-(void) setAfterAnimator:(LayAnimator *)_s {
    self->afterAnimation = _s;
}

-(void) addParallelAnimator:(LayAnimator*)_parallelAnimation {
    [self->parallelAnimator addObject:_parallelAnimation];
}

-(void) doStart {
}

-(void) doEnd {
}

@end
