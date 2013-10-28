//
//  LaySearchView.h
//  Lay
//
//  Created by Rene Kollmorgen on 21.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayIconButton.h"
#import "LayVcNavigationBarDelegate.h"

typedef enum TitlePoition_ {
    TITLE_LEFT,
    TITLE_CENTER,
} TitlePosition;

@interface LayVcNavigationBar : NSObject <UISearchBarDelegate>

-(id)initWithViewController:(UIViewController*)viewController;

-(void)showButtonsInNavigationBar;

@property (nonatomic, weak) id<LayVcNavigationBarDelegate> delegate;
@property (nonatomic) BOOL queryButtonInNavigationBar;
@property (nonatomic) BOOL learnButtonInNavigationBar;
@property (nonatomic) BOOL cancelButtonInNavigationBar;
@property (nonatomic) BOOL searchButtonInNavigationBar;
@property (nonatomic) BOOL settingsButtonInNavigationBar;
@property (nonatomic) BOOL backButtonInNavigationBar;
@property (nonatomic) BOOL infoButtonInNavigationBar;

-(void)showTitle:(NSString*)title atPosition:(TitlePosition)position;

-(void)showTitle:(NSString*)title_ atPosition:(TitlePosition)position withFont:(UIFont*)appliedFont;

-(void)showTitle:(NSString*)title_ atPosition:(TitlePosition)position withFont:(UIFont*)appliedFont andColor:(UIColor*)titleColor;

-(void)showTitleImage:(UIImage*)image atPosition:(TitlePosition)position;

@end
