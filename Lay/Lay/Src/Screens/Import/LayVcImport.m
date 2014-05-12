//
//  LayVcImport.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 13.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayVcImport.h"
#import "LayXmlCatalogFileReader.h"
#import "LayCatalogDetails.h"
#import "LayStyleGuide.h"
#import "LayCatalogFileReader.h"
#import "LayVcNavigationBar.h"
#import "LayImage.h"
#import "LayFrame.h"
#import "LayButton.h"
#import "LayCatalogImport.h"
#import "LayCatalogImportReport.h"
#import "LayAppConfiguration.h"
#import "LayMainDataStore.h"
#import "LayCatalogManager.h"
#import "LayVcCatalogList.h"
#import "LayVBoxLayout.h"
#import "LayHintView.h"
#import "LayError.h"
#import "LayAppNotifications.h"

#import "MWLogging.h"
#import "OctoKit.h"

#import "Catalog+Utilities.h"

static const CGFloat V_SPACE = 10.0f;
static const NSInteger TAG_MY_VIEWS = 6001;
static const NSInteger TAG_STATE_VIEW = 6002;
static const NSInteger TAG_CATALOG_INFO_DOWNLOAD = 6003;

@interface LayVcImport () {
    NSURL *urlZippedCatalog;
    LayGithubCatalog *githubCatalog;
    id<LayCatalogFileReader> catalogFileReader;
    UIScrollView *importView;
    UILabel *importQuestionLabel;
    NSUInteger maxImportSteps;
    NSUInteger currentImportStep;
    LayCatalogFileInfo* catalogFileInfo;
    LayVcNavigationBar *navBarViewController;
    LayCatalogDetails *catalogDetailView;
    UILabel* statusMessage;
    UIView* handleDuplicateImportContainer;
    UIView *buttonContainer;
    LayButton *moreDetailsButton;
    LayButton *okButton;
    LayButton *abortButton;
    LayButton *sendReport;
    UILabel* sendReportMessage;
    NSTimer *deleteDuplicateCatalogStepTimer;
    BOOL catalogWasUnzipped;
    AFHTTPRequestOperation *downlaodOperation;
}
@end

static Class g_classObj = nil;

@implementation LayVcImport

+(void) initialize {
    g_classObj = [LayVcImport class];
}

-(id)initWithZippedFile:(NSURL*)urlZippedCatalog_ {
    self->urlZippedCatalog = urlZippedCatalog_;
    self->maxImportSteps = 0;
    self->catalogWasUnzipped = NO;
    return [super initWithNibName:nil bundle:nil];
}

-(id)initWithGithubCatalogToDownload:(LayGithubCatalog*)githubCatalog_ {
    self->githubCatalog = githubCatalog_;
    self->maxImportSteps = 0;
    self->catalogWasUnzipped = NO;
    return [super initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithZippedFile:nil];
}

-(void)dealloc {
    MWLogDebug(g_classObj, @"dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    self.view.backgroundColor = [styleGuide getColor:BackgroundColor];
    [self registerEvents];
    
}

-(void)viewWillAppear:(BOOL)animated {
    if(!catalogWasUnzipped) {
        if( !self->urlZippedCatalog ) {
            [self showDownloadState];
        } else {
            [self showUnzipState];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)registerEvents {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleWantToImportCatalogNotification) name:(NSString*)LAY_NOTIFICATION_WANT_TO_IMPORT_CATALOG object:nil];
    [nc addObserver:self selector:@selector(handlePreferredFontSizeChanges) name:(NSString*)LAY_NOTIFICATION_PREFERRED_FONT_SIZE_CHANGED object:nil];
}

-(void)handleWantToImportCatalogNotification {
    if(self.navigationController.topViewController == self) {
        // check if there is still an task(unzip, delete, import) in progress
        UIView *stateView = [self.view.window viewWithTag:TAG_STATE_VIEW];
        if(stateView) {
            [LayCatalogManager instance].pendingCatalogToImport = NO;
            NSNotification *note = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_IGNORE_IMPORT_CATALOG__ANOTHER_IS_STILL_IN_PROGRESS object:self];
            [[NSNotificationCenter defaultCenter] postNotification:note];
            NSString *text = NSLocalizedString(@"ImportStillATaskInProgress", nil);
            [self showHint:text withTarget:nil andAction:nil state:NO andDuration:4.0f];
        } else {
            // If the emailComposeView is shown close the view
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}

-(void)handlePreferredFontSizeChanges {
    UIView *stateView = [self.view.window viewWithTag:TAG_STATE_VIEW];
    if(!stateView && catalogWasUnzipped) {
        [self setupCatalogPreview];
    }
}

-(void)setupNavigationUnzipFinished {
    //Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    UIImage *logoPublisher = nil;//[catalog publisherLogo];
    if(logoPublisher) {
        [self->navBarViewController showTitleImage:logoPublisher atPosition:TITLE_CENTER];
        //[self addPublisherLogo:logoPublisher];
    } else {
        NSString *publisherTitle = nil;
        if(self->catalogFileInfo) {
            publisherTitle = [self->catalogFileInfo detailForKey:@"publisher"];
        } else {
            publisherTitle = NSLocalizedString(@"ImportReadingInfoFailed", nil);
        }
        [self->navBarViewController showTitle:publisherTitle atPosition:TITLE_CENTER];
    }
    self->navBarViewController.delegate = self;
    self->navBarViewController.backButtonInNavigationBar = YES;
    [self->navBarViewController showButtonsInNavigationBar];
}

-(void)setupNavigationUnzipState {
    // Setup the navigation controller
    self->navBarViewController = [[LayVcNavigationBar alloc]initWithViewController:self];
    NSString *nameOfCatalogFile = [self->urlZippedCatalog lastPathComponent];
    [self->navBarViewController showTitle:nameOfCatalogFile atPosition:TITLE_CENTER];
    self->navBarViewController.delegate = self;
    self->navBarViewController.cancelButtonInNavigationBar = NO;
    [self->navBarViewController showButtonsInNavigationBar];
}

-(void)setupNavigationDownloadState {
    // Setup the navigation controller
    self->navBarViewController = [[LayVcNavigationBar alloc]initWithViewController:self];
    [self->navBarViewController showTitle:self->githubCatalog->url atPosition:TITLE_CENTER];
    self->navBarViewController.delegate = self;
    self->navBarViewController.cancelButtonInNavigationBar = YES;
    [self->navBarViewController showButtonsInNavigationBar];
}

-(void)setupUnzipStateView {
    UIView *downloadCatalogInfoView = [self.view viewWithTag:TAG_CATALOG_INFO_DOWNLOAD];
    [downloadCatalogInfoView removeFromSuperview];
    const CGFloat viewWidth = self.view.frame.size.width;
    UIImage *imageUnpack = [LayImage imageWithId:LAY_IMAGE_UNPACK];
    NSString *buttonText = NSLocalizedString(@"BackToMyCatalogs", nil);
    LayImportStateView *importStateView = [[LayImportStateView alloc]initWithWidth:viewWidth icon:imageUnpack andButtonText:buttonText];
    importStateView.delegate = self;
    NSString *text = NSLocalizedString(@"ImportUnpackCatalog", nil);
    [importStateView setLabelText:text];
    importStateView.tag = TAG_STATE_VIEW;
    importStateView.center = self.view.center;
    [self.view addSubview:importStateView];
}

-(void)setupDownloadStateView {
    LayCatalogFileInfo *catalogFileInfo2 = [LayCatalogFileInfo new];
    catalogFileInfo2.catalogTitle = self->githubCatalog->title;
    //[catalogFileInfo2 setDetail:self->githubCatalog->name forKey:@"publisher"];
    //[catalogFileInfo2 setDetail:self->githubCatalog->version forKey:@"version"];
    catalogFileInfo2.cover = self->githubCatalog->cover;
    catalogFileInfo2.coverMediaFormat = LAY_FORMAT_JPG;
    catalogFileInfo2.coverMediaType = LAY_MEDIA_IMAGE;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat heightOfStatusAndNavBar = [styleGuide heightOfStatusAnsNavigationBar];
    LayCatalogDetails *catalogView = [[LayCatalogDetails alloc]initWithCatalogFileInfo:catalogFileInfo2 andPositionY:heightOfStatusAndNavBar];
    catalogView.tag = TAG_CATALOG_INFO_DOWNLOAD;
    [self.view addSubview:catalogView];
    //
    const CGFloat viewWidth = self.view.frame.size.width;
    UIImage *imageUnpack = [LayImage imageWithId:LAY_IMAGE_DOWNLOAD];
    NSString *buttonText = NSLocalizedString(@"BackToMyCatalogs", nil);
    LayImportStateView *importStateView = [[LayImportStateView alloc]initWithWidth:viewWidth icon:imageUnpack andButtonText:buttonText];
    importStateView.delegate = self;
    NSString *text = NSLocalizedString(@"ImportCatalogDownloadCatalog", nil);
    [importStateView setLabelText:text];
    importStateView.tag = TAG_STATE_VIEW;
    importStateView.center = self.view.center;
    [self.view addSubview:importStateView];
}


-(void)showDownloadState {
    MWLogDebug(g_classObj, @"Download catalog:%@", self->githubCatalog->title );
    [self setupNavigationDownloadState];
    [self setupDownloadStateView];
    [self performSelectorInBackground:@selector(downloadCatalog) withObject:nil];
}

-(void)showUnzipState {
    if(!self->urlZippedCatalog) {
        MWLogError(g_classObj, @"Object is not properly initialized! URL to zipped catalog is nil!");
        return;
    }
    MWLogDebug(g_classObj, @"Unzip catalog-file:", [self->urlZippedCatalog path] );
    [self setupNavigationUnzipState];
    LayImportStateView *importStateView = (LayImportStateView *)[self.view viewWithTag:TAG_STATE_VIEW];
    if( !importStateView ) {
        [self setupUnzipStateView];
    } else {
        NSString *text = NSLocalizedString(@"ImportUnpackCatalog", nil);
        LayImportStateView *importStateView = (LayImportStateView *)[self.view.window viewWithTag:TAG_STATE_VIEW];
        [importStateView setLabelText:text];
        UIImage *imageUnpack = [LayImage imageWithId:LAY_IMAGE_UNPACK];
        [importStateView setIcon:imageUnpack];
    }
    [self performSelectorInBackground:@selector(unzipCatalog) withObject:nil];
}

-(void)showErrorUnzipState {
    NSString *text = NSLocalizedString(@"ImportUnpackCatalogError", nil);
    LayImportStateView *importStateView = (LayImportStateView *)[self.view viewWithTag:TAG_STATE_VIEW];
    [importStateView showErrorStateWithText:text];
}

-(void)showLabelReadingCatalogInfo {
    NSString *text = NSLocalizedString(@"ImportReadCatalogInfo", nil);
    LayImportStateView *importStateView = (LayImportStateView *)[self.view.window viewWithTag:TAG_STATE_VIEW];
    [importStateView setLabelText:text];
}

-(void)showLabelCreateThumbnails {
    NSString *text = NSLocalizedString(@"ImportCatalogCreateThumbnailState", nil);
    LayImportStateView *importStateView = (LayImportStateView *)[self.view.window viewWithTag:TAG_STATE_VIEW];
    [importStateView setLabelText:text];
}

-(void)showLabelOptimizeSearch {
    NSString *text = NSLocalizedString(@"ImportCatalogCreateOptimizeSearch", nil);
    LayImportStateView *importStateView = (LayImportStateView *)[self.view.window viewWithTag:TAG_STATE_VIEW];
    [importStateView setLabelText:text];
}

-(void)resetProgressView {
    LayImportStateView *importStateView = (LayImportStateView *)[self.view.window viewWithTag:TAG_STATE_VIEW];
    [importStateView.progressView setProgress:0.0f animated:NO];
}

-(void)setProgressViewComplete {
    LayImportStateView *importStateView = (LayImportStateView *)[self.view.window viewWithTag:TAG_STATE_VIEW];
    [importStateView.progressView setProgress:1.0f animated:YES];
}

-(void)setupCatalogPreview {
    if(self->importView) {
        [self->importView removeFromSuperview];
        self->importView = nil;
    }
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat heightOfStatusAndNavBar = [styleGuide heightOfStatusAnsNavigationBar];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGRect viewFrame = CGRectMake(0.0f, heightOfStatusAndNavBar, self.view.frame.size.width, self.view.frame.size.height - heightOfStatusAndNavBar);
    self->importView = [[UIScrollView alloc]initWithFrame:viewFrame];
    self->importView.backgroundColor = [styleGuide getColor:BackgroundColor];
    self->importView.clipsToBounds = YES;
    //
    const CGSize buttonSize = CGSizeMake(viewFrame.size.width-2*hSpace, [styleGuide getDefaultButtonHeight]);
    // check if the catalog is already present
    const CGRect handleDuplicateImportFrame = CGRectMake(hSpace, V_SPACE, viewFrame.size.width-2*hSpace, 0.0f);
    self->handleDuplicateImportContainer = [[UIView alloc]initWithFrame:handleDuplicateImportFrame];
    handleDuplicateImportContainer.tag = TAG_MY_VIEWS;
    const CGRect duplicateCatalogInfoFrame = CGRectMake(0.0f, 0.0f, viewFrame.size.width-2*hSpace, 0.0f);
    UILabel *duplicateCatalogInfo = [[UILabel alloc]initWithFrame:duplicateCatalogInfoFrame];
    duplicateCatalogInfo.tag = TAG_MY_VIEWS;
    duplicateCatalogInfo .numberOfLines = [styleGuide numberOfLines];
    duplicateCatalogInfo.backgroundColor = [UIColor clearColor];
    duplicateCatalogInfo.font = [styleGuide getFont:NormalPreferredFont];
    duplicateCatalogInfo.text = NSLocalizedString(@"ImportInfoDuplicateCatalog", nil);
    [duplicateCatalogInfo sizeToFit];
    [handleDuplicateImportContainer addSubview:duplicateCatalogInfo];
    const CGRect deleteStoredCatalogButtonFrame = CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height);
    NSString* deleteStoredCatalogButtonLabel = NSLocalizedString(@"ImportDeleteDuplicateCatalogButton", nil);
    LayButton *deleteStoredCatalogButtonButton = [[LayButton alloc]initWithFrame:deleteStoredCatalogButtonFrame label:deleteStoredCatalogButtonLabel font:[styleGuide getFont:NormalPreferredFont] andColor:[styleGuide getColor:ClearColor]];
    [deleteStoredCatalogButtonButton addTarget:self action:@selector(setupDeleteDuplicateCatalog) forControlEvents:UIControlEventTouchUpInside];
    [deleteStoredCatalogButtonButton fitToContent];
    [handleDuplicateImportContainer addSubview:deleteStoredCatalogButtonButton];
    handleDuplicateImportContainer.hidden = YES;
    CGFloat neededHeight = [LayVBoxLayout layoutSubviewsOfView:self->handleDuplicateImportContainer withSpace:V_SPACE];
    [LayFrame setHeightWith:neededHeight toView:handleDuplicateImportContainer animated:NO];
    [importView addSubview:handleDuplicateImportContainer];
    // catalog details
    self->catalogDetailView = [[LayCatalogDetails alloc]initWithCatalogFileInfo:self->catalogFileInfo andPositionY:0.0f];
    self->catalogDetailView.tag = TAG_MY_VIEWS;
    [importView addSubview:catalogDetailView];
    // More details button
    if(self->catalogFileInfo.catalogDescription) {
        const CGRect moreDetailsButtonFrame = CGRectMake(hSpace, 0.0f, buttonSize.width, buttonSize.height);
        NSString* moreDetailsLabel = NSLocalizedString(@"ImportShowDescription", nil);
        self->moreDetailsButton = [[LayButton alloc]initWithFrame:moreDetailsButtonFrame label:moreDetailsLabel font:[styleGuide getFont:NormalPreferredFont] andColor:[styleGuide getColor:ClearColor]];
        self->moreDetailsButton.tag = TAG_MY_VIEWS;
        [moreDetailsButton addTarget:self action:@selector(showDescription) forControlEvents:UIControlEventTouchUpInside];
        [moreDetailsButton fitToContent];
        [importView addSubview:moreDetailsButton];
    }
    // import question
    const CGRect questionLabelFrame = CGRectMake(hSpace, 0.0f, viewFrame.size.width-2*hSpace, 0.0f);
    self->importQuestionLabel = [[UILabel alloc]initWithFrame:questionLabelFrame];
    self->importQuestionLabel.tag = TAG_MY_VIEWS;
    self->importQuestionLabel .numberOfLines = [styleGuide numberOfLines];
    self->importQuestionLabel.backgroundColor = [UIColor clearColor];
    importQuestionLabel.font = [styleGuide getFont:NormalPreferredFont];
    importQuestionLabel.text = NSLocalizedString(@"ImportQuestion", nil);
    [importQuestionLabel sizeToFit];
    [importView addSubview:importQuestionLabel];
    // buttonContainer
    const CGRect buttonFrame = CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height);
    NSString *okLabel = NSLocalizedString(@"ImportOkLabel", nil);
    self->okButton = [[LayButton alloc]initWithFrame:buttonFrame label:okLabel font:[styleGuide getFont:NormalPreferredFont] andColor:[styleGuide getColor:ClearColor]];
    self->okButton.tag = TAG_MY_VIEWS;
    [self->okButton fitToContent];
    [okButton addTarget:self action:@selector(showImportState) forControlEvents:UIControlEventTouchUpInside];
    NSString *abortLabel = NSLocalizedString(@"ImportAbortLabel", nil);
    self->abortButton = [[LayButton alloc]initWithFrame:buttonFrame label:abortLabel font:[styleGuide getFont:NormalPreferredFont] andColor:[styleGuide getColor:ClearColor]];
    [self->abortButton fitToContent];
    [abortButton addTarget:self action:@selector(showMyCatalogs) forControlEvents:UIControlEventTouchUpInside];
    const CGRect buttonContainerFrame = CGRectMake(hSpace, 0.0f, viewFrame.size.width-2*hSpace, buttonSize.height);
    self->buttonContainer = [[UIView alloc]initWithFrame:buttonContainerFrame];
    self->buttonContainer.tag = TAG_MY_VIEWS;
    [buttonContainer addSubview:okButton];
    [buttonContainer addSubview:abortButton];
    [self layoutButtons:buttonContainer];
    [importView addSubview:buttonContainer];
    // Status message
    const CGRect statusMessageFrame = CGRectMake(hSpace, 0.0f, viewFrame.size.width-2*hSpace, 0.0);
    self->statusMessage = [[UILabel alloc]initWithFrame:statusMessageFrame];
    self->statusMessage.tag = TAG_MY_VIEWS;
    self->statusMessage.backgroundColor = [UIColor clearColor];
    statusMessage.numberOfLines = [styleGuide numberOfLines];
    statusMessage.font = [styleGuide getFont:NormalPreferredFont];
    [importView addSubview:statusMessage];
    // send error report
    NSString *sendReportLabel = NSLocalizedString(@"ImportSendReportMail", nil);
    const CGRect sendReportFrame = CGRectMake(hSpace, 0.0f, buttonSize.width, buttonSize.height);
    self->sendReport = [[LayButton alloc]initWithFrame:sendReportFrame label:sendReportLabel font:[styleGuide getFont:NormalPreferredFont] andColor:[styleGuide getColor:ClearColor]];
    self->sendReport.tag = TAG_MY_VIEWS;
    [sendReport addTarget:self action:@selector(sendErrorReport) forControlEvents:UIControlEventTouchUpInside];
    sendReport.hidden = YES;
    [importView addSubview:sendReport];
    const CGRect sendReportMessageFrame = CGRectMake(hSpace, 0.0f, viewFrame.size.width-2*hSpace, 0.0);
    self->sendReportMessage = [[UILabel alloc]initWithFrame:sendReportMessageFrame];
    self->sendReportMessage.tag = TAG_MY_VIEWS;
    self->sendReportMessage.backgroundColor = [UIColor clearColor];
    sendReportMessage.numberOfLines = [styleGuide numberOfLines];
    sendReportMessage.font = [styleGuide getFont:NormalPreferredFont];
    sendReportMessage.hidden = YES;
    [importView addSubview:sendReportMessage];
    
    if(self->catalogFileInfo) {
        // Check oif there is a catalog with the same title and publisher
        NSString *titleOfCatalog = self->catalogFileInfo.catalogTitle;
        NSString *publisherOfCatalog = [self->catalogFileInfo detailForKey:@"publisher"];
        Catalog *catalog = [[LayMainDataStore store] findCatalogByTitle:titleOfCatalog andPublisher:publisherOfCatalog];
        if(catalog) {
            self->okButton.hidden = YES;
            self->importQuestionLabel.hidden = YES;
            [self layoutButtons:self->buttonContainer];
            self->handleDuplicateImportContainer.hidden = NO;
        }
    } else {
        // The info-section of the catalog could not be read
        self->catalogDetailView.hidden = YES;
        self->moreDetailsButton.hidden = YES;
        self->importQuestionLabel.hidden = YES;
        [self adjustViewToFailedImport];
    }
    [self.view addSubview:self->importView];
    [self layoutView];
}

-(void)showCatalogPreview {
    [self setupCatalogPreview];
    [LayFrame setHeightWith:0.0f toView:self->importView animated:NO];
    UIView *unzipStateView = [self.view viewWithTag:TAG_STATE_VIEW];
    unzipStateView.clipsToBounds = YES;
    const CGFloat unzipStateViewWidth = unzipStateView.frame.size.width;
    CALayer *unzipStateViewLayer = unzipStateView.layer;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat heightOfStatusAndNavBar = [styleGuide heightOfStatusAnsNavigationBar];
    const CGFloat importViewHeight = self.view.frame.size.height - heightOfStatusAndNavBar;
    const CGFloat importViewWidth = self.view.frame.size.width;
    CALayer *importViewLayer = self->importView.layer;
    CGPoint importViewPos = CGPointMake(self.view.layer.position.x, (importViewHeight / 2.0f) + heightOfStatusAndNavBar);
    importViewLayer.position = importViewPos;
    [UIView animateWithDuration:0.3 animations:^{
        importViewLayer.position = importViewPos;
        importViewLayer.bounds = CGRectMake(0.0f, 0.0f, importViewWidth, importViewHeight);
        unzipStateViewLayer.bounds = CGRectMake(0.0f, 0.0f, unzipStateViewWidth, 0.0f);
    } completion:^(BOOL finished) {
        [unzipStateView removeFromSuperview];
    }];
}

-(void)showImportState {
    [self setupImportStateView];
    [self performSelectorInBackground:@selector(importCatalog) withObject:nil];
}

-(void)setupImportStateView {
    NSString *text = NSLocalizedString(@"ImportCatalogState", nil);
    UIImage *image = [LayImage imageWithId:LAY_IMAGE_IMPORT];
    [self setupStateViewWithText:text andImage:image];
}

-(void)setupStateViewWithText:(NSString*)text andImage:(UIImage*)image {
    const CGRect backgroundFrame = self.view.window.frame;
    UIView *backgroundView = [[UIView alloc]initWithFrame:backgroundFrame];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    backgroundView.backgroundColor = [styleGuide getColor:GrayTransparentBackground];
    NSString *buttonText = NSLocalizedString(@"BackToMyCatalogs", nil);
    LayImportStateView *importStateView = [[LayImportStateView alloc]initWithWidth:backgroundFrame.size.width icon:image andButtonText:buttonText];
    importStateView.backgroundColor = [styleGuide getColor:WhiteBackground];
    importStateView.delegate = self;
    [importStateView setLabelText:text];
    importStateView.tag = TAG_STATE_VIEW;
    
    const CGFloat vSpace = 20.0f;
    const CGFloat heightStateViewContainer = importStateView.frame.size.height + 2 * vSpace;
    const CGRect stateViewContainerRect = CGRectMake(0.0f, 0.0f, backgroundFrame.size.width, heightStateViewContainer);
    UIView *importStateViewContainer = [[UIView alloc]initWithFrame:stateViewContainerRect];
    importStateViewContainer.backgroundColor = [styleGuide getColor:WhiteBackground];
    importStateView.center = importStateViewContainer.center;
    [importStateViewContainer addSubview:importStateView];
    // prepare animation
    importStateViewContainer.center = backgroundView.center;
    const CGFloat heightImportStateView = importStateViewContainer.frame.size.height;
    [LayFrame setHeightWith:0.0f toView:importStateViewContainer animated:NO];
    importStateViewContainer.clipsToBounds = YES;
    [backgroundView addSubview:importStateViewContainer];
    [self.view.window addSubview:backgroundView];
    // animation
    const CGFloat widthImportStateView = importStateViewContainer.frame.size.width;
    CALayer *importStateViewLayer = importStateViewContainer.layer;
    importStateViewLayer.position = self.view.window.layer.position;
    [UIView animateWithDuration:0.4 animations:^{
        importStateViewLayer.position = self.view.window.layer.position;
        importStateViewLayer.bounds = CGRectMake(0.0f, 0.0f, widthImportStateView, heightImportStateView);
    }];
}

-(void)removeImportStateView {
    UIView *importStateView = [self.view.window viewWithTag:TAG_STATE_VIEW];
    if(importStateView) {
        UIView* stateViewContainer = importStateView.superview;
        UIView *backgroundView = stateViewContainer.superview;
        [backgroundView removeFromSuperview];
    }
}

-(void)showImportFinished:(LayCatalogImportReport*)importReport {
    [self removeImportStateView];
    BOOL state = YES;
    NSString *hint  = nil;
    if(importReport.imported) {
        MWLogInfo(g_classObj, @"Imported catalog successfully!");
        self->statusMessage.hidden = YES;
        hint = NSLocalizedString(@"ImportSuccessfully", nil);
        self->abortButton.hidden = YES;
        self->okButton.label = NSLocalizedString(@"OpenCatalog", nil);
        [okButton removeTarget:self action:@selector(importCatalog) forControlEvents:UIControlEventTouchUpInside];
        [okButton addTarget:self action:@selector(openCatalog) forControlEvents:UIControlEventTouchUpInside];
        [self->okButton fitToContent];
    } else {
        state = NO;
        hint = NSLocalizedString(@"ImportErrorShort", nil);
        [self adjustViewToFailedImport];
    }
    self->importQuestionLabel.hidden = YES;
    [self->statusMessage sizeToFit];
    [self layoutView];
    
    if(hint) {
        [self showHint:hint withTarget:nil andAction:nil state:state];
    }
}

-(void)showDeleteDuplicateCatalogFinished:(NSNumber*)catalogDeleted {
    [self removeImportStateView];
    BOOL deletedCatalog = [catalogDeleted boolValue];
    if(deletedCatalog) {
        self->okButton.hidden = NO;
        self->importQuestionLabel.hidden = NO;
        [self layoutButtons:self->buttonContainer];
        [self layoutView];
        NSString *hint = NSLocalizedString(@"ImportDeletedDuplicateCatalogSuccessfully", nil);
        [self hideHandleDuplicateFrame];
        [self showHint:hint withTarget:nil andAction:nil state:YES];
    } else {
        NSString *hint = NSLocalizedString(@"ImportDeletedDuplicateCatalogWithErrors", nil);
        [self showHint:hint withTarget:nil andAction:nil state:NO];
    }
}

// runs in another thread
-(void)unzipCatalog {
    NSURL *unzippedCatalogDirectory = [LayXmlCatalogFileReader unzipCatalog:self->urlZippedCatalog andStateDelegate:self];
    [self performSelectorOnMainThread:@selector(setProgressViewComplete) withObject:nil waitUntilDone:NO];
    [NSThread sleepForTimeInterval:1.5];
    if( !unzippedCatalogDirectory ) {
        MWLogError(g_classObj, @"unzipCatalog:(%@) returned nil!", self->urlZippedCatalog );
        [self performSelectorOnMainThread:@selector(showErrorUnzipState) withObject:nil waitUntilDone:NO];
        [LayCatalogManager cleanupInboxAndTmpDir];
    } else {
        MWLogInfo(g_classObj, @"Unzipped catalog:%@ sucessfully.", self->urlZippedCatalog );
        NSString* nameOfCatalogXmlFile = [LayXmlCatalogFileReader getNameOfCatalogFile:unzippedCatalogDirectory];
        if(nameOfCatalogXmlFile) {
            MWLogDebug(g_classObj, @"Name of catalog-file is:%@", nameOfCatalogXmlFile );
            NSURL *urlToXmlCatalogFile = [unzippedCatalogDirectory URLByAppendingPathComponent:nameOfCatalogXmlFile];
            if(urlToXmlCatalogFile) {
                [self performSelectorOnMainThread:@selector(showLabelReadingCatalogInfo) withObject:nil waitUntilDone:NO];
                [self performSelectorOnMainThread:@selector(resetProgressView) withObject:nil waitUntilDone:NO];
                self->catalogFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFileNotReadinCatalogInfo:urlToXmlCatalogFile];
                if(self->catalogFileReader) {
                    [self->catalogFileReader readMetaInfoWithStateDelegate:self];
                    [self performSelectorOnMainThread:@selector(setProgressViewComplete) withObject:nil waitUntilDone:NO];
                     [NSThread sleepForTimeInterval:1.5];
                    //
                    if( self->githubCatalog ) {
                        // the version, publisher and title of the github-catalog have precedence for the values within the catalog's xml
                        LayCatalogFileInfo *metaInfo = [self->catalogFileReader metaInfo];
                        metaInfo.catalogTitle = self->githubCatalog->title;
                        [metaInfo setDetail:self->githubCatalog->name forKey:@"publisher"];
                        [metaInfo setDetail:self->githubCatalog->version forKey:@"version"];
                    }
                    //
                    self->catalogFileInfo = [self->catalogFileReader metaInfo];
                    self->catalogWasUnzipped = YES;
                    [self performSelectorOnMainThread:@selector(setupNavigationUnzipFinished) withObject:nil waitUntilDone:NO];
                    [self performSelectorOnMainThread:@selector(showCatalogPreview) withObject:nil waitUntilDone:NO];
                } else {
                    MWLogError(g_classObj, @"CatalogFileReader is nil!");
                }
            }
        } else {
            MWLogError(g_classObj, @"There is no XML-file in the package:%@", self->urlZippedCatalog );
            [self performSelectorOnMainThread:@selector(showErrorUnzipState) withObject:nil waitUntilDone:NO];
            [LayCatalogManager cleanupInboxAndTmpDir];
        }
    }
}

-(void)downloadCatalog {
    NSURL *zipBallUrl = [NSURL URLWithString:self->githubCatalog->zipball_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:zipBallUrl];
    self->downlaodOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    //
    NSString *pathToTmpDir = NSTemporaryDirectory();
    NSString *fileNameToCreate = [NSString stringWithFormat:@"%@.zip", self->githubCatalog->repoName];
    NSString *fullPath = [pathToTmpDir stringByAppendingPathComponent:fileNameToCreate];
    NSOutputStream *fullPathOutStream = [NSOutputStream outputStreamToFileAtPath:fullPath append:NO];
    [self->downlaodOperation setOutputStream:fullPathOutStream];
    [self->downlaodOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        [self setMaxSteps:totalBytesExpectedToRead];
        [self setStep:totalBytesRead];
    }];
    //
    [self->downlaodOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"RES: %@", [[[operation response] allHeaderFields] description]);
        NSError *error;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
        if (error) {
            MWLogError([g_classObj class], @"Details:%@", [error description] );
        } else {
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            MWLogInfo([g_classObj class], @"Downloaded file:%@ with size:%lld", fileNameToCreate, fileSize );
            [self performSelectorOnMainThread:@selector(setProgressViewComplete) withObject:nil waitUntilDone:NO];
            self->urlZippedCatalog = [NSURL fileURLWithPath:fullPath];
            [self showUnzipState];
        }
        self->downlaodOperation = nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MWLogError([g_classObj class], @"Can not download file:%@ details:%@", fileNameToCreate, [error description] );
        self->downlaodOperation = nil;
    }];
    
    [self->downlaodOperation start];
}

-(void)importCatalog {
    UIBackgroundTaskIdentifier taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
    // Create new logfile
    [LayAppConfiguration configureLogging];
    //
    self->maxImportSteps = 0;
    self->currentImportStep = 0;
    
    NSSet *stopWordSet = [self stopWordSet];
    LayCatalogImport *catalogImport = [[LayCatalogImport alloc]initWithDataFileReader:self->catalogFileReader];
    LayCatalogImportReport* importReport = [catalogImport importWithStateDelegate:self andStopWordSet:stopWordSet];
    [self performSelectorOnMainThread:@selector(setProgressViewComplete) withObject:nil waitUntilDone:NO];
    if(importReport.imported) {
        [self performSelectorOnMainThread:@selector(setProgressViewComplete) withObject:nil waitUntilDone:NO];
        [NSThread sleepForTimeInterval:1.5];
        [self performSelectorOnMainThread:@selector(showImportFinished:) withObject:importReport waitUntilDone:NO];
        // delete temorary import files
        [LayCatalogManager cleanupInboxAndTmpDir];
    } else {
        [NSThread sleepForTimeInterval:1.0];
        [self performSelectorOnMainThread:@selector(showImportFinished:) withObject:importReport waitUntilDone:NO];
        // delete temorary import files
        [LayCatalogManager cleanupInboxAndTmpDir];
    }
    
    if(taskId == UIBackgroundTaskInvalid) {
        MWLogWarning(g_classObj, @"Could not run import as long running backgroundtask.");
    } else {
        MWLogInfo(g_classObj, @"Mark import task as finished.");
        [[UIApplication sharedApplication] endBackgroundTask:taskId];
    }
}

-(NSSet*)stopWordSet {
    NSMutableSet *allKeywordSet = [NSMutableSet setWithCapacity:200];
    NSError *error = nil;
    NSString *deStopWordListFilePath = [[NSBundle mainBundle] pathForResource:@"stopwords_de" ofType:@"txt"];
    NSString *germanStopWords = [NSString stringWithContentsOfFile:deStopWordListFilePath encoding:NSUTF8StringEncoding error:&error];
    if( !germanStopWords && error ) {
        MWLogError(g_classObj, @"Could not read german stop word list. Details:%@", [error description]);
    } else {
        NSSet *germanSet = [NSSet setWithArray:[germanStopWords componentsSeparatedByString:@"\r\n"]];
        [allKeywordSet unionSet:germanSet];
    }
    
    NSString *enStopWordListFilePath = [[NSBundle mainBundle] pathForResource:@"stopwords_en" ofType:@"txt"];
    NSString *enStopWords = [NSString stringWithContentsOfFile:enStopWordListFilePath encoding:NSUTF8StringEncoding error:&error];
    if( !enStopWords && error ) {
        MWLogError(g_classObj, @"Could not read english stop word list. Details:%@", [error description]);
    } else {
        NSSet *enSet = [NSSet setWithArray:[enStopWords componentsSeparatedByString:@"\r\n"]];
        [allKeywordSet unionSet:enSet];
    }
    
    return allKeywordSet;
}

-(void)deleteDuplicateCatalog {
    self->maxImportSteps = 0;
    self->currentImportStep = 0;
    NSString *titleOfCatalog = self->catalogFileInfo.catalogTitle;
    NSString *publisherOfCatalog = [self->catalogFileInfo detailForKey:@"publisher"];
    Catalog *catalog = [[LayMainDataStore store] findCatalogByTitle:titleOfCatalog andPublisher:publisherOfCatalog];
    if(catalog) {
        [self performSelectorOnMainThread:@selector(prepareDeleteCatalogProgressView:) withObject:catalog waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(startDeleteCatalogProgressView) withObject:catalog waitUntilDone:NO];
        BOOL deletedCatalog = [LayMainDataStore deleteCatalogWithinNewCreatedContext:catalog];
        [self performSelectorOnMainThread:@selector(stopDeleteDuplicateCatalogStepTimer) withObject:catalog waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(setProgressViewComplete) withObject:nil waitUntilDone:NO];
        [NSThread sleepForTimeInterval:1.5];
        NSNumber *catalogDeleted = [NSNumber numberWithBool:deletedCatalog];
        [self performSelectorOnMainThread:@selector(showDeleteDuplicateCatalogFinished:) withObject:catalogDeleted waitUntilDone:NO];
    } else {
        MWLogError(g_classObj, @"Could not find catalog:(%@, %@) for deletion!", titleOfCatalog, publisherOfCatalog);
        NSNumber *catalogDeleted = [NSNumber numberWithBool:NO];
        [self performSelectorOnMainThread:@selector(showDeleteDuplicateCatalogFinished:) withObject:catalogDeleted waitUntilDone:NO];
    }
}

-(void)prepareDeleteCatalogProgressView:(Catalog*)catalogToDelete {
    const NSUInteger numberOfQuestions = [catalogToDelete numberOfQuestions];
    const NSUInteger numberOfExplanations = [catalogToDelete numberOfExplanations];
    const NSUInteger numberOfSteps = numberOfQuestions + numberOfExplanations;
    [self setMaxSteps:numberOfSteps];
}

-(void)startDeleteCatalogProgressView {
    self->deleteDuplicateCatalogStepTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateDeleteCatalogProgressView) userInfo:nil repeats:YES];
}

-(void)updateDeleteCatalogProgressView {
    self->currentImportStep++;
    if(self->currentImportStep == self->maxImportSteps) {
        [self stopDeleteDuplicateCatalogStepTimer];
    }
    [self updateProgressView];
}

-(void)stopDeleteDuplicateCatalogStepTimer {
    if(self->deleteDuplicateCatalogStepTimer) {
        [self->deleteDuplicateCatalogStepTimer invalidate];
        self->deleteDuplicateCatalogStepTimer = nil;
    }
}

-(void)layoutButtons:(UIView*)container {
    const CGFloat buttonSpace = 20.0f;
    CGFloat xPos = 0.0f;
    for (UIView* button in [container subviews]) {
        if(!button.hidden) {
            [LayFrame setXPos:xPos toView:button];
            xPos = xPos + button.frame.size.width + buttonSpace;
        }
    }
}

-(void)layoutView {
    CGFloat space = V_SPACE;
    CGFloat currentOffsetY = 15.0f;
    for (UIView *subview in self->importView.subviews) {
        if(subview.tag != TAG_MY_VIEWS) continue;
        
        if(!subview.hidden) {
            CGRect subViewFrame = subview.frame;
            // y-Pos
            subViewFrame.origin.y = currentOffsetY;
            subview.frame = subViewFrame;
            currentOffsetY += subViewFrame.size.height + space;
        }
    }
    CGSize newSize = CGSizeMake(self.view.frame.size.width, currentOffsetY);
    [self->importView setContentSize:newSize];
}

//
// Action handlers
//

-(void)setupDeleteDuplicateCatalog {
    NSString *text = NSLocalizedString(@"ImportDeleteCatalogState", nil);
    UIImage *image = [LayImage imageWithId:LAY_IMAGE_IMPORT];
    [self setupStateViewWithText:text andImage:image];
    [self performSelectorInBackground:@selector(deleteDuplicateCatalog) withObject:nil];
}

-(void) hideHandleDuplicateFrame {
    self->handleDuplicateImportContainer.hidden = YES;
    
    CGFloat space = V_SPACE;
    CGFloat currentOffsetY = 15.0f;
    for (UIView *subview in self->importView.subviews) {
        if(subview.tag != TAG_MY_VIEWS) continue;
        
        if(!subview.hidden) {
            CGRect subViewFrame = subview.frame;
            // y-Pos
            subViewFrame.origin.y = currentOffsetY;
            [UIView animateWithDuration:0.3 animations:^{
                subview.frame = subViewFrame;
            }];
            currentOffsetY += subViewFrame.size.height + space;
        }
    }
    CGSize newSize = CGSizeMake(self.view.frame.size.width, currentOffsetY);
    [self->importView setContentSize:newSize];
}

-(void) showHint:(NSString*)hint withTarget:(id)target andAction:(SEL)action state:(BOOL)state {
    [self showHint:hint withTarget:target andAction:action state:state andDuration:2.0f];
}

-(void) showHint:(NSString*)hint withTarget:(id)target andAction:(SEL)action state:(BOOL)state andDuration:(CGFloat)duration {
    const CGRect viewFrame = [[UIScreen mainScreen] bounds];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    LayStyleGuideColor color = AnswerCorrect;
    if(!state) {
        color = AnswerWrong;
    }
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGFloat width = viewFrame.size.width-2*hSpace;
    LayHintView *hintView = [[LayHintView alloc]initWithWidth:width view:self.view target:target andAction:action];
    hintView.duration = duration;
    [hintView showHint:hint withBorderColor:color];
}

-(void)adjustViewToFailedImport {
    MWLogInfo(g_classObj, @"Could not import the catalog!");
    BOOL emailAuthorSet = NO;
    NSString *emailAuthor = [self->catalogFileInfo detailForKey:@"emailAuthor"];
    if([emailAuthor length] > 3) {
        // TODO_ email pattern check during the import
        self->statusMessage.text = NSLocalizedString(@"ImportErrorEmailAuthor", nil);
        emailAuthorSet = YES;
    } else {
        self->statusMessage.text = NSLocalizedString(@"ImportError", nil);
    }
    
    [self->statusMessage sizeToFit];
    self->statusMessage.hidden = NO;
    self->abortButton.hidden = YES;
    self->okButton.label = NSLocalizedString(@"BackToMyCatalogs", nil);
    [okButton removeTarget:self action:@selector(importCatalog) forControlEvents:UIControlEventTouchUpInside];
    [okButton addTarget:self action:@selector(showMyCatalogs) forControlEvents:UIControlEventTouchUpInside];
    [self->okButton fitToContent];
    if([MFMailComposeViewController canSendMail] && emailAuthorSet) {
        self->sendReport.hidden = NO;
        [self->sendReport fitToContent];
    }
}

-(void)openCatalog {
    NSString *titleOfCatalog = self->catalogFileInfo.catalogTitle;
    NSString *publisherOfCatalog = [self->catalogFileInfo detailForKey:@"publisher"];
    Catalog *catalog = [[LayMainDataStore store] findCatalogByTitle:titleOfCatalog andPublisher:publisherOfCatalog];
    if(catalog) {
        [LayCatalogManager instance].currentSelectedCatalog = catalog;
        [LayCatalogManager instance].currentCatalogShouldBeOpenedDirectly = YES;
        [self showMyCatalogsNoAnimation];
    } else {
        MWLogInfo(g_classObj, @"Could not open the catalog!");
        self->okButton.label = NSLocalizedString(@"BackToMyCatalogs", nil);
        [self->okButton fitToContent];
        [okButton removeTarget:self action:@selector(openCatalog) forControlEvents:UIControlEventTouchUpInside];
        [okButton addTarget:self action:@selector(showMyCatalogs) forControlEvents:UIControlEventTouchUpInside];
        self->statusMessage.text = NSLocalizedString(@"ImportOpenCatalogError", nil);
        [self->statusMessage sizeToFit];
        self->sendReport.hidden = NO;
        [self->sendReport fitToContent];
        [self layoutView];
    }
}

// Action handlers
-(void) showDescription {
    [self->catalogDetailView showDescription];
    [self->moreDetailsButton removeTarget:self action:@selector(showDescription) forControlEvents:UIControlEventTouchUpInside];
    [self->moreDetailsButton addTarget:self action:@selector(hideDescription) forControlEvents:UIControlEventTouchUpInside];
    self->moreDetailsButton.label = NSLocalizedString(@"ImportHiddeDescription", nil);
    [self->moreDetailsButton fitToContent];
    [self layoutView];
}

-(void)hideDescription {
    [self->catalogDetailView hideDescription];
    [self->moreDetailsButton removeTarget:self action:@selector(hiddeDescription) forControlEvents:UIControlEventTouchUpInside];
    [self->moreDetailsButton addTarget:self action:@selector(showDescription) forControlEvents:UIControlEventTouchUpInside];
    self->moreDetailsButton.label = NSLocalizedString(@"ImportShowDescription", nil);
    [self->moreDetailsButton fitToContent];
    [self layoutView];
}

-(void)showMyCatalogs {
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    [catalogManager performSelectorInBackground:@selector(cleanupInboxAndTmpDir) withObject:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showMyCatalogsNoAnimation {
    if(self->githubCatalog) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

-(void)sendErrorReport {
    // This sample can run on devices running iPhone OS 2.0 or later
	// The MFMailComposeViewController class is only available in iPhone OS 3.0 or later.
	// So, we must verify the existence of the above class and provide a workaround for devices running
	// earlier versions of the iPhone OS.
	// We display an email composition interface if MFMailComposeViewController exists and the device can send emails.
	// We launch the Mail application on the device, otherwise.
	if ([MFMailComposeViewController canSendMail])
	{
        MWLogInfo(g_classObj, @"Try to send error report by mail.");
        MFMailComposeViewController *mailComposeViewController= [[MFMailComposeViewController alloc] init];
        mailComposeViewController.mailComposeDelegate = self;
        NSString *catalogTitle = @"?";
        if(self->catalogFileInfo) {
            catalogTitle = self->catalogFileInfo.catalogTitle;
        }
        NSString* subject = [NSString stringWithFormat:@"KEEMI / error report for catalog: %@!", catalogTitle];
        [mailComposeViewController setSubject:subject];
        
        // Set up recipients
        NSString *emailAuthor = [self->catalogFileInfo detailForKey:@"emailAuthor"];
        NSArray *toRecipients = [NSArray arrayWithObject:emailAuthor];
        
        [mailComposeViewController setToRecipients:toRecipients];
        
        NSData *contentOfLog = [LayAppConfiguration contentOfLogFile];
        if(contentOfLog) {
            [mailComposeViewController addAttachmentData:contentOfLog mimeType:@"text/plain" fileName:@"KeemiImportErrorReport.txt"];
        }
        
        // Fill out the email body text
        NSString *emailBody = [NSString stringWithFormat:@"The catalog:\"%@\" could not be imported!", catalogTitle];
        LayError *error = [self->catalogFileReader readError];
        if(error) {
            emailBody = [emailBody stringByAppendingFormat:@" Details:%@", error.details];
        }
        [mailComposeViewController setMessageBody:emailBody isHTML:NO];
        
        [self presentViewController:mailComposeViewController animated:YES completion:nil];
    }
	else
	{
        MWLogWarning( g_classObj, @"The app needs at least version 6 of ios OR email is not setup!");
	}
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if(error) {
        MWLogError(g_classObj, @"mailComposeController:%@,%d", [error domain], [error code]);
    }
    NSString *reportMessage = nil;
	// Notifies users about errors associated with the interface
    BOOL sencondChoiceToSendReport = YES;
	switch (result)
	{
		case MFMailComposeResultCancelled:
			reportMessage = NSLocalizedString(@"ImportNotSentReport", nil);
			break;
		case MFMailComposeResultSaved:
			reportMessage = NSLocalizedString(@"ImportSavedReport", nil);
            sencondChoiceToSendReport = NO;
			break;
		case MFMailComposeResultSent:
			reportMessage = NSLocalizedString(@"ImportSentReport", nil);
            sencondChoiceToSendReport = NO;
			break;
		case MFMailComposeResultFailed:
			reportMessage = NSLocalizedString(@"ImportCouldNotSentReport", nil);
			break;
		default:
			reportMessage = NSLocalizedString(@"ImportCouldNotSentReport", nil);
			break;
	}
    self->sendReportMessage.hidden = NO;
    self->sendReportMessage.text = reportMessage;
    [self->sendReportMessage sizeToFit];
    
    if(!sencondChoiceToSendReport) {
        self->sendReport.hidden = YES;
    }
    
    [self layoutView];
    
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateProgressView {
    LayImportStateView *importStateView = (LayImportStateView *)[self.view.window viewWithTag:TAG_STATE_VIEW];
    CGFloat stepProgress = (CGFloat)self->currentImportStep / (CGFloat)self->maxImportSteps;
    UIProgressView *progressView = importStateView.progressView;
    if(progressView) {
        [progressView setProgress:stepProgress animated:YES];
    }
}

//
// LayImportProgressDelegate
//
-(void)setMaxSteps:(NSUInteger)maxSteps {
    self->maxImportSteps = maxSteps;
}

-(void)setStep:(NSUInteger)step {
    self->currentImportStep = step;
    [self performSelectorOnMainThread:@selector(updateProgressView) withObject:nil waitUntilDone:NO];
}

-(void)startingNextProgressPartWithIdentifier:(NSInteger)identifiier {
    if(identifiier == LayCatalogImportProgressPartIdentifierCreatingThumbnails) {
        self->maxImportSteps = 0;
        self->currentImportStep = 0;
        [self performSelectorOnMainThread:@selector(resetProgressView) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(showLabelCreateThumbnails) withObject:nil waitUntilDone:NO];
    } else if(identifiier == LayCatalogImportProgressPartIdentifierOptimizeSearch) {
        self->maxImportSteps = 0;
        self->currentImportStep = 0;
        [self performSelectorOnMainThread:@selector(resetProgressView) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(showLabelOptimizeSearch) withObject:nil waitUntilDone:NO];
    }
}

//
// LayImportStateViewDelegate
//
-(void)buttonPressed {
    [self showMyCatalogs];
}

//
// LayVcNavigationBarDelegate
//
-(void)backPressed {
    [self showMyCatalogs];
}

-(void)cancelPressed {
    [self->downlaodOperation cancel];
    self->downlaodOperation = nil;
     LayCatalogManager *catalogManager = [LayCatalogManager instance];
    [catalogManager performSelectorInBackground:@selector(cleanupInboxAndTmpDir) withObject:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


/*-(void)debug_ActivateColorsForSubviews {
 self->catalogDetailView.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
 self->importQuestionLabel.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
 self->moreDetailsButton.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
 self->buttonContainer.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
 }*/

@end
