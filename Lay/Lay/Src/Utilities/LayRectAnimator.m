//
//  LYRectAnimator.m
//  AdvancedTableViewCells
//
//  Created by Luis Remirez on 30.01.13.
//
//

#import "LayRectAnimator.h"

@implementation LayRectAnimator

-(id) initWithView:(UIView *)_view duration:(float)_duration andTargetPoint:(CGPoint)_targetPoint {
    CGRect rect = CGRectMake(_targetPoint.x, _targetPoint.y, _view.frame.size.width, _view.frame.size.height);
    return [self initWithView:_view duration:_duration andTargetRect:rect];
}

-(id) initWithView:(UIView *)_view duration:(float)_duration andTargetRect:(CGRect)_targetRect {
    self = [super initWithView:_view andDuration:_duration];
    self->targetRect = _targetRect;
    self->startRect = view.frame;
    return self;
}

-(void) doStart {
    view.frame = targetRect;
}

-(void) doEnd {
    view.frame = startRect;
}

@end
