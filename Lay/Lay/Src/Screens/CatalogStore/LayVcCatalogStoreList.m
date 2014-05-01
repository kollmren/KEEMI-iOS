//
//  LayViewController.m
//  Lay
//
//  Created by Rene on 29.10.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayVcCatalogStoreList.h"
#import "LayMainDataStore.h"
#import "LayMyCatalogListItem.h"
#import "LayVcCatalogList.h"
#import "LayVcNavigationBar.h"
#import "LayImage.h"
#import "LayVBoxLayout.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"
#import "LayTableSectionView.h"
#import "LayAppNotifications.h"
#import "LayImportStateViewHandler.h"
#import "LayHintView.h"
#import "LayVcNavigation.h"
#import "LayVcSettings.h"
#import "LayMediaData.h"

#import "OctoKit.h"

#import "LayCatalogManager.h"
#import "MWLogging.h"


@interface LayGithubCatalog : NSObject {
@public
    NSString *title;
    NSData *cover;
    NSString *description;
    NSString *owner;
    NSString *version;
    NSString *url;
    NSString *name;
}

+(LayGithubCatalog*) catalogWithTitle:(NSString*)title cover:(NSData*)cover description:(NSString*)descr owner:(NSString*)owner url:(NSString*)url  andVersion:(NSString*)version;

@end

//
//
//static const NSInteger NUMBER_OF_SECTIONS = 1;
static NSString *urlToGetUserInfoTemplate = @"https://api.github.com/users/";

@interface LayVcCatalogStoreList () {
    //LayTableSectionView* sectionMyCatalog;
    LayImportStateViewHandler *stateViewHandler;
    LayVcNavigationBar* navBarViewController;
    NSMutableArray* githubCatalogList;
    NSURLConnection *urlConnection;
    NSMutableData *searchResultInJson;
    NSDictionary *searchResultMap;
    UIActivityIndicatorView *activity;
    LayGithubCatalog *catalogToDownload;
    NSIndexPath *indexPathToDelete;
}

@end


@implementation LayVcCatalogStoreList


- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    
    self = [super initWithNibName:@"LayVcCatalogStoreList"
                           bundle:nil];
    if (self) {
        self->navBarViewController = [[LayVcNavigationBar alloc]initWithViewController:self];
        self->navBarViewController.delegate = self;
        self->navBarViewController.cancelButtonInNavigationBar = YES;
        self->githubCatalogList = [NSMutableArray arrayWithCapacity:100];
        self->urlConnection = nil;
        self->searchResultInJson = [NSMutableData dataWithCapacity:1024];
        [self registerEvents];
    }
    return self;
}

-(void)dealloc {
    MWLogDebug([LayVcCatalogStoreList class], @"dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //
    [self->navBarViewController showButtonsInNavigationBar];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    UIFont *appTitleFont = [styleGuide getFont:AppTitleFont];
    UIColor *appNameColor = [styleGuide getColor:TextColor];
    [self->navBarViewController showTitle:@"Catalogs at GitHub" atPosition:TITLE_CENTER withFont:appTitleFont andColor:appNameColor];
    //
    //NSString *sectionMyCatalogsTitle = NSLocalizedString(@"MyCatalogs", nil);
    //self->sectionMyCatalog = [self sectionLabelWithTitle:sectionMyCatalogsTitle];
    //self.tableView.tableHeaderView = self->sectionMyCatalog;
    //
    self.tableView.backgroundColor = [styleGuide getColor:BackgroundColor];
    //
    UINib* cellXibFile = [UINib nibWithNibName:@"LayMyCatalogListItem" bundle:nil];
    [self.tableView registerNib:cellXibFile forCellReuseIdentifier:@"CatalogListItemIdentifier"];
    
    self.tableView.separatorColor = [UIColor clearColor];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated {
    
    self->activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self->activity.color = [[LayStyleGuide instanceOf:nil] getColor:ButtonSelectedColor];
    [self.tableView setBackgroundView:self->activity];
    [self->activity startAnimating];
    //[self performSelectorInBackground:@selector(searchKeemiCatalogsAtGitHub) withObject:nil];
    [self searchKeemiCatalogsAtGitHub];
    
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    if(catalogManager.currentCatalogShouldBeOpenedDirectly) {
        catalogManager.currentCatalogShouldBeOpenedDirectly = NO;
        LayVcCatalogList *vcCatalog = [LayVcCatalogList new];
        // Push it onto the top of the navigation controller's stack
        [[self navigationController] pushViewController:vcCatalog
                                               animated:NO];
    } else if(catalogManager.pendingCatalogToImport) {
        catalogManager.pendingCatalogToImport = NO;
        NSNotification *note = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_DO_IMPORT_CATALOG object:self];
        [[NSNotificationCenter defaultCenter] postNotification:note];
    } else {
        [catalogManager resetAllProperties];
        NSIndexPath *pathToSelectedRow = [self.tableView indexPathForSelectedRow];
        [self.tableView deselectRowAtIndexPath:pathToSelectedRow animated:NO];
        [self.tableView reloadData];
    }

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create an instance of UITableViewCell, with default appearance
    // Check for a reusable cell first, use that if it exists
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:@"CatalogListItemIdentifier"];
    
    // If there is no reusable cell of this type, create a new one
    if (!cell) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:@"CatalogListItemIdentifier"];
    }

    LayMyCatalogListItem *column = (LayMyCatalogListItem *)cell;
    LayGithubCatalog *catalog = [self->githubCatalogList objectAtIndex:[indexPath row]];
    NSString *numberOfQuestions = @"";
    LayMediaData *coverMediaData = [LayMediaData byData:catalog->cover type:LAY_MEDIA_IMAGE andFormat:LAY_FORMAT_JPG];
    [column setCoverWithMediaData:coverMediaData title:catalog->title publisher:catalog->owner andNumberOfQuestions:numberOfQuestions];
 
    return cell;
}

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LayGithubCatalog *catalog = [self->githubCatalogList objectAtIndex:[indexPath row]];
    [self setupCatalogToDownload:catalog atIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfCatalogsInSection = 1;
    return numberOfCatalogsInSection;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [githubCatalogList count];
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat heightOfSection = 25.0f;
    if(section == 0) {
        heightOfSection = 0.0f;
    }
    return heightOfSection;
}

-(LayTableSectionView*) sectionLabelWithTitle:(NSString*)title {
    LayTableSectionView *sectionView = [[LayTableSectionView alloc]initWithTitle:title andBorderColor:NoColor];
    return sectionView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

//
-(void)registerEvents {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleWantToImportCatalogNotification) name:(NSString*)LAY_NOTIFICATION_WANT_TO_IMPORT_CATALOG object:nil];
    [nc addObserver:self selector:@selector(handlePreferredFontSizeChanges) name:(NSString*)LAY_NOTIFICATION_PREFERRED_FONT_SIZE_CHANGED object:nil];
}

-(void)handlePreferredFontSizeChanges {
    //[self->sectionMyCatalog adjustToNewPreferredFont];
}

-(void)handleWantToImportCatalogNotification {
    if(self.navigationController.topViewController == self) {
        LayCatalogManager *catalogManager = [LayCatalogManager instance];
        if(catalogManager.pendingCatalogToImport) {
            if(self->stateViewHandler && self->stateViewHandler.busy) {
                [LayCatalogManager instance].pendingCatalogToImport = NO;
                NSNotification *note = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_IGNORE_IMPORT_CATALOG__ANOTHER_IS_STILL_IN_PROGRESS object:self];
                [[NSNotificationCenter defaultCenter] postNotification:note];
                NSString *text = NSLocalizedString(@"ImportStillATaskInProgress", nil);
                [self showHint:text withTarget:nil andAction:nil state:NO andDuration:4.0f];
            } else {
                catalogManager.pendingCatalogToImport = NO;
                NSNotification *note = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_DO_IMPORT_CATALOG object:self];
                [[NSNotificationCenter defaultCenter] postNotification:note];
            }
        }
    }
}

-(void)setupCatalogToDownload:(LayGithubCatalog*)catalog atIndexPath:(NSIndexPath *)indexPath {
    NSString *textTemplate = NSLocalizedString(@"ImportDownloadCatalogState", nil);
    NSString* text = [NSString stringWithFormat:textTemplate, catalog->title];
    UIImage *image = [LayImage imageWithId:LAY_IMAGE_IMPORT];
    self->stateViewHandler = [[LayImportStateViewHandler alloc]initWithSuperView:self.tableView.window icon:image andText:text];
    self->stateViewHandler.delegate = self;
    //self->stateViewHandler.useTimerForSteps = YES;
    self->catalogToDownload = catalog;
    self->indexPathToDelete = indexPath;
    [self->stateViewHandler startWork];
}


//
// LayVcNavigationBarDelegate
//
-(void)cancelPressed {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}


//
// LayImportStateViewHandlerDelegate
//
-(NSString*)startWork:(id<LayImportProgressDelegate>)progressDelegate {
    NSString *errorMessage = nil;
    NSString *titleOfCatalog = self->catalogToDownload->title;
    NSString *publisherOfCatalog = self->catalogToDownload->owner;
    MWLogInfo([LayVcCatalogStoreList class], @"Download catalog with title:%@, publisher:%@ .", titleOfCatalog, publisherOfCatalog);
    const NSUInteger maxSteps = 100;
    [progressDelegate setMaxSteps:maxSteps];
    
    NSString *urlToZipBall = [NSString stringWithFormat:@"%@/zipball/master", self->catalogToDownload->url];
    NSURL *url = [NSURL URLWithString:urlToZipBall];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSString *nameOfInboxDir = @"Inbox";
    NSFileManager* fileMngr = [NSFileManager defaultManager];
    NSArray *dirList = [fileMngr URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentDirUrl = [dirList objectAtIndex:0];
    // TODO: get the name of the Inbox directory programmatically !
    NSURL *inboxDirUrl = [documentDirUrl URLByAppendingPathComponent:nameOfInboxDir];
    NSString *inboxDirPath = [inboxDirUrl path];
    NSString *fileName = [NSString stringWithFormat:@"%@.zip", [url lastPathComponent]];
    NSString *fullPath = [inboxDirPath stringByAppendingPathComponent:fileName];
    
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fullPath append:NO]];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSUInteger step = (totalBytesRead / totalBytesExpectedToRead) * 100;
        [progressDelegate setStep:step];
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"RES: %@", [[[operation response] allHeaderFields] description]);
        NSError *error;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
        if (error) {
            NSLog(@"ERR: %@", [error description]);
        } else {
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            MWLogInfo([LayVcCatalogStoreList class], @"Downloaded file:%@ with size:%l", fileName, fileSize );
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MWLogError([LayVcCatalogStoreList class], @"Can not download file:%@ details:%@", fileName, [error description] );
    }];
    
    [operation start];
    
    return errorMessage;
}

-(void)buttonPressed {
    
}

-(void)closedStateView {
    /*
    if(self->catalogToDelete && self->indexPathToDelete) {
        [self deleteCatalogFromtableAnimated];
    }
     */
}

//
//
//
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

//
//
//
-(void)searchKeemiCatalogsAtGitHub {
    OCTClient *client = [[OCTClient alloc] initWithServer:OCTServer.dotComServer];
    NSDictionary *parameters = @{ @"q": @"KEEMI", @"sort": @"stars" };
    NSURLRequest *request = [client requestWithMethod:@"GET" path:@"/search/repositories" parameters:parameters notMatchingEtag:nil];
    self->urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    if( !self->urlConnection ) {
        MWLogError([LayVcCatalogStoreList class], @"Can not make search request!" );
    }
}

-(void)loadKeemiCatalogListFromGitHub {
    if( self->searchResultMap  ) {
        OCTClient *client = [[OCTClient alloc] initWithServer:OCTServer.dotComServer];
        NSArray *items = self->searchResultMap[@"items"];
        // all repo's found which keyword KEEMI
        //__block NSMutableArray *keemiRepositoriesAll = [NSMutableArray arrayWithCapacity:10];
        for (NSDictionary* keemiRepo in items ) {
            NSString *repoName = keemiRepo[@"name"];
            NSDictionary *ownerMetaData = keemiRepo[@"owner"];
            NSString *owner = ownerMetaData[@"login"];
            NSString *url = keemiRepo[@"html_url"];
            RACSignal *repoRequest = [client fetchRepositoryWithName:repoName owner:owner];
            [repoRequest subscribeNext:^(OCTRepository *repositoryWithKeyword) {
                MWLogDebug([LayVcCatalogStoreList class], @"Found repo with name:%@", repositoryWithKeyword.name );
                //[keemiRepositoriesAll addObject:repository];
                RACSignal *catalogCover = [client fetchRelativePath:@"Cover.jpg" inRepository:repositoryWithKeyword reference:nil];
                [catalogCover subscribeNext:^(OCTFileContent *coverFile) {
                    MWLogDebug([LayVcCatalogStoreList class], @"Found catalog with name:%@", repositoryWithKeyword.name );
                    //OCTFileContent
                    //id content = [cover valueForKey:@"file"];
                    //NSString * n = NSStringFromClass([content class]);
                    NSData *cover = nil;
                    if( [coverFile.encoding isEqualToString:@"base64"] ) {
                        cover = [[NSData alloc] initWithBase64EncodedString:coverFile.content options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    } else {
                        OCTContent *content = (OCTContent *)coverFile;
                        MWLogError([LayVcCatalogStoreList class], @"Can not decode file:%@", content.name );
                    }
                    NSString *title = [self separateCamelCaseString:repositoryWithKeyword.name];
                    if( title ) {
                        title = [title stringByReplacingOccurrencesOfString:@"Keemi " withString:@""];
                    } else {
                        title = repositoryWithKeyword.name;
                    }
                    NSString *descr = repositoryWithKeyword.repoDescription;
                    NSString *owner = repositoryWithKeyword.ownerLogin;
                    LayGithubCatalog* catalogAtGitHub = [LayGithubCatalog catalogWithTitle:title cover:cover description:descr owner:owner url:url andVersion:nil];
                    [self fetchNamesForOwnersForCatalog:catalogAtGitHub];
                    [self->githubCatalogList addObject:catalogAtGitHub];
                    [self performSelectorOnMainThread:@selector(addCatalogToTable) withObject:nil waitUntilDone:NO];
                } error:^(NSError *error) {
                    MWLogError([LayVcCatalogStoreList class], @"catalogCover:%@", [error description] );
                } completed:^{
                    MWLogDebug([LayVcCatalogStoreList class], @"FetchPath completed!");
                }];
            } error:^(NSError *error) {
                MWLogError([LayVcCatalogStoreList class], @"Could not fetch repo:%@", repoName );
            } completed:^{
                MWLogDebug([LayVcCatalogStoreList class], @"FetchRepo completed!", repoName );
            }];
        }
    } else {
        MWLogError([LayVcCatalogStoreList class], @"Searching for KEEMI catalogs failed!");
    }
}

-(void)fetchNamesForOwnersForCatalog:(LayGithubCatalog*)catalog {
    NSString* urlToGetUserInfo = [NSString stringWithFormat:@"%@%@", urlToGetUserInfoTemplate, catalog->owner];
    NSURL *url = [NSURL URLWithString:urlToGetUserInfo];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    //AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://samwize.com/"]];
    /*NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:@"http://samwize.com/api/pigs/"
                                                      parameters:nil];*/
    //AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    //[httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Print the response body in text
        NSError *error = nil;
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        catalog->name = userInfo[@"name"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MWLogError([LayVcCatalogStoreList class], @"Could not get name of owner:%@!", catalog->owner);
    }];
    [operation start];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self->searchResultInJson appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error = nil;
    self->searchResultMap = [NSJSONSerialization JSONObjectWithData:self->searchResultInJson options:0 error:&error];
    [self performSelectorInBackground:@selector(loadKeemiCatalogListFromGitHub) withObject:nil];
}


-(void)addCatalogToTable {
    int lastRow = [self->githubCatalogList count] - 1;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    [[self tableView] insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationBottom];
    [self->activity stopAnimating];
    self->activity.hidden = YES;
}

-(NSString*) separateCamelCaseString:(NSString*)camelCaseString {
    NSMutableString *separated = [NSMutableString string];
    @try {
        for (NSInteger i=0; i < camelCaseString.length; i++){
            NSString *ch = [camelCaseString substringWithRange:NSMakeRange(i, 1)];
            if ( i != 0 && [ch rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location != NSNotFound) {
                [separated appendString:@" "];
            }
            [separated appendString:ch];
        }
    }
    @catch (NSException *exception) {
        MWLogError([LayVcCatalogStoreList class], @"Separating camelCaseString:%@ failed!", camelCaseString);
    }
    
    return separated;
}

@end


//
//
@implementation LayGithubCatalog

+(LayGithubCatalog*) catalogWithTitle:(NSString*)title cover:(NSData*)cover description:(NSString*)descr owner:(NSString*)owner url:(NSString*)url andVersion:(NSString*)version {
    LayGithubCatalog *catalog = [LayGithubCatalog new];
    catalog->title = title;
    catalog->cover = cover;
    catalog->description = descr;
    catalog->owner = owner;
    catalog->version = version;
    catalog->url = url;
    return catalog;
}

@end
