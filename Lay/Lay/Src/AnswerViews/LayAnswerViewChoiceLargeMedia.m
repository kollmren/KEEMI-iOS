//
//  LayAnswerViewChoiceLargeMedia.m
//  Lay
//
//  Created by Rene Kollmorgen on 18.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayAnswerViewChoiceLargeMedia.h"
#import "LayMediaView.h"
#import "LayAnswerType.h"
#import "LayMediaTypes.h"
#import "LayMediaData.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"
#import "LayAnswerItemViewMinimized.h"

#import "Question+Utilities.h"
#import "Answer+Utilities.h"
#import "AnswerItem+Utilities.h"
#import "Media+Utilities.h"
#import "AnswerMedia.h"

#import "MWLogging.h"

static const CGFloat SPACE = 5.0f;

@interface LayAnswerViewChoiceLargeMedia() {
    Answer* answer;
    LayMediaView *mediaView;
    LayAnswerItemViewMinimized *answerItemView;
}
@end

@implementation LayAnswerViewChoiceLargeMedia

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)dealloc {
    MWLogDebug([LayAnswerViewChoiceLargeMedia class], @"dealloc");
}

-(void)addAnswerItemViewWith:(Answer*)answer_ {
    if(self->answerItemView) {
        [self->answerItemView removeFromSuperview];
        self->answerItemView = nil;
    }
    const CGFloat heightOfMinView = [[LayStyleGuide instanceOf:nil] buttonSize].height;
    const CGSize sizeOfView = self.frame.size;
    const CGFloat yPos = sizeOfView.height - heightOfMinView - SPACE;
    const CGPoint minimizedPoint = CGPointMake(SPACE, yPos);
    const CGFloat maximizedWidth = sizeOfView.width - 2 * SPACE;
    self->answerItemView = [[LayAnswerItemViewMinimized alloc]initWithMinimizedPosition:minimizedPoint width:maximizedWidth andAnswer:answer_];
    [self addSubview:self->answerItemView];
}

-(void)setMedia:(Answer*)answer_ {
    NSArray *answerMediaList = [answer_ mediaList];
     MWLogInfo([LayAnswerViewChoiceLargeMedia class], @"Catch one media marked as large from media-list(question:%@)!", answer_.questionRef.name);
    Media* largeMedia = nil;
    for (Media* media in answerMediaList) {
        if([media isLargeMedia]) {
            largeMedia = media;
            break;
        }
    }
    
    if(largeMedia) {
        LayMediaData *mediaData = [LayMediaData byMediaObject:largeMedia];
        if(self->mediaView) {
            [self->mediaView removeFromSuperview];
            self->mediaView = nil;
        }
        self->mediaView = [[LayMediaView alloc]initWithFrame:self.frame andMediaData:mediaData];
        self->mediaView.zoomable = YES;
        [self->mediaView layoutMediaView];
        [self addSubview:self->mediaView];
    } else {
        MWLogError([LayAnswerViewChoiceLargeMedia class], @"Did not find any media marked as large for question:%@", answer_.questionRef.name );
    }
}

//
// LayAnswerView
//
-(id<LayAnswerView>)initAnswerView {
    return [self initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
}

-(CGSize)showAnswer:(Answer *)answer_ andSize:(CGSize)viewSize userCanSetAnswer:(BOOL)userCanSetAnswer{
    [LayFrame setSizeWith:viewSize toView:self];
    self->answer = answer_;
    [self setMedia:answer_];
    [self addAnswerItemViewWith:answer_];
    return self.frame.size;
}

-(void)showSolution {
    [self->answerItemView showSolution];
}

-(BOOL)isUserAnswerCorrect {
    BOOL corretAnswer = YES;
    NSArray *answerItemList = [self->answer answerItemListOrderedByNumber];
    for (AnswerItem* answerItem in answerItemList) {
        if((![answerItem.setByUser boolValue] && [answerItem.correct boolValue]) ||
           ([answerItem.setByUser boolValue] && ![answerItem.correct boolValue])) {
            corretAnswer = NO;
        }
    }
    return corretAnswer;
}

-(UIView*)answerView {
    return self;
}

-(BOOL)userSetAnswer {
    BOOL userSetAnAnswer = NO;
    NSArray *answerItemList = [self->answer answerItemListOrderedByNumber];
    for (AnswerItem* answerItem in answerItemList) {
        if([answerItem.setByUser boolValue]) {
            userSetAnAnswer = YES;
            break;
        }
    }
    return userSetAnAnswer;
}

-(void)setDelegate:(id<LayAnswerViewDelegate>)delegate {
}

@end


