//
//  LYRectAnimator.h
//  AdvancedTableViewCells
//
//  Created by Luis Remirez on 30.01.13.
//
//

#import "LayAnimator.h"

@interface LayRectAnimator : LayAnimator {
@protected CGRect targetRect;
@protected CGRect startRect;
}

-(id) initWithView:(UIView *)view duration:(float)duration andTargetPoint:(CGPoint)_targetPoint;
-(id) initWithView:(UIView *)view duration:(float)duration andTargetRect:(CGRect)_targetRect;

@end
