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
#import "LayHintView.h"
#import "LayVcNavigation.h"
#import "LayVcSettings.h"
#import "LayMediaData.h"
#import "LayVcImport.h"
#import "LayGithubCatalog.h"


#import "OctoKit.h"

#import "LayCatalogManager.h"
#import "Catalog+Utilities.h"
#import "MWLogging.h"


//
//
//static const NSInteger NUMBER_OF_SECTIONS = 1;
static NSString *urlToGetUserInfoTemplate = @"https://api.github.com/users/";

@interface LayVcCatalogStoreList () {
    //LayTableSectionView* sectionMyCatalog;
    LayVcNavigationBar* navBarViewController;
    NSMutableArray* githubCatalogList;
    NSURLConnection *urlConnection;
    NSMutableData *searchResultInJson;
    NSDictionary *searchResultMap;
    UIActivityIndicatorView *activity;
    LayGithubCatalog *catalogToDownload;
    NSArray *catalogsInStore;
}

@end


typedef enum : NSUInteger {
    CatalogIsUpTodate,
    CatalogIsNotStored,
    CatalogIsNotUpTodate,
} CatalogStati;


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
    NSString *label = NSLocalizedString(@"ImportCatalogDownloadCatalogFromGithub", nil);
    [self->navBarViewController showTitle:label atPosition:TITLE_CENTER withFont:appTitleFont andColor:appNameColor];
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
    
    catalogsInStore = [[LayMainDataStore store] findAllCatalogs];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

-(void)viewWillAppear:(BOOL)animated {
    if( [self->githubCatalogList count] == 0 ) {
        // The view appears from the import of a catalog
        self->activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self->activity.color = [[LayStyleGuide instanceOf:nil] getColor:ButtonSelectedColor];
        [self.tableView setBackgroundView:self->activity];
        [self->activity startAnimating];
        //[self performSelectorInBackground:@selector(searchKeemiCatalogsAtGitHub) withObject:nil];
        NSError *error = nil;
        NSString *URLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.github.com"] encoding:NSUTF8StringEncoding error:&error];
        if( URLString ) {
            [self searchKeemiCatalogsAtGitHub];
        } else {
            NSString *errorMesg = NSLocalizedString(@"ImportDownloadNoConnection", nil);
            [self showErrorMessage:errorMesg];
            if(error) {
                MWLogError([LayVcCatalogStoreList class], @"No connection! Details:%@", [error description] );
            }
        }
        
    } else {
        catalogsInStore = [[LayMainDataStore store] findAllCatalogs];
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
    column.numberOfQuestionsLabelInBlueColor = YES;
    LayGithubCatalog *catalog = [self->githubCatalogList objectAtIndex:[indexPath row]];
    NSString *label = NSLocalizedString(@"ImportCatalogDownloadCatalog", nil);
    CatalogStati statiOfCatalog = [self statiForCatalog:catalog];
    if( statiOfCatalog == CatalogIsUpTodate ) {
        label = NSLocalizedString(@"ImportCatalogOpenCatalog", nil);
    } else if( statiOfCatalog == CatalogIsNotUpTodate ) {
        label = NSLocalizedString(@"ImportCatalogUpdateCatalog", nil);
    }
    
    LayMediaData *coverMediaData = [LayMediaData byData:catalog->cover type:LAY_MEDIA_IMAGE andFormat:LAY_FORMAT_JPG];
    [column setCoverWithMediaData:coverMediaData title:catalog->title publisher:catalog->name andNumberOfQuestions:label];
 
    return cell;
}

-(void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LayGithubCatalog *catalog = [self->githubCatalogList objectAtIndex:[indexPath row]];
    CatalogStati statiOfCatalog = [self statiForCatalog:catalog];
    if( statiOfCatalog == CatalogIsUpTodate ) {
        Catalog *storedCatalog = [self storedCatalogForGithubCatalog:catalog];
        [LayCatalogManager instance].currentSelectedCatalog = storedCatalog;
        [LayCatalogManager instance].currentCatalogShouldBeOpenedDirectly = YES;
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        LayGithubCatalog *catalog = [self->githubCatalogList objectAtIndex:[indexPath row]];
        LayVcImport *vcImport = [[LayVcImport alloc] initWithGithubCatalogToDownload:catalog];
        UINavigationController* navigationController = (UINavigationController* )self.navigationController;
        [navigationController pushViewController:vcImport animated:YES];
    }
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

}

-(void)handleWantToImportCatalogNotification {

}


//
// LayVcNavigationBarDelegate
//
-(void)cancelPressed {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
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
                    NSString *title = repositoryWithKeyword.repoDescription;
                    NSString *owner = repositoryWithKeyword.ownerLogin;
                    LayGithubCatalog* catalogAtGitHub = [LayGithubCatalog catalogWithTitle:title cover:cover owner:owner url:url andVersion:nil];
                    catalogAtGitHub->repoName = repositoryWithKeyword.name;
                    [self fetchCurrentReleaseOfCatalog:catalogAtGitHub];
                } error:^(NSError *error) {
                    MWLogDebug([LayVcCatalogStoreList class], @"catalogCover:%@", [error description] );
                    static const NSInteger API_RATE_LIMIT_EXCEEDED_EEROR = 674;
                    if ( error.code == API_RATE_LIMIT_EXCEEDED_EEROR ) {
                        [self performSelectorOnMainThread:@selector(showRateLimitExceededFailureMessage) withObject:nil waitUntilDone:NO];
                    }
                } completed:^{
                    MWLogDebug([LayVcCatalogStoreList class], @"FetchPath completed!");
                }];
            } error:^(NSError *error) {
                MWLogError([LayVcCatalogStoreList class], @"Could not fetch repo:%@. Details:%@", repoName, [error description] );
                static const NSInteger API_RATE_LIMIT_EXCEEDED_EEROR = 674;
                if ( error.code == API_RATE_LIMIT_EXCEEDED_EEROR ) {
                    [self performSelectorOnMainThread:@selector(showRateLimitExceededFailureMessage) withObject:nil waitUntilDone:NO];
                }
            } completed:^{
                MWLogDebug([LayVcCatalogStoreList class], @"FetchRepo completed!", repoName );
            }];
        }
    } else {
        MWLogError([LayVcCatalogStoreList class], @"Searching for KEEMI catalogs failed!");
    }
}

-(void)showErrorMessage:(NSString*)error {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGFloat width = self.view.frame.size.width - 2 * hSpace;
    const CGRect labelRect = CGRectMake(0.0f, 0.0f, width, 0.0f);
    UILabel *label = [[UILabel alloc]initWithFrame:labelRect];
    label.textColor = [UIColor lightGrayColor];
    label.text = error;
    // adjust size
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [styleGuide getFont:NormalPreferredFont];
    label.numberOfLines = 10;
    [label sizeToFit];
    label.center = self.view.center;
    [self.view addSubview:label];
    
    [self->activity stopAnimating];
    self->activity.hidden = YES;
}


-(void)fetchCurrentReleaseOfCatalog:(LayGithubCatalog*)catalog {
    NSString* urlToGetUserInfo = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/releases", catalog->owner, catalog->repoName];
    NSURL *url = [NSURL URLWithString:urlToGetUserInfo];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Print the response body in text
        NSError *error = nil;
        NSArray *releaseInfoList = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        if( [releaseInfoList count] > 0 ) {
            NSDictionary *currentRelease = [releaseInfoList objectAtIndex:0];
            catalog->version = currentRelease[@"tag_name"];;
            catalog->zipball_url = currentRelease[@"zipball_url"];
            [self fetchNamesForOwnersForCatalog:catalog];
        } else {
            MWLogWarning([LayVcCatalogStoreList class], @"Ignore catalog:%@ was the catalog was not released yet!", catalog->title );
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        MWLogError([LayVcCatalogStoreList class], @"Could not get release of catalog:%@!", catalog->title);
    }];
    [operation start];
}

-(void)fetchNamesForOwnersForCatalog:(LayGithubCatalog*)catalog {
    NSString* urlToGetUserInfo = [NSString stringWithFormat:@"%@%@", urlToGetUserInfoTemplate, catalog->owner];
    NSURL *url = [NSURL URLWithString:urlToGetUserInfo];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Print the response body in text
        NSError *error = nil;
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        catalog->name = userInfo[@"name"];
        if( [catalog->name length] > 1 ) {
            [self->githubCatalogList addObject:catalog];
            [self performSelectorOnMainThread:@selector(addCatalogToTable) withObject:nil waitUntilDone:NO];
        } else {
            MWLogError([LayVcCatalogStoreList class], @"Ignore catalog:%@ as the owner has no name set!", catalog->title );
        }
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    MWLogError([LayVcCatalogStoreList class], @"Could not search for KEEMI catalogs! Details:%@!", [error description]);
    static const NSInteger API_RATE_LIMIT_EXCEEDED_EEROR = 674;
    if ( error.code == API_RATE_LIMIT_EXCEEDED_EEROR ) {
        NSString *errorMesg = NSLocalizedString(@"ImportDownloadRateLimitReached", nil);
        [self showErrorMessage:errorMesg];
    }
}


-(void)addCatalogToTable {
    int lastRow = [self->githubCatalogList count] - 1;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
    [[self tableView] insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationBottom];
    [self->activity stopAnimating];
    self->activity.hidden = YES;
}

-(CatalogStati) statiForCatalog:(LayGithubCatalog*)githubCatalog {
    CatalogStati statiOfCatalog = CatalogIsNotStored;
    for (Catalog *storedCatalog in self->catalogsInStore) {
        NSString *publisherOfStoredCatalog =  [storedCatalog publisher];
        if( [storedCatalog.title isEqualToString:githubCatalog->title] &&
           [publisherOfStoredCatalog isEqualToString:githubCatalog->name] ) {
            float storedVersion = [storedCatalog.version floatValue];
            float githubVersion = [githubCatalog->version floatValue];
            if( storedVersion < githubVersion ) {
                statiOfCatalog = CatalogIsNotUpTodate;
            } else {
                statiOfCatalog = CatalogIsUpTodate;
            }
        }
    }
    return statiOfCatalog;
}

-(Catalog*)storedCatalogForGithubCatalog:(LayGithubCatalog*)githubCatalog {
    Catalog *catalog = nil;
    for (Catalog *storedCatalog in self->catalogsInStore) {
        NSString *publisherOfStoredCatalog =  [storedCatalog publisher];
        if( [storedCatalog.title isEqualToString:githubCatalog->title] &&
           [publisherOfStoredCatalog isEqualToString:githubCatalog->name] ) {
            catalog = storedCatalog;
            break;
        }
    }
    return catalog;
}

@end

