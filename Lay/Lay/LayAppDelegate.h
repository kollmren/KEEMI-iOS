//
//  LayAppDelegate.h
//  Lay
//
//  Created by Rene on 29.10.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@class LayVcMyCatalogList;

@interface LayAppDelegate : UIResponder <UIApplicationDelegate, MFMailComposeViewControllerDelegate> {
    BOOL appConfigured;
    BOOL paymentObserverAlreadyRegistered;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) LayVcMyCatalogList *viewController;

@end
