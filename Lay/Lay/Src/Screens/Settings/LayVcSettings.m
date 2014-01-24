//
//  LayVcSettings.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 17.09.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayVcSettings.h"
#import "LayVcNavigationBar.h"
#import "LayStyleGuide.h"
#import "LayAppNotifications.h"
#import "LayAppConfiguration.h"
#import "LayUserDefaults.h"

#import "MWLogging.h"

static const NSInteger SECTION_HELP_IDX = 0;
static const NSInteger SECTION_HELP_SAMPLE_CATALOGS_IDX = 0;
static const NSInteger SECTION_HELP_FAQ_IDX = 1;
//
static const NSInteger SECTION_SUPPORT_IDX = 1;
static const NSInteger SECTION_SUPPORT_FEEDBACK_IDX = 0;
static const NSInteger SECTION_SUPPORT_REPORT_BUG_IDX = 1;
//
static const NSInteger SECTION_GENERAL_IDX = 2;

@interface LayVcSettings () {
    LayVcNavigationBar *navBarViewController;
    NSArray* sectionTitleList;
}
    
@end

@implementation LayVcSettings

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        NSString *titleGeneralSection = NSLocalizedString(@"InfoGeneral", nil);
        NSString *titleHelpSection = NSLocalizedString(@"InfoHelp", nil);
        NSString *titleSupportSection = NSLocalizedString(@"InfoSupport", nil);
        sectionTitleList = [NSArray arrayWithObjects:titleHelpSection, titleSupportSection, titleGeneralSection, nil];
        [self registerEvents];
    }
    return self;
}

-(void)dealloc {
    MWLogDebug([LayVcSettings class], @"dealloc");
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

-(void)registerEvents {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleWantToImportCatalogNotification) name:(NSString*)LAY_NOTIFICATION_WANT_TO_IMPORT_CATALOG object:nil];
}

-(void)handleWantToImportCatalogNotification {
    if(self.navigationController.topViewController == self) {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setupNavigation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupNavigation {
    // Setup the navigation controller
    self->navBarViewController = [[LayVcNavigationBar alloc]initWithViewController:self];
    self->navBarViewController.delegate = self;
    self->navBarViewController.cancelButtonInNavigationBar = YES;
    NSString *title = NSLocalizedString(@"InfoTitle", nil);
    [self->navBarViewController showTitle:title atPosition:TITLE_CENTER];
    [self->navBarViewController showButtonsInNavigationBar];
}

//
// Table view data source
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3; /* General ,Help, Support */
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = 0;
    if(section == SECTION_GENERAL_IDX) {
        numberOfRowsInSection = 1;
    } else if(section == SECTION_HELP_IDX) {
        numberOfRowsInSection = 2;
    } else if(section == SECTION_SUPPORT_IDX) {
        numberOfRowsInSection = 2;
    }
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    const NSInteger section = indexPath.section;
    const NSInteger row = indexPath.row;
    if(section == SECTION_GENERAL_IDX) {
        NSString* appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSString *title = NSLocalizedString(@"InfoAppVersionTitle", nil);
        cell.textLabel.text = title;
        cell.detailTextLabel.text = appVersion;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.enabled = NO;
    } else if(section == SECTION_HELP_IDX) {
        if(row == SECTION_HELP_SAMPLE_CATALOGS_IDX) {
            cell.textLabel.text = NSLocalizedString(@"InfoHelpSampleCatalogs", nil);
        } else if( row == SECTION_HELP_FAQ_IDX ) {
            cell.textLabel.text = NSLocalizedString(@"InfoHelpFaq", nil);
        }
    } else if(section == SECTION_SUPPORT_IDX) {
        if(row == SECTION_SUPPORT_FEEDBACK_IDX) {
            cell.textLabel.text = NSLocalizedString(@"InfoSupportFeedback", nil);
        } else if( row == SECTION_SUPPORT_REPORT_BUG_IDX ) {
            cell.textLabel.text = NSLocalizedString(@"InfoSupportBugReport", nil);
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self->sectionTitleList objectAtIndex:section];
}

//
// Table view delegate
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    const NSInteger section = indexPath.section;
    const NSInteger row = indexPath.row;
    if(section == SECTION_GENERAL_IDX) {
        
    } else if(section == SECTION_HELP_IDX) {
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        /*NSString *faqPath = @"faq-students";
        if([language isEqualToString:@"de"]) {
            faqPath = @"faqs-studenten";
        }*/
        if(row == SECTION_HELP_SAMPLE_CATALOGS_IDX) {
            NSString *catalogLink = @"https://github.com/PaaSQ";
            NSURL *link = [NSURL URLWithString:catalogLink];
            MWLogInfo([LayVcSettings class], @"Try to open link:%@", catalogLink);
            if (![[UIApplication sharedApplication] openURL:link]) {
                MWLogError([LayVcSettings class], @"Could not open link to:%@", catalogLink);
            }
        } else if( row == SECTION_HELP_FAQ_IDX ) {
            NSString *faqLink = [NSString stringWithFormat:@"http://www.keemimobile.com/%@/features", language];
            NSURL *link = [NSURL URLWithString:faqLink];
            MWLogInfo([LayVcSettings class], @"Try to open link:%@", faqLink);
            if (![[UIApplication sharedApplication] openURL:link]) {
                MWLogError([LayVcSettings class], @"Could not open link to:%@", faqLink);
            }
        }
    } else if(section == SECTION_SUPPORT_IDX) {
        if(row == SECTION_SUPPORT_FEEDBACK_IDX) {
            NSString *subject = NSLocalizedString(@"InfoFeedbackSubject", nil);
            NSString *recipient = @"support@keemimobile.com";
            [self sendMessage:subject recipient:recipient andText:nil file1:nil file2:nil];
        } else if( row == SECTION_SUPPORT_REPORT_BUG_IDX ) {
            NSString *subject = NSLocalizedString(@"InfoBugReportSubject", nil);
            NSString *recipient = @"support@keemimobile.com";
            NSData *contentOfBackupLog = [LayAppConfiguration contentBackupedOfLogFile];
            NSData *contentOfLog = [LayAppConfiguration contentOfLogFile];
            [self sendMessage:subject recipient:recipient andText:nil file1:contentOfBackupLog file2:contentOfLog];
        }
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return -1; // default
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil; // default
}

//
// LayVcNavigationBarDelegate
//
-(void)cancelPressed {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

//
// Action handlers
//
-(void)sendMessage:(NSString*)subject recipient:(NSString*)recipient andText:(NSString*)text file1:(NSData*)file1 file2:(NSData*)file2 {
	if ([MFMailComposeViewController canSendMail])
	{
        MWLogInfo([LayVcSettings class], @"Try to send message by mail.");
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setSubject:subject];
        
        // Set up recipients
        NSArray *toRecipients = [NSArray arrayWithObject:recipient];
        [picker setToRecipients:toRecipients];
        
        if(file1) {
            [picker addAttachmentData:file1 mimeType:@"text/plain" fileName:@"KeemiBugReport1.txt"];
        }
        
        if(file2) {
            [picker addAttachmentData:file2 mimeType:@"text/plain" fileName:@"KeemiBugReport2.txt"];
        }

        
        [picker setMessageBody:text isHTML:NO];
        
        [self presentViewController:picker animated:YES completion:nil];
    }
	else
	{
        MWLogError( [LayVcSettings class], @"E-Mail is not configured!");
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
        MWLogError([LayVcSettings class], @"mailComposeController:%@,%d", [error domain], [error code]);
    }
    
    switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			MWLogInfo([LayVcSettings class], @"Send report.");
			break;
		case MFMailComposeResultFailed:
			MWLogError([LayVcSettings class], @"Failed to send report.");
			break;
		default:
			break;
	}
    
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
