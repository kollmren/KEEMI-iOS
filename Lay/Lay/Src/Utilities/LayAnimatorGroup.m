//
//  LYAnimatorGroup.m
//  AdvancedTableViewCells
//
//  Created by Luis Remirez on 02.02.13.
//
//

#import "LayAnimatorGroup.h"

@implementation LayAnimatorGroup


-(id) initWithDuration:(float)_duration {
    self = [super initWithView:nil andDuration:_duration];
    return self;
}

-(void) doStart {
    for(LayAnimator* sibling in self->parallelAnimator) {
        [sibling doStart];
    }
}

-(void) doEnd {
    for(LayAnimator* sibling in self->parallelAnimator) {
        [sibling doEnd];
    }
}

@end
