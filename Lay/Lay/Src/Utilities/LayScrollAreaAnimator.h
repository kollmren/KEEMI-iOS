//
//  LYScrollAreaAnimator.h
//  AdvancedTableViewCells
//
//  Created by Luis Remirez on 31.01.13.
//
//

#import "LayAnimator.h"

@interface LayScrollAreaAnimator : LayAnimator {
@protected BOOL partialArea;
@protected UIScrollView* scrollView;
@protected CGRect formerScrollViewRect;
@protected float formerZoomScale;
@protected CGRect targetRect;
@protected CGRect formerRect;
@protected CGRect targetImageRect;
@protected CGRect formerImageRect;
@protected CGRect zoomArea;
}

-(id) initWithScrollArea:(UIScrollView*)_scrollView view:(UIView*)_view duration:(float)_duration zoomArea:(CGRect)_zoomArea andFactor:(float)_factor;

-(id) initWithScrollArea:(UIScrollView*)_scrollView view:(UIView*)_view duration:(float)_duration zoomArea:(CGRect)_zoomArea factor:(float)_factor origin:(CGPoint)origin andScalar:(float)scalar;

-(id) initWithScrollArea:(UIScrollView*)_scrollView view:(UIView*)_view duration:(float)_duration zoomArea:(CGRect)_zoomArea factor:(float)_factor andTargetRect:(CGRect)targetRect;

@end
