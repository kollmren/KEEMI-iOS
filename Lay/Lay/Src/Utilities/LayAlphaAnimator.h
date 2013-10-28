//
//  LYAlphaAnimator.h
//  AdvancedTableViewCells
//
//  Created by Luis Remirez on 30.01.13.
//
//

#import "LayAnimator.h"

@interface LayAlphaAnimator : LayAnimator {
@protected float targetAlpha;
@protected float startAlpha;
}

-(id) initWithView:(UIView *)view duration:(float)duration andTargetAlpha:(float)_targetAlpha;

@end
