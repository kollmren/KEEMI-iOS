//
//  LayMiniIconBar.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 06.08.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum MiniIconsId_ {
    MINI_FAVOURITE = 1,
    MINI_RESOURCE,
    MINI_NOTE,
    MINI_QUERY,
    MINI_LEARN,
    MINI_USER,
    MINI_LEARN_STATE
} MiniIconsId;

typedef enum MiniIconsPositionId_ {
    MINI_POSITION_TOP = 1,
    MINI_POSITION_V_SPACE, // default
} MiniIconsPositionId;

@interface LayMiniIconBar : UIView

@property (nonatomic) BOOL showDisabledIcons;
@property (nonatomic) BOOL showQuestionIcon;
@property (nonatomic) BOOL showExplanationIcon;
@property (nonatomic) BOOL showNotesIcon;
@property (nonatomic) BOOL showFavouriteIcon;
@property (nonatomic) BOOL showUserIcon;
@property (nonatomic) BOOL showLearnStateIcon;
@property (nonatomic) MiniIconsPositionId positionId;

-(id)initWithWidth:(CGFloat)width;

-(void)show:(BOOL)yesNO miniIcon:(MiniIconsId)miniIconId;

-(void)setLearnStateIconColor:(UIColor*)color;

@end
