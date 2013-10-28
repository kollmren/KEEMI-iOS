//
//  LayVcSettings.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 17.09.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayVcNavigationBarDelegate.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface LayVcSettings : UITableViewController<MFMailComposeViewControllerDelegate, LayVcNavigationBarDelegate>

@end
