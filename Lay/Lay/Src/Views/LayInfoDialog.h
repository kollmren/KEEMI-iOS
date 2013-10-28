//
//  LayInfoDialogViewController.h
//  Lay
//
//  Created by Luis Remirez on 07.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LayImageRibbonDelegate.h"

@class Explanation;
@class Resource;
@interface LayInfoDialog : UIView<LayImageRibbonDelegate, UIWebViewDelegate>

-(id) initWithWindow:(UIWindow*)mainView_;

-(UIView*) showInfo:(NSArray*)info withTitle:(NSString*)title;
-(UIView*) showInfo:(NSArray*)info withTitle:(NSString*)title caller:(id)caller selector:(SEL)selector;
-(UIView*) showInfo:(NSArray*)info withTitle:(NSString*)title_ andMediaList:(NSArray*)mediaList;

-(UIView*) showShortExplanation:(Explanation*)explanation;

-(UIView*) showStatistic:(NSArray*)info withTitle:(NSString*)title_ caller:(id)caller_ selector:(SEL)selector_;

-(UIView*) showResource:(NSString*)title_ link:(NSObject*)resource;

@end
