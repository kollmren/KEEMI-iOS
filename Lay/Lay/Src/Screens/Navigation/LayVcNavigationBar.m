//
//  LaySearchView.m
//  Lay
//
//  Created by Rene Kollmorgen on 21.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayVcNavigationBar.h"
#import "LayIconButton.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"
#import "LayAppNotifications.h"

#import "MWLogging.h"

@interface LayVcNavigationBar (){
    __weak UIViewController* viewController;
    CALayer* disableViewOverlay;
    NSString *title;
    UIImage *titleImage;
    TitlePosition titlePosition;
}

@end

@implementation LayVcNavigationBar

static const NSInteger NUMBER_OF_POSSIBLE_BUTTONS_IN_NAVIGATION_BAR = 5;

@synthesize cancelButtonInNavigationBar,
queryButtonInNavigationBar,
learnButtonInNavigationBar,
searchButtonInNavigationBar,
settingsButtonInNavigationBar,
backButtonInNavigationBar,
infoButtonInNavigationBar,
addButtonInNavigationBar,
delegate;

-(id)initWithViewController:(UIViewController*)viewController_ {
    self = [super init];
    if (self) {
        self->viewController = viewController_;
        [self registerEvents];
    }
    return self;
}

-(void)dealloc {
    MWLogDebug([LayVcNavigationBar class], @"dealloc");
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

-(void)registerEvents {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handlePreferredFontSizeChanges) name:(NSString*)LAY_NOTIFICATION_PREFERRED_FONT_SIZE_CHANGED object:nil];
}

-(void)showButtonsInNavigationBar {
    [self->viewController navigationItem].hidesBackButton = YES;
    
    NSMutableArray *navigationButtonItemList = [NSMutableArray arrayWithCapacity:NUMBER_OF_POSSIBLE_BUTTONS_IN_NAVIGATION_BAR];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    // clean the current settings
    [self->viewController navigationItem].leftBarButtonItems = @[];
    [self->viewController navigationItem].rightBarButtonItems = @[];
    //
    negativeSpacer.width = 0;//-16;
    [navigationButtonItemList addObject:negativeSpacer];
    
    if(self.queryButtonInNavigationBar) {
        UIButton *button = [LayIconButton buttonWithId:LAY_BUTTON_QUESTION];
        [button addTarget:self action:@selector(queryPressed) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
        [navigationButtonItemList addObject:buttonItem];
    }
    
    if(self.addButtonInNavigationBar) {
        UIButton *button = [LayIconButton buttonWithId:LAY_BUTTON_ADD];
        [button addTarget:self action:@selector(addPressed) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
        [navigationButtonItemList addObject:buttonItem];
    }
    
    if(self.learnButtonInNavigationBar) {
        UIButton *button = [LayIconButton buttonWithId:LAY_BUTTON_LEARN];
        [button addTarget:self action:@selector(learnPressed) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
        [navigationButtonItemList addObject:buttonItem];
    }
    
    if(self.searchButtonInNavigationBar) {
        UIButton *button = [LayIconButton buttonWithId:LAY_BUTTON_SEARCH];
        [button addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
        [navigationButtonItemList addObject:buttonItem];
    }
    
    if(self.settingsButtonInNavigationBar) {
        UIButton *button = [LayIconButton buttonWithId:LAY_BUTTON_SETTINGS];
        [button addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
        [navigationButtonItemList addObject:buttonItem];
    }
    
    if(self.infoButtonInNavigationBar) {
        UIButton *button = [LayIconButton buttonWithId:LAY_BUTTON_INFO];
        [button addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
        NSArray *navigationButtonItemListLeft = @[buttonItem];
        [[self->viewController navigationItem] setLeftBarButtonItems:navigationButtonItemListLeft animated:YES];
    }
    
    /*UIBarButtonItem *buttonItemSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];*/
    [[self->viewController navigationItem] setRightBarButtonItems:navigationButtonItemList animated:YES];
    
    // items shown left
    if(self.cancelButtonInNavigationBar) {
        UIButton *button = [LayIconButton buttonWithId:LAY_BUTTON_CANCEL];
        [button addTarget:self action:@selector(cancelPressed) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
        [self->viewController navigationItem].leftBarButtonItems = @[negativeSpacer, buttonItem];
    }

        
    if(self.backButtonInNavigationBar) {
        UIButton *button = [LayIconButton buttonWithId:LAY_BUTTON_BACK];
        [button addTarget:self action:@selector(backToPreviousUiController) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
        [self->viewController navigationItem].leftBarButtonItems = @[negativeSpacer, buttonItem];
    }
}

-(void)showTitle:(NSString*)title_ atPosition:(TitlePosition)position {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    UIFont *appliedFont = [styleGuide getFont:NormalPreferredFont];
    [self showTitle:title_ atPosition:position withFont:appliedFont];
}

-(void)showTitle:(NSString*)title_ atPosition:(TitlePosition)position withFont:(UIFont*)appliedFont {
    if(title_) {
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        UIFont *appliedFont = [styleGuide getFont:NormalPreferredFont];
        UIColor *titleColor = [styleGuide getColor:TextColor];
        [self showTitle:title_ atPosition:position withFont:appliedFont andColor:titleColor];
    }
}

-(void)showTitle:(NSString*)title_ atPosition:(TitlePosition)position withFont:(UIFont*)appliedFont andColor:(UIColor*)titleColor {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    if(title_) {
        title = title_;
        titlePosition = position;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        if(position == TITLE_CENTER) {
            NSTextAlignment textAlignment = NSTextAlignmentCenter;
            UILabel *label =
            [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, screenWidth, 0.0f)];
            label.text = title;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = titleColor;
            label.font = appliedFont;
            label.textAlignment = textAlignment;
            [label sizeToFit];
            const CGFloat xPoslabel = (screenWidth - label.frame.size.width) / 2.0f;
            [LayFrame setXPos:xPoslabel toView:label];
            [[self->viewController navigationItem] setTitleView:label];
        } else {
            UILabel *label =
            [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, screenWidth, 0.0f)];
            label.text = title;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [styleGuide getColor:TextColor];
            label.font = appliedFont;
            NSTextAlignment textAlignment = NSTextAlignmentLeft;
            label.textAlignment = textAlignment;
            UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:label];
            NSArray *barItemList = [NSArray arrayWithObject:item];
            [self->viewController navigationItem].leftBarButtonItems = barItemList;
        }
    }
}


-(void)showTitleImage:(UIImage*)image_ atPosition:(TitlePosition)position {
    if(image_) {
        self->titleImage = image_;
        self->titlePosition = position;
        CGFloat xPos = 0.0;
        CGFloat titleWidth = 90.0f;
        if(position == TITLE_CENTER) {
            CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
            titleWidth = 200.0f;
            xPos = screenWidth/2 - titleWidth/2;
        }
        CGFloat heightTitleImage = 30.0f;
        UIImageView *imageView =
        [[UIImageView alloc] initWithFrame:CGRectMake(xPos, 0.0f, titleWidth, heightTitleImage)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = image_;
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        [styleGuide makeRoundedBorder:imageView withBackgroundColor:WhiteTransparentBackground andBorderColor:WhiteTransparentBackground];
        [[self->viewController navigationItem] setTitleView:imageView];
    }
}

//
// handler for the navigation buttons
//
-(void)cancelPressed {
    if(self.delegate) [self.delegate cancelPressed];
}

-(void)queryPressed {
    if(self.delegate) [self.delegate queryPressed];
}

-(void)learnPressed {
    if(self.delegate) [self.delegate learnPressed];
}

-(void)openSettings {
    if(self.delegate) [self.delegate infoPressed];
}

-(void)search {
    if(self.delegate) [self.delegate searchIconPressed];
}

-(void)addPressed {
    if(self.delegate) [self.delegate addPressed];
}

-(void)backToPreviousUiController {
    if(self.delegate && [self.delegate respondsToSelector:@selector(backPressed)]) [self.delegate backPressed];
    [self->viewController.navigationController popViewControllerAnimated:YES];
}

//
// implement UISearchBarDelegate
//
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if(self.delegate) [self.delegate searchFinished];
    searchBar.text=@"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    searchBar.delegate = nil;
    [[self->viewController navigationItem] setTitleView:nil];
    
    [self->disableViewOverlay removeFromSuperlayer];
    self->disableViewOverlay = nil;
    
    [self showButtonsInNavigationBar];
    [self showTitle:self->title atPosition:self->titlePosition];
}

//
// Action handlers
//
-(void)handlePreferredFontSizeChanges {
    [self showTitle:self->title atPosition:self->titlePosition];
}

@end
