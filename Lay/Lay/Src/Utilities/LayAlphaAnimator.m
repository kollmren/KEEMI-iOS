//
//  LYAlphaAnimator.m
//  AdvancedTableViewCells
//
//  Created by Luis Remirez on 30.01.13.
//
//

#import "LayAlphaAnimator.h"

@implementation LayAlphaAnimator

-(id) initWithView:(UIView *)_view duration:(float)_duration andTargetAlpha:(float)_targetAlpha {
    self = [super initWithView:_view andDuration:_duration];
    self->targetAlpha = _targetAlpha;
    self->startAlpha = view.alpha;
    return self;
}

-(void) doStart {
    view.alpha = targetAlpha;
}

-(void) doEnd {
    view.alpha = startAlpha;
}

@end
