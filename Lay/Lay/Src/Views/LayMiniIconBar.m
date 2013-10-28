//
//  LayMiniIconBar.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 06.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayMiniIconBar.h"
#import "LayImage.h"
#import "LayFrame.h"

static const CGFloat g_disabledMiniIconsAlphaValue = 0.2f;
static const CGFloat g_enabledMiniIconsAlphaValue = 1.0f;

@implementation LayMiniIconBar

@synthesize showDisabledIcons, showExplanationIcon, showQuestionIcon, showNotesIcon, showFavouriteIcon, showUserIcon, showLearnStateIcon, positionId;

- (id)initWithWidth:(CGFloat)width
{
    const CGFloat heightOfMiniIconBar = 20.0f;
    const CGRect frame = CGRectMake(0.0f, 0.0f, width, heightOfMiniIconBar);
    self = [super initWithFrame:frame];
    if (self) {
        self.showDisabledIcons = YES;
        self.positionId = MINI_POSITION_V_SPACE;
        [self setupMiniIcons];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setShowLearnStateIcon:(BOOL)showLearnStateIcon_ {
    showLearnStateIcon = showLearnStateIcon_;
    if(showLearnStateIcon) {
        const CGFloat scale = 0.7f;
        const CGFloat lengthStateRect = self.frame.size.height * scale;
        const CGRect learnStateIconRect = CGRectMake(0.0f, 0.0f, lengthStateRect, lengthStateRect);
        UIView *learnStateIcon = [[UIView alloc]initWithFrame:learnStateIconRect];
        learnStateIcon.alpha = g_disabledMiniIconsAlphaValue;
        learnStateIcon.tag = MINI_LEARN_STATE;
        [self insertSubview:learnStateIcon atIndex:0];
    } else {
        UIView* mini = [self viewWithTag:MINI_LEARN_STATE];
        [mini removeFromSuperview];
    }
    [self layoutMiniContainer];
}

-(void)setShowExplanationIcon:(BOOL)showExplanationIcon_ {
    showExplanationIcon = showExplanationIcon_;
    if(showExplanationIcon) {
        UIImage *learnMini = [LayImage imageWithId:LAY_IMAGE_LEARN_MINI];
        learnMini = [UIImage imageWithCGImage:learnMini.CGImage scale:2.0f orientation:learnMini.imageOrientation];
        UIImageView *learnImgView = [[UIImageView alloc]initWithImage:learnMini];
        learnImgView.tag = MINI_LEARN;
        learnImgView.alpha = g_disabledMiniIconsAlphaValue;
        [self addSubview:learnImgView];
    } else {
        UIView* mini = [self viewWithTag:MINI_LEARN];
        [mini removeFromSuperview];
    }
    [self layoutMiniContainer];
}

-(void)setShowUserIcon:(BOOL)showUserIcon_ {
    showUserIcon = showUserIcon_;
    if(showUserIcon) {
        UIImage *userMini = [LayImage imageWithId:LAY_IMAGE_USER];
        userMini = [UIImage imageWithCGImage:userMini.CGImage scale:2.0f orientation:userMini.imageOrientation];
        UIImageView *userImgView = [[UIImageView alloc]initWithImage:userMini];
        userImgView.tag = MINI_USER;
        userImgView.alpha = g_disabledMiniIconsAlphaValue;
        [self addSubview:userImgView];
    } else {
        UIView* mini = [self viewWithTag:MINI_LEARN];
        [mini removeFromSuperview];
    }
    [self layoutMiniContainer];
}

-(void)setShowQuestionIcon:(BOOL)showQuestionIcon_ {
    showQuestionIcon = showQuestionIcon_;
    if(showQuestionIcon) {
        UIImage *queryMini = [LayImage imageWithId:LAY_IMAGE_QUERY_MINI];
        queryMini = [UIImage imageWithCGImage:queryMini.CGImage scale:2.0f orientation:queryMini.imageOrientation];
        UIImageView *queryImgView = [[UIImageView alloc]initWithImage:queryMini];
        queryImgView.tag = MINI_QUERY;
        queryImgView.alpha = g_disabledMiniIconsAlphaValue;
        [self addSubview:queryImgView];
    } else {
        UIView* mini = [self viewWithTag:MINI_QUERY];
        [mini removeFromSuperview];
    }
    [self layoutMiniContainer];
}

-(void)setShowNotesIcon:(BOOL)showIcon {
    showNotesIcon = showIcon;
    if(showNotesIcon) {
        UIImage *mini = [LayImage imageWithId:LAY_IMAGE_NOTES_MINI];
        mini = [UIImage imageWithCGImage:mini.CGImage scale:2.0f orientation:mini.imageOrientation];
        UIImageView *imgView = [[UIImageView alloc]initWithImage:mini];
        imgView.tag = MINI_NOTE;
        imgView.alpha = g_disabledMiniIconsAlphaValue;
        [self addSubview:imgView];
    } else {
        UIView* mini = [self viewWithTag:MINI_NOTE];
        [mini removeFromSuperview];
    }
    [self layoutMiniContainer];
}

-(void)setShowFavouriteIcon:(BOOL)showIcon {
    showFavouriteIcon = showIcon;
    if(showFavouriteIcon) {
        UIImage *mini = [LayImage imageWithId:LAY_IMAGE_FAVOURITES_MINI];
        mini = [UIImage imageWithCGImage:mini.CGImage scale:2.0f orientation:mini.imageOrientation];
        UIImageView *imgView = [[UIImageView alloc]initWithImage:mini];
        imgView.tag = MINI_FAVOURITE;
        imgView.alpha = g_disabledMiniIconsAlphaValue;
        [self addSubview:imgView];
    } else {
        UIView* mini = [self viewWithTag:MINI_FAVOURITE];
        [mini removeFromSuperview];
    }
    [self layoutMiniContainer];
}

-(void)setShowDisabledIcons:(BOOL)showDisabledIcons_ {
    showDisabledIcons = showDisabledIcons_;
    [self layoutMiniContainer];
}

-(void)setPositionId:(MiniIconsPositionId)positionId_ {
    positionId = positionId_;
    [self layoutMiniContainer];

}

-(void)show:(BOOL)yesNO miniIcon:(MiniIconsId)miniIconId {
    UIView *miniIconView = [self viewWithTag:miniIconId];
    if(yesNO) {
        miniIconView.alpha = g_enabledMiniIconsAlphaValue;
    } else {
        miniIconView.alpha = g_disabledMiniIconsAlphaValue;
    }
    if(NO == self.showDisabledIcons) {
        [self layoutMiniContainer];
    }
}

//
// Private
//

-(void)setupMiniIcons {
    UIImage *noteMini = [LayImage imageWithId:LAY_IMAGE_NOTES_MINI];
    noteMini = [UIImage imageWithCGImage:noteMini.CGImage scale:2.0f orientation:noteMini.imageOrientation];
    UIImage *resourceMini = [LayImage imageWithId:LAY_IMAGE_RESOURCES_MINI];
    resourceMini = [UIImage imageWithCGImage:resourceMini.CGImage scale:2.0f orientation:resourceMini.imageOrientation];
    UIImage *favouriteMini = [LayImage imageWithId:LAY_IMAGE_FAVOURITES_MINI];
    favouriteMini = [UIImage imageWithCGImage:favouriteMini.CGImage scale:2.0f orientation:favouriteMini.imageOrientation];
    UIImageView *noteImgView = [[UIImageView alloc]initWithImage:noteMini];
    noteImgView.tag = MINI_NOTE;
    noteImgView.alpha = g_disabledMiniIconsAlphaValue;
    UIImageView *resImgView = [[UIImageView alloc]initWithImage:resourceMini];
    resImgView.tag = MINI_RESOURCE;
    resImgView.alpha = g_disabledMiniIconsAlphaValue;
    UIImageView *favImgView = [[UIImageView alloc]initWithImage:favouriteMini];
    favImgView.tag = MINI_FAVOURITE;
    favImgView.alpha = g_disabledMiniIconsAlphaValue;
    const CGFloat scale = 0.7f;
    const CGFloat lengthStateRect = self.frame.size.height * scale;
    const CGRect learnStateIconRect = CGRectMake(0.0f, 0.0f, lengthStateRect, lengthStateRect);
    UIView *learnStateIcon = [[UIView alloc]initWithFrame:learnStateIconRect];
    learnStateIcon.alpha = g_disabledMiniIconsAlphaValue;
    learnStateIcon.tag = MINI_LEARN_STATE;
    [self addSubview:noteImgView];
    [self addSubview:resImgView];
    [self addSubview:favImgView];
    [self layoutMiniContainer];
}

-(void)layoutMiniContainer {
    const CGFloat hSpace = 7.0f;
    CGFloat yPos = 5.0f;
    if(self.positionId == MINI_POSITION_TOP) {
        yPos = 0.0f;
    }
    CGFloat xPosCurrent = self.frame.size.width;
    for (UIView* miniView in [self subviews]) {
        if(NO == self.showDisabledIcons) {
            if(miniView.alpha < g_enabledMiniIconsAlphaValue) {
                miniView.hidden = YES;
            } else {
                miniView.hidden = NO;
            }
        }
        
        if(!miniView.hidden) {
            miniView.hidden = NO;
            CGFloat width = miniView.frame.size.width;
            xPosCurrent = xPosCurrent - width - hSpace;
            [LayFrame setXPos:xPosCurrent toView:miniView];
            [LayFrame setYPos:yPos toView:miniView];
        }
    }
}

-(void)setLearnStateIconColor:(UIColor*)color {
    UIView* learnStateIcon = [self viewWithTag:MINI_LEARN_STATE];
    if(learnStateIcon) {
       learnStateIcon.backgroundColor = color; 
    }
}

@end
