//
//  LYscrollViewAnimator.m
//  AdvancedTableViewCells
//
//  Created by Luis Remirez on 31.01.13.
//
//

#import "LayScrollAreaAnimator.h"

@implementation LayScrollAreaAnimator

-(id) initWithScrollArea:(UIScrollView*)_scrollView view:(UIView*)_view duration:(float)_duration zoomArea:(CGRect)_zoomArea andFactor:(float)_factor {
    CGRect rect = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width/3, _scrollView.frame.size.height/3);
    return [self initWithScrollArea:_scrollView view:_view duration:_duration zoomArea:_zoomArea factor:_factor andTargetRect:rect];
}

-(id) initWithScrollArea:(UIScrollView*)_scrollView view:(UIView*)_view duration:(float)_duration zoomArea:(CGRect)_zoomArea factor:(float)_factor origin:(CGPoint)origin andScalar:(float)scalar {
    CGRect rect = CGRectMake(origin.x, origin.y, _scrollView.frame.size.width/scalar, _scrollView.frame.size.height/scalar);
    return [self initWithScrollArea:_scrollView view:_view duration:_duration zoomArea:_zoomArea factor:_factor andTargetRect:rect];
}

-(id) initWithScrollArea:(UIScrollView*)_scrollView view:(UIView*)_view duration:(float)_duration zoomArea:(CGRect)_zoomArea factor:(float)_factor andTargetRect:(CGRect)_targetRect {
    self = [super initWithView:_view andDuration:_duration];

    scrollView = _scrollView;
    partialArea = _factor>1.0;
    
    targetRect = _targetRect;
    formerImageRect = view.frame;
    targetImageRect = CGRectMake(formerImageRect.origin.x-_zoomArea.origin.x, formerImageRect.origin.y-_zoomArea.origin.y, formerImageRect.size.width, formerImageRect.size.height);
    zoomArea = _zoomArea;
    self.duration = partialArea?self.duration:self.duration/2.0;
    return self;
}

-(void) doStart {
    formerScrollViewRect = scrollView.frame;
    scrollView.frame = self->targetRect;
    
    if(partialArea) {
        view.frame = targetImageRect;
    } else {
        CGPoint contentOffset = scrollView.contentOffset;
        CGSize contentSize = scrollView.contentSize;
        formerZoomScale = scrollView.zoomScale;
        formerImageRect = CGRectMake(contentOffset.x, contentOffset.y, contentSize.width, contentSize.height);
    }
}

-(void) startAnimationCompleted {
    if(!partialArea) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:self.duration/2.0];
        [scrollView zoomToRect:zoomArea animated:NO];
        [UIView commitAnimations];
    }
}

-(void) doEnd {    
    if(partialArea) {
        scrollView.frame = formerScrollViewRect;
        view.frame = formerImageRect;
    } else {
        scrollView.contentOffset = formerImageRect.origin;
        scrollView.contentSize = formerImageRect.size;
    }
}

-(void) endAnimationCompleted {
    if(!partialArea) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:partialArea?self.duration:self.duration/2.0];
        scrollView.frame = formerScrollViewRect;
        scrollView.zoomScale = formerZoomScale;
        scrollView.contentOffset = formerImageRect.origin;
        [UIView commitAnimations];
    }
}

@end
