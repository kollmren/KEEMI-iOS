//
//  LYAffineTransformationAnimator.m
//  AdvancedTableViewCells
//
//  Created by Luis Remirez on 30.01.13.
//
//

#import "LayAffineTransformationAnimator.h"

@implementation LayAffineTransformationAnimator

-(id) initWithView:(UIView *)_view duration:(float)_duration andTransformation:(CGAffineTransform)_transformation {
    self = [super initWithView:_view andDuration:_duration];
    transformation = _transformation;
    return self;
}

-(void) doStart {
    view.transform = transformation;
}

-(void) doEnd {
    view.transform = CGAffineTransformIdentity;
}

@end
