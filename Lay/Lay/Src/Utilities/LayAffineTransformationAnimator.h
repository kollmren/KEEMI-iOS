//
//  LYAffineTransformationAnimator.h
//  AdvancedTableViewCells
//
//  Created by Luis Remirez on 30.01.13.
//
//

#import "LayAnimator.h"

@interface LayAffineTransformationAnimator : LayAnimator {
    CGAffineTransform transformation;
}

-(id) initWithView:(UIView *)view duration:(float)duration andTransformation:(CGAffineTransform)_transformation;

@end
