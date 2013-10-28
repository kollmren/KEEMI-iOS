//
//  LayAppDelegate.m
//  Lay
//
//  Created by Rene on 29.10.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayAppDelegate.h"

#import "LayVcNavigation.h"
#import "LayVcMyCatalogList.h"
#import "LayVcImport.h"
#import "LayError.h"
#import "LayAppConfiguration.h"
#import "LayInfoDialog.h"
#import "LayXmlcatalogFileReader.h"
#import "LayAppNotifications.h"
#import "LayCatalogManager.h"
#import "LayStyleGuide.h"

#import "MWLogging.h"

@implementation LayAppDelegate


static Class _classObj = nil;
static NSURL* currentCatalogToImport;

static const NSString* const startedAndTerminatedFineKey = @"startedAndTerminatedFineKey";
static const NSInteger startedAppFine = 1;
static const NSInteger terminatedAppFine = 2;
static const NSInteger startedAppWithError = 3;

+(void) initialize {
    _classObj = [LayAppDelegate class];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&myExceptionHandler);
    NSURL* catalogURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if(!catalogURL) {
        // Check if the application is launched because another app ask the system to open a keemi-catalog. In this
        // case (a value for the key UIApplicationLaunchOptionsURLKey is available) the catalog-package is already copied
        // into the Documents/Inbox directory. This package we dont want to delete.
        // But in a normal startup(the app is fresh started by the user) we cleanup the Inbox dir by removing it at all.
        // ! The catalog-package is opened in the function:
        // application:openURL:sourceApplication
        // this delegete function is called after(from?) this function.
        [LayCatalogManager cleanupInboxAndTmpDir];
    }
    
    // Register events
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(importCatalog) name:(NSString*)LAY_NOTIFICATION_DO_IMPORT_CATALOG object:nil];
    [nc addObserver:self selector:@selector(applicationWillTerminate) name:(NSString*)LAY_NOTIFICATION_IGNORE_IMPORT_CATALOG__ANOTHER_IS_STILL_IN_PROGRESS object:nil];
    [nc addObserver:self selector:@selector(contentSizeCategoryDidChange:) name:(NSString*)UIContentSizeCategoryDidChangeNotification object:nil];
    
    
    
    // Setup window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    // Configure app
    self->appConfigured = [LayAppConfiguration configureApp];
    if(self->appConfigured) {
        MWLogInfo(_classObj, @"Run configuration successfully!");
        LayVcMyCatalogList *vcMyCatalogList = [[LayVcMyCatalogList alloc]init];
        LayVcNavigation *vcNavigation = [[LayVcNavigation alloc] initWithRootViewController:vcMyCatalogList];
        self.window.rootViewController = vcNavigation;
        // Set a flag to indicate a well start of the app.
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *appSettings = [standardUserDefaults dictionaryRepresentation];
        BOOL appIsLaunchedTheFirstTime = [appSettings objectForKey:(NSString*)startedAndTerminatedFineKey]==nil?YES:NO;
        if(!appIsLaunchedTheFirstTime) {
            MWLogInfo(_classObj, @"Check the terminate flag of the app.");
            const NSInteger startTerminateFlagValue = [standardUserDefaults integerForKey:(NSString*)startedAndTerminatedFineKey];
            if(startTerminateFlagValue != terminatedAppFine) {
                MWLogError(_classObj, @"The app terminated undefined(crashed) the last time.");
                NSString *message = NSLocalizedString(@"ErrorAlertMessageSendBugReport", nil);
                NSString *sendButtonTitle = NSLocalizedString(@"MailSendButton", nil);
                NSString *cancelButtonTitle = NSLocalizedString(@"MailCancelButton", nil);
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                             message:message
                                                            delegate:self
                                                   cancelButtonTitle:cancelButtonTitle
                                                   otherButtonTitles:sendButtonTitle,nil];
                [av show];
            } else {
                MWLogInfo(_classObj, @"The app terminated in a defined state last time.");
            }
        } else {
            MWLogInfo(_classObj, @"App is started for the first time.");
        }
    } else {
        NSString *appConfigErrorMessage =  NSLocalizedString(@"ErrorCouldNotConfigureApp", nil);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:appConfigErrorMessage
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
    }

    return YES;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL openedTheResource = NO;
    if(!url) {
        MWLogError(_classObj, @"URL is nil!");
        NSString* message = NSLocalizedString(@"ErrorCatalogToOpenDoesnNotExist", nil);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:message
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
    } else {
        NSFileManager *fileMngr = [NSFileManager defaultManager];
        if(![fileMngr fileExistsAtPath:[url path]]) {
            MWLogError(_classObj, @"Package does not exists:%@", [url path]);
        } else {
            LayCatalogManager *catalogManager = [LayCatalogManager instance];
            catalogManager.pendingCatalogToImport = YES;
            currentCatalogToImport = url;
            NSNotification *note = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_WANT_TO_IMPORT_CATALOG object:self];
            [[NSNotificationCenter defaultCenter] postNotification:note];
            openedTheResource = YES;
        }
    }
    return openedTheResource;
}

-(void)openCatalog:(NSURL*)urlCatalog {
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    if(![fileMngr fileExistsAtPath:[urlCatalog path]]) {
        MWLogError(_classObj, @"Package does not exists:%@", [urlCatalog path]);
    } else {
        MWLogDebug(_classObj, @"Setup import dialog:", [urlCatalog path] );
        LayVcImport *vcImport = [[LayVcImport alloc]initWithZippedFile:urlCatalog];
        UINavigationController* navigationController = (UINavigationController* )self.window.rootViewController;
        [navigationController pushViewController:vcImport animated:NO];
    }
}

// hanlde Notifications
-(void)contentSizeCategoryDidChange:(NSNotification*)updatedContentSize {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    [styleGuide updatePreferredFonts];
    
    NSNotification *notification = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_PREFERRED_FONT_SIZE_CHANGED object:self];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

-(void)importCatalog {
    [self openCatalog:currentCatalogToImport];
}

-(void)deleteIgnoredCatalogFromInbox {
    // Delete file which was ignored to import due to an already imported catalog. 
    [LayCatalogManager deleteFile:currentCatalogToImport];
}

void myExceptionHandler(NSException *exception)
{
    MWLogError(_classObj, @"Undefined exception:%@, %@, %@", exception.name, exception.reason, [exception userInfo]);
    MWLogError(_classObj, @"Backtrace:%@", [exception callStackSymbols]);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    MWLogDebug(_classObj, @"applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    MWLogDebug(_classObj, @"applicationDidEnterBackground");
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setInteger:terminatedAppFine forKey:(NSString*)startedAndTerminatedFineKey];
    [standardUserDefaults synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    MWLogDebug(_classObj, @"applicationWillEnterForeground");
    // Set a flag to indicate a well start of the app.
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if(self->appConfigured){
        [standardUserDefaults setInteger:startedAppFine forKey:(NSString*)startedAndTerminatedFineKey];
    } else {
        [standardUserDefaults setInteger:startedAppWithError forKey:(NSString*)startedAndTerminatedFineKey];
    }
    
    [standardUserDefaults synchronize];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    MWLogDebug(_classObj, @"applicationDidBecomeActive");
    // Set a flag to indicate a well start of the app.
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if(self->appConfigured){
        [standardUserDefaults setInteger:startedAppFine forKey:(NSString*)startedAndTerminatedFineKey];
    } else {
        [standardUserDefaults setInteger:startedAppWithError forKey:(NSString*)startedAndTerminatedFineKey];
    }
    
    [standardUserDefaults synchronize];
}

- (BOOL)fileManager:(NSFileManager *)fileManager shouldRemoveItemAtPath:(NSString *)path {
    return YES;
}

//
// Action handlers
//
-(void)sendMessage:(NSString*)subject recipient:(NSString*)recipient andText:(NSString*)text {
	if ([MFMailComposeViewController canSendMail])
	{
        MWLogInfo(_classObj, @"Try to send message by mail.");
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setSubject:subject];
        
        // Set up recipients
        NSArray *toRecipients = [NSArray arrayWithObject:recipient];
        [picker setToRecipients:toRecipients];
        // Log / Report
        NSData *contentOfLog = [LayAppConfiguration contentBackupedOfLogFile];
        if(contentOfLog) {
            [picker addAttachmentData:contentOfLog mimeType:@"text/plain" fileName:@"KeemiBugReport.txt"];
        }
        //
        [picker setMessageBody:text isHTML:NO];
        
        UIViewController* rootViewController = self.window.rootViewController;
        [rootViewController presentViewController:picker animated:YES completion:nil];
    }
	else
	{
        MWLogError( _classObj, @"E-Mail is not configured!");
        NSString *text = NSLocalizedString(@"MailNotConfiguredText", nil);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:text
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
	}
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if(error) {
        MWLogError(_classObj, @"mailComposeController:%@,%d", [error domain], [error code]);
    }
    
    switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			MWLogInfo(_classObj, @"Send report.");
			break;
		case MFMailComposeResultFailed:
			MWLogError(_classObj, @"Failed to send report.");
			break;
		default:
			break;
	}

	[controller.topViewController dismissViewControllerAnimated:YES completion:nil];
}

//
// UIAlertViewDelegate
//
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        NSString *subject = NSLocalizedString(@"InfoBugReportSubject", nil);
        NSString *recipient = @"support@keemimobile.com";
        [self sendMessage:subject recipient:recipient andText:subject];
    }
}

@end
