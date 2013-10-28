//
//  LayMInimizeAnimator.h
//  Lay
//
//  Created by Luis Remirez on 10.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayAnimator.h"

@interface LayMinimizeAnimator : LayAnimator {
    UIView* maximizedView;
    UIView* minimizedView;
    CGRect maximizedSize;
    CGRect minimizedSize;
    bool maximized;
}

-(id) initWithView:(UIView*)view andMinimizedView:(UIView*)minimizedView_ andMaximizedView:(UIView*)maximizedView_ duration:(float)duration_ isMaximized:(bool)maximized_;
-(void) rescan;


@end
