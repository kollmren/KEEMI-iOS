//
//  LaySectionMenu.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 04.07.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LaySectionMenuDelegate.h"

@interface LaySectionMenEntryButton : UIButton {
    CALayer *highlightLayer;
}

-(void)highlight;

@end

//
@interface LaySectionMenu : UIView {
    @private
    UIView *sectionOverviewStrap;
    UIScrollView *container;
    UIButton *strapButtonRight;
    UIButton *strapButtonLeft;
    UIButton *toTopButton;
    NSString* title;
    CGFloat initialContainerWidth;
}

@property (nonatomic) NSArray* sectionViewMetaInfoList;
@property (nonatomic, weak) id<LaySectionMenuDelegate> menuDelegate;

-(id)initWithSectionViewMetaInfoList:(NSArray*)sectionViewMetaInfoList andTitle:(NSString*)title;

-(void)setWindow:(UIWindow*)window;

-(void)showMenu;

-(void)hideSectionOverview:(BOOL)animated;

-(void)hideSectionOverviewAnimated;

-(void)closeMenu;

-(BOOL)menuIsVisible;

@end
