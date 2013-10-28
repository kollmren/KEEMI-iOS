//
//  LYAnimatorBase.h
//  AdvancedTableViewCells
//
//  Created by Luis Remirez on 30.01.13.
//
//

#import <Foundation/Foundation.h>

@interface LayAnimator : NSObject {
@protected UIView* view;
@protected NSMutableArray* parallelAnimator;
@protected LayAnimator* afterAnimation;
}

@property float duration;
@property float removeViewAfterOperation;

-(id) initWithView:(UIView*)view;
-(id) initWithView:(UIView*)view andDuration:(float)duration;

-(void) startAnimation;
-(void) endAnimation;
-(void) setAfterAnimator:(LayAnimator*)_afterAnimation;
-(void) addParallelAnimator:(LayAnimator*)_parallelAnimation;

-(void) doStart;
-(void) doEnd;

+(void) enableAnimation:(BOOL)enable;

@end
