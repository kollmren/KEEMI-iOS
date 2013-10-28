//
//  LayVcImport.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 13.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayCatalogFileReader.h"
#import "LayCatalogDetails.h"
#import "LayImportProgressDelegate.h"
#import "LayImportStateView.h"
#import "LayVcNavigationBarDelegate.h"


#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface LayVcImport : UIViewController<MFMailComposeViewControllerDelegate, LayImportProgressDelegate, LayImportStateViewDelegate, LayVcNavigationBarDelegate>

-(id)initWithZippedFile:(NSURL*)urlZippedCatalog;

@end
