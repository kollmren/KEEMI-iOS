//
//  LayVcCatalogDetail.m
//  Lay
//
//  Created by Rene Kollmorgen on 12.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayVcNotes.h"
#import "LayVcNavigationBar.h"
#import "LayStyleGuide.h"
#import "LayCatalogDetails.h"
#import "LayTableSectionView.h"
#import "LayButton.h"
#import "LayMediaView.h"
#import "LayVBoxLayout.h"
#import "LayFrame.h"
#import "LayImage.h"
#import "LAyMediaData.h"
#import "LayInfoDialog.h"
#import "LayUserDataStore.h"
#import "LayCatalogManager.h"
#import "LayAppNotifications.h"

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"
#import "Explanation+Utilities.h"

#import "UGCCatalog+Utilities.h"
#import "UGCExplanation+Utilities.h"
#import "UGCQuestion+Utilities.h"
#import "UGCNote.h"
#import "UGCMedia.h"

#import "MWLogging.h"

static const NSUInteger TAG_TEXT_VIEW = 1001;
static const NSUInteger TAG_STATUS_LABEL = 1002;
static const NSUInteger TAG_SAVE_BUTTON = 1003;
static const NSInteger TAG_IMAGE_NOTE_VIEW = 1004;
static const CGFloat g_HEIGHT_OF_THUMBNAIL_VIEW = 150.0f;

@interface LayVcNotes () {
    LayVcNavigationBar* navBarViewController;
    UIView *addTextNoteDialog;
    Catalog *catalogParam;
    Question *questionParam;
    Explanation *explanationParam;
    NSMutableArray *noteList;
    UIView *buttonContainer;
    LayButton *addTextNote;
    LayButton *addImageNote;
    UIPopoverController *imagePickerPopover;
}

@end

//
// LayVcNotes
//

static Class g_classObj = nil;

@implementation LayVcNotes


+(void)initialize { 
    g_classObj = [LayVcNotes class];
}

-(id)initWithCatalog:(Catalog*)catalog_ {
    self = [self initWithNibName:nil bundle:nil];
    if(self) {
        self->catalogParam = catalog_;
        [self initNoteList];
    }
    return self;
}

-(id)initWithExplanation:(Explanation*)explanation {
    self = [self initWithNibName:nil bundle:nil];
    if(self) {
        self->explanationParam = explanation;
        [self setNeedsStatusBarAppearanceUpdate];
        [self initNoteList];
    }
    return self;
}

-(id)initWithQuestion:(Question*)question {
    self = [self initWithNibName:nil bundle:nil];
    if(self) {
        self->questionParam = question;
        [self setNeedsStatusBarAppearanceUpdate];
        [self initNoteList];
    }
    return self;
}

-(void)initNoteList {
    if(self->questionParam) {
        self->catalogParam = self->questionParam.catalogRef;
        NSArray *questionNoteList = [self->questionParam noteList];
        self->noteList = [NSMutableArray arrayWithCapacity:[questionNoteList count]];
        [self->noteList addObjectsFromArray:questionNoteList];
    } else if(self->explanationParam) {
        self->catalogParam = self->explanationParam.catalogRef;
        NSArray *explanationNoteList = [self->explanationParam noteList];
        self->noteList = [NSMutableArray arrayWithCapacity:[explanationNoteList count]];
        [self->noteList addObjectsFromArray:explanationNoteList];
    } else {
        NSArray *catalogNoteList = [self->catalogParam  noteList];
        self->noteList = [NSMutableArray arrayWithCapacity:[catalogNoteList count]];
        [self->noteList addObjectsFromArray:catalogNoteList];
    }
}


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        [self registerEvents];
    }
    return self;
}

-(BOOL)prefersStatusBarHidden {
    BOOL prefersStatusBarHidden = NO;
    if(self->questionParam || self->explanationParam) {
        prefersStatusBarHidden = YES;
    }
    return prefersStatusBarHidden;
}

-(void)loadView {
    const CGRect initialTableFrame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    UITableView *tableView = [[UITableView alloc]initWithFrame:initialTableFrame style:UITableViewStylePlain];
    tableView.separatorColor = [UIColor clearColor];
    tableView.dataSource = self;
    tableView.delegate = self;
    self.view = tableView;
}

-(void)dealloc {
    MWLogDebug([LayVcNotes class], @"dealloc");
    MWLogDebug([LayVcNotes class], @"Save added or updated notes.");
    [self saveUpdatedNotes];
    //
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    self->navBarViewController.delegate = nil;
}

-(void)registerEvents {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handlePreferredFontSizeChanges) name:(NSString*)LAY_NOTIFICATION_PREFERRED_FONT_SIZE_CHANGED object:nil];
    [nc addObserver:self selector:@selector(handleWantToImportCatalogNotification) name:(NSString*)LAY_NOTIFICATION_WANT_TO_IMPORT_CATALOG object:nil];
    [nc addObserver:self
           selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
	[nc addObserver:self
           selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self->navBarViewController = [[LayVcNavigationBar alloc]initWithViewController:self];
    self->navBarViewController.cancelButtonInNavigationBar = YES;
    [self->navBarViewController showButtonsInNavigationBar];
    NSString *title = NSLocalizedString(@"CatalogNotes", nil);
    [self->navBarViewController showTitle:title  atPosition:TITLE_CENTER];
     self->navBarViewController.delegate = self;
    //
    [self setupTableHeader];
    [self setupAddButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    if(catalogManager.pendingCatalogToImport) {
        UINavigationController *navController = self.navigationController;
        [navController popToRootViewControllerAnimated:NO];
    }
    
    [self initNoteList];
    
    NSIndexPath *pathToSelectedRow = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:pathToSelectedRow animated:NO];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupTableHeader {
    if(self.tableView.tableHeaderView) {
        [self.tableView.tableHeaderView removeFromSuperview];
    }
    if(self->catalogParam && (!self->questionParam && !self->explanationParam)) {
        const CGFloat yPosDetailView = 10.0f;
        LayCatalogDetails *catalogDetailView = [[LayCatalogDetails alloc]initWithCatalog:self->catalogParam andPositionY:yPosDetailView];
        catalogDetailView.showDetailTable = NO;
        const CGFloat vSpace = 15.0f;
        const CGFloat newHeaderHeight = catalogDetailView.frame.size.height + vSpace;
        [LayFrame setHeightWith:newHeaderHeight toView:catalogDetailView animated:NO];
        self.tableView.tableHeaderView = catalogDetailView;
    } else {
        const CGRect screenFrame = [[UIScreen mainScreen] bounds];
        const CGFloat width = screenFrame.size.width;
        const CGFloat vSpace = 15.0f;
        const CGRect headerRect = CGRectMake(0.0f, 0.0f, width, 0.0f);
        UIView *header = [[UIView alloc]initWithFrame:headerRect];
        header.backgroundColor = [UIColor clearColor];
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
        const CGRect titleRect = CGRectMake(hSpace, vSpace, width-2*hSpace, 0.0f);
        UILabel *title = [[UILabel alloc]initWithFrame:titleRect];
        title.numberOfLines = [styleGuide numberOfLines];
        title.textColor = [styleGuide getColor:TextColor];
        title.backgroundColor = [UIColor clearColor];
        title.textAlignment = NSTextAlignmentLeft;
        NSString *text = nil;
        if(self->questionParam) {
            title.font = [styleGuide getFont:QuestionFont];
            title.textColor = [UIColor darkGrayColor];
            text = self->questionParam.question;
        } else if(explanationParam) {
            title.font = [styleGuide getFont:TitlePreferredFont];
            text = self->explanationParam.title;
        } else {
            MWLogError(g_classObj, @"Invalid object initialization!");
        }
        title.text = text;
        [title sizeToFit];
        CGFloat newHeaderHeight = vSpace + title.frame.size.height + 2*vSpace;
        if(self->questionParam) {
            UIView *questionTitleContainer = [self questionView:self->questionParam withWidth:width];
            if(questionTitleContainer) {
                [LayFrame setYPos:vSpace toView:questionTitleContainer];
                const CGFloat yPosTitle = vSpace + questionTitleContainer.frame.size.height + vSpace;
                [LayFrame setYPos:yPosTitle toView:title];
                [header addSubview:questionTitleContainer];
                newHeaderHeight += questionTitleContainer.frame.size.height + vSpace;
            }
            
        }
        
        [LayFrame setHeightWith:newHeaderHeight toView:header animated:NO];
        [header addSubview:title];
        self.tableView.tableHeaderView = header;
    }
}

static const NSUInteger TAG_QUESTION_TITLE = 105;
-(UIView*)questionView:(Question*)question withWidth:(CGFloat)width {
    UIView *titleContainer = nil;
    if(question.title) {
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        UIFont *smallFont = [styleGuide getFont:TitlePreferredFont];
        UIColor *textColor = [styleGuide getColor:TextColor];
        const CGFloat indent = 10.0f;
        CGFloat horizontalBorderOfView = [styleGuide getHorizontalScreenSpace];
        const CGFloat titleContainerWidth = width -  2*horizontalBorderOfView;
        const CGRect titleContainerFrame = CGRectMake(horizontalBorderOfView, 0.0f, titleContainerWidth, 0.0f);
        titleContainer = [[UIView alloc]initWithFrame:titleContainerFrame];
        titleContainer.tag = TAG_QUESTION_TITLE;
        //
        const CGFloat titleWith = titleContainerWidth - 2 * horizontalBorderOfView - 2 * indent;
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(indent, indent, titleWith, 0.0f)];
        title.textColor = textColor;
        title.backgroundColor = [UIColor clearColor];
        title.font = smallFont;
        title.text = [NSString stringWithFormat:@"%@", question.title];
        title.numberOfLines = [styleGuide numberOfLines];
        [title sizeToFit];
        const CGFloat heightTitleContainer = title.frame.size.height + 2 * indent;
        [LayFrame setHeightWith:heightTitleContainer toView:titleContainer animated:NO];
        [titleContainer addSubview:title];
        [styleGuide makeRoundedBorder:titleContainer withBackgroundColor:GrayTransparentBackground andBorderColor:ClearColor];
    }
    return titleContainer;
}

-(void)setupAddButtons {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    const CGFloat buttonWidth = screenWidth / 2.0f;
    NSString *buttonTitle = NSLocalizedString(@"NotesAddTextNote", nil);
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    UIImage *plusIcon = [LayImage imageWithId:LAY_IMAGE_ADD];
    LayMediaData *mediaData = [LayMediaData byUIImage:plusIcon];
    const CGFloat buttonHeight = [styleGuide getDefaultButtonHeight];
    const CGRect initialButtonRect = CGRectMake(0.0f, 0.0f, buttonWidth, buttonHeight);
    self->addTextNote = [[LayButton alloc]initWithFrame:initialButtonRect label:buttonTitle mediaData:mediaData font:[styleGuide getFont:NormalPreferredFont] andColor:[styleGuide getColor:WhiteTransparentBackground]];
    self->addTextNote.topBottomLayer = YES;
    [self->addTextNote fitToHeight];
    [self->addTextNote hiddeBorders:YES];
    [self->addTextNote addTarget:self action:@selector(addTextNote:) forControlEvents:UIControlEventTouchUpInside];
    
    buttonTitle = NSLocalizedString(@"NotesAddImageNote", nil);
    self->addImageNote = [[LayButton alloc]initWithFrame:initialButtonRect label:buttonTitle mediaData:mediaData font:[styleGuide getFont:NormalPreferredFont] andColor:[styleGuide getColor:WhiteTransparentBackground]];
    
    self->addImageNote.topBottomLayer = YES;
    [self->addImageNote fitToHeight];
    [self->addImageNote hiddeBorders:YES];
    [self->addImageNote addTarget:self action:@selector(addImageNote:) forControlEvents:UIControlEventTouchUpInside];
    
    const CGFloat actualButtonHeight = self->addTextNote.frame.size.height;
    const CGRect buttonContainerFrame = CGRectMake(0.0f, 0.0, screenWidth, actualButtonHeight);
    self->buttonContainer = [[UIView alloc]initWithFrame:buttonContainerFrame];
    self->buttonContainer.backgroundColor = [UIColor clearColor];
    [self->buttonContainer addSubview:self->addTextNote];
    [LayFrame setXPos:buttonWidth toView:self->addImageNote];
    [self->buttonContainer addSubview:self->addImageNote];
    [self setBackgroundColorForButtons];
}

-(void)setBackgroundColorForButtons {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    self->addTextNote.backgroundColor = [styleGuide getColor:WhiteTransparentBackground];
    self->addImageNote.backgroundColor = [styleGuide getColor:WhiteTransparentBackground];
}

-(void)addNewTextNote:(NSString*)text {
    UGCNote *note = [self saveEditedNote:text orImage:nil context:self->catalogParam];
    if(note) {
        NSInteger lastRowInSection = 0;
        lastRowInSection = [self->noteList count];
        [self->noteList addObject:note];
        [self.tableView reloadData];
        // show note
        NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRowInSection inSection:0];
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

-(void)addNewImageNote:(UIImage*)image {
    UGCNote *note = [self saveEditedNote:nil orImage:image context:self->catalogParam];
    if(note) {
        NSInteger lastRowInSection = 0;
        lastRowInSection = [self->noteList count];
        [self->noteList addObject:note];
        [self.tableView reloadData];
        // show note
        NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRowInSection inSection:0];
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

- (void)takePicture:(id)sender
{
    if([imagePickerPopover isPopoverVisible]) {
        [imagePickerPopover dismissPopoverAnimated:YES];
        imagePickerPopover = nil;
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController
         isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    [imagePicker setDelegate:self];
    
    // Place image picker on the screen
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // Create a new popover controller that will display the imagePicker
        imagePickerPopover = [[UIPopoverController alloc]
                              initWithContentViewController:imagePicker];
        
        [imagePickerPopover setDelegate:self];
        
        // Display the popover controller, sender
        // is the camera bar button item
        [imagePickerPopover presentPopoverFromBarButtonItem:sender
                                   permittedArrowDirections:UIPopoverArrowDirectionAny
                                                   animated:YES];
    } else {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Get picked image from info dictionary
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self addNewImageNote:image];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        // If on the phone, the image picker is presented modally. Dismiss it.
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        // If on the ipad, the image picker is in the popover. Dismiss the popover.
        [imagePickerPopover dismissPopoverAnimated:YES];
        imagePickerPopover = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self->imagePickerPopover = nil;
}

//
// UITableViewDelegate
//
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    LayNoteCell *noteCell = (LayNoteCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(noteCell.note && noteCell.note.mediaRef) {
        LayMediaData *mediaData = [LayMediaData byData:noteCell.note.mediaRef.data type:LAY_MEDIA_IMAGE andFormat:LAY_FORMAT_JPG];
        const CGPoint posThumbnail = [noteCell imageNotePosition];
        const CGRect mediaViewRect = CGRectMake(0.0f, posThumbnail.y, self.tableView.frame.size.width, g_HEIGHT_OF_THUMBNAIL_VIEW);
        LayMediaView *mediaView = [[LayMediaView alloc]initWithFrame:mediaViewRect andMediaData:mediaData];
        mediaView.ignoreEvents = YES;
        mediaView.fitToContent = YES;
        mediaView.removeAfterClosedFullscreen = YES;
        mediaView.zoomable = YES;
        [mediaView layoutMediaView];
        const CGFloat posX = (noteCell.frame.size.width - mediaView.frame.size.width) / 2.0f;
        [LayFrame setXPos:posX toView:mediaView];
        [noteCell addSubview:mediaView];
        [mediaView showContentInFullScreen];
    } else {
        [self showTextNote:noteCell.note];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return self->buttonContainer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return  self->buttonContainer.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UGCNote* note = [self->noteList objectAtIndex:[indexPath row]];
    CGFloat cellHeight = [LayNoteCell heightForNote:note];
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = 0.0f;
    return headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    return sectionView;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


// The two following methods must be implemented to get the menu right. So far the are never called!
-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    /*
     BOOL canPerformAction = NO;
     if(action == @selector(openRelatedQuestions:)){
     Resource* resource = [self resourceForIndexPath:indexPath];
     if([resource.questionRef count] > 0 ) {
     canPerformAction = YES;
     }
     } else if(action == @selector(openRelatedExplanations:)){
     Resource* resource = [self resourceForIndexPath:indexPath];
     if([resource.explanationRef count] > 0 ) {
     canPerformAction = YES;
     }
     }
     return canPerformAction;
     */
    return YES;
}


- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    /*
     if(action == @selector(openRelatedQuestions:)){
     
     } else if(action == @selector(openRelatedExplanations:)){
     
     };
     */
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
 return [sectionInfo name];
 }*/


//
// UITableViewDataSource
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRowsInSection = [self->noteList count];
    return numberOfRowsInSection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LayNoteCell *noteCell = (LayNoteCell*)[tableView dequeueReusableCellWithIdentifier:(NSString*)noteCellIdentifier];
    if(nil==noteCell) {
        noteCell = [[LayNoteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:(NSString*)noteCellIdentifier];
    }
    noteCell.delegate = self;
    UGCNote* note = [self->noteList objectAtIndex:[indexPath row]];
    noteCell.note = note;
    
    if(self->explanationParam || self->questionParam) {
        noteCell.canOpenLinkedQuestionsOrExplanations = NO;
    } else {
        noteCell.canOpenLinkedQuestionsOrExplanations = YES;
    }

    return noteCell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        [self->noteList removeObjectAtIndex:[indexPath row]];
        LayNoteCell *noteCell = (LayNoteCell *)[tableView cellForRowAtIndexPath:indexPath];
        NSManagedObjectContext *context = [noteCell.note managedObjectContext];
        [context deleteObject:noteCell.note];
        // Animated deletion crashes
        //NSArray *rowsToDelete = [NSArray arrayWithObjects:indexPath, nil];
        //[tableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationTop];
        
        [tableView reloadData];
    }
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
-(void)addTextNote:(UIButton*)button {
    [self setupTextNoteDialog:nil];
    [self openTextNoteDialog:self->addTextNoteDialog];
}

-(void)addImageNote:(UIButton*)button {
    [self takePicture:button];
}

//
// add resource dialog
//

-(void)setupTextNoteDialog:(UGCNote*)note {
    UIWindow *window = self.view.window;
    if(window) {
        const CGFloat width = window.frame.size.width;
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        UIView *backgound = [[UIView alloc] initWithFrame:window.frame];
        backgound.backgroundColor = [[LayStyleGuide instanceOf:nil] getColor:InfoBackgroundColor];
        [window addSubview:backgound];
        self->addTextNoteDialog = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, width, 0.0f)];
        self->addTextNoteDialog.backgroundColor = [styleGuide getColor:BackgroundColor];
        self->addTextNoteDialog.clipsToBounds = TRUE;
        // title
        const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
        const CGRect titleRect = CGRectMake(hSpace, 0.0f, width-2*hSpace, 0.0f);
        UILabel *title = [[UILabel alloc]initWithFrame:titleRect];
        title.font = [styleGuide getFont:NormalPreferredFont];
        title.numberOfLines = [styleGuide numberOfLines];
        title.textColor = [styleGuide getColor:TextColor];
        title.backgroundColor = [UIColor clearColor];
        [self->addTextNoteDialog addSubview:title];
        // Textfields
        UIFont *textFieldFont = [styleGuide getFont:NormalPreferredFont];
        const CGFloat heightTextFields = textFieldFont.lineHeight * 6.0f;
        const CGRect textFieldRect = CGRectMake(hSpace, 0.0f, width-2*hSpace, heightTextFields);
        UITextView *textView = [[UITextView alloc]initWithFrame:textFieldRect];
        textView.tag = TAG_TEXT_VIEW;
        textView.delegate = self;
        textView.layer.borderWidth = [styleGuide getBorderWidth:NormalBorder];
        textView.layer.borderColor = [styleGuide getColor:ButtonBorderColor].CGColor;
        textView.font = textFieldFont;
        if(note) {
            title.text =  NSLocalizedString(@"NotesEditTextNoteTitle", nil);
            textView.text = note.text;
        } else {
            title.text =  NSLocalizedString(@"NotesAddTextNoteTitle", nil);
        }
        [title sizeToFit];
        [self->addTextNoteDialog addSubview:textView];
        // Buttons
        const CGFloat buttonHeight = [styleGuide getDefaultButtonHeight];
        const CGRect buttonContainerRect = CGRectMake(hSpace, 0.0f, width, buttonHeight);
        UIView *dialogButtonContainer = [[UIView alloc]initWithFrame:buttonContainerRect];
        UIFont *font = [styleGuide getFont:NormalPreferredFont];
        NSString *buttonLabel = NSLocalizedString(@"Save", nil);
        LayButton *buttonSave = [[LayButton alloc]initWithFrame:buttonContainerRect label:buttonLabel font:font andColor:[styleGuide getColor:WhiteTransparentBackground]];
        buttonSave.tag = TAG_SAVE_BUTTON;
        buttonSave.enabled = NO;
        buttonSave.resource = note;
        [buttonSave addTarget:self action:@selector(saveEditedTextNote:) forControlEvents:UIControlEventTouchUpInside];
        [buttonSave fitToContent];
        buttonLabel = NSLocalizedString(@"Cancel", nil);
        LayButton *buttonCancel = [[LayButton alloc]initWithFrame:buttonContainerRect label:buttonLabel font:font andColor:[styleGuide getColor:WhiteTransparentBackground]];
        [buttonCancel addTarget:self action:@selector(cancelAddingTextNote) forControlEvents:UIControlEventTouchUpInside];
        [buttonCancel fitToContent];
        [dialogButtonContainer addSubview:buttonSave];
        [dialogButtonContainer addSubview:buttonCancel];
        [self layoutResourceDialogButtonContainer:dialogButtonContainer];
        [self->addTextNoteDialog addSubview:dialogButtonContainer];
        //
        [backgound addSubview:self->addTextNoteDialog];
    }
}

-(void)openTextNoteDialog:(UIView*)dialog {
    const CGPoint dialogCenter = CGPointMake(0.0f, self.view.window.frame.size.height/2.0f);
    [LayFrame setPos:dialogCenter toView:dialog];
    const CGFloat dialogHeight = [self layoutAddTextNoteDialog:dialog];
    CALayer *dialogLayer = dialog.layer;
    [UIView animateWithDuration:0.3 animations:^{
        dialogLayer.bounds = CGRectMake(0.0f, 0.0f, dialog.frame.size.width, dialogHeight);
    }];
}

-(CGFloat)layoutAddTextNoteDialog:(UIView*)dialog {
    const CGFloat vSpace = 10.0f;
    CGFloat currentYPos = 15.0f;
    for (UIView* subView in [dialog subviews]) {
        [LayFrame setYPos:currentYPos toView:subView];
        currentYPos += subView.frame.size.height + vSpace;
    }
    return currentYPos;
}

-(void)layoutResourceDialogButtonContainer:(UIView*)dialogButtonContainer {
    const CGFloat hSpace = 20.0f;
    CGFloat currentXPos = 0.0f;
    for (UIView* subView in [dialogButtonContainer subviews]) {
        [LayFrame setXPos:currentXPos toView:subView];
        currentXPos += subView.frame.size.width + hSpace;
    }
}

-(void)closeaddTextNoteDialog {
    [self.tableView reloadData];
    if(self->addTextNoteDialog) {
        [self->addTextNoteDialog.superview removeFromSuperview];
        self->addTextNoteDialog = nil;
    }
}

-(void)showTextNote:(UGCNote*)note {
    NSString *dateAsString = [NSDateFormatter localizedStringFromDate:note.created dateStyle: NSDateFormatterShortStyle timeStyle: NSDateFormatterShortStyle];
    NSString *titleDateTemplate = NSLocalizedString(@"NotesTitleTextNode", nil);
    NSString *title = [NSString stringWithFormat:titleDateTemplate, dateAsString];
    LayInfoDialog *infoDlg = [[LayInfoDialog alloc]initWithWindow:self.tableView.window];
    NSArray *textList = [NSArray arrayWithObject:note.text];
    [infoDlg showInfo:textList withTitle:title caller:self selector:@selector(deselectNote)];
}

-(void)closeImageNote {
    UIWindow *window = self.tableView.window;
    UIView *noteImageView = [window viewWithTag:TAG_IMAGE_NOTE_VIEW];
    [noteImageView removeFromSuperview];
    [self deselectNote];
}

-(void)deselectNote {
    NSIndexPath *pathToSelectedRow = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:pathToSelectedRow animated:NO];
}

//
// keyboard events
//
- (void)keyboardWillShow:(NSNotification *)notification
{
	const CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat overlapVSpace = self->addTextNoteDialog.frame.origin.y + self->addTextNoteDialog.frame.size.height - keyboardFrame.origin.y;
    if(overlapVSpace > 0.0f) {
        CALayer *dialogLayer = self->addTextNoteDialog.layer;
        const CGFloat newYPosDialog = dialogLayer.position.y - overlapVSpace;
        [UIView animateWithDuration:0.3 animations:^{
            dialogLayer.position = CGPointMake(dialogLayer.position.x, newYPosDialog);
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
}

-(void)handlePreferredFontSizeChanges {
    [self setupTableHeader];
    [self setupAddButtons];
    [self.tableView reloadData];
}

-(void)handleWantToImportCatalogNotification {
    if(self.navigationController.topViewController == self) {
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    }
}

//
// LayNoteCellDelegate
//
-(void)editNote:(UGCNote*)note {
    [self setupTextNoteDialog:note];
    [self openTextNoteDialog:self->addTextNoteDialog];
}

//
// UITextVieDelegate methods
//
- (void)textViewDidChange:(UITextView *)textView {
    LayButton *saveButton = (LayButton*)[self->addTextNoteDialog viewWithTag:TAG_SAVE_BUTTON];
    if([textView.text length] > 0) {
        saveButton.enabled = YES;
        UILabel* statusLabel = (UILabel*)[self->addTextNoteDialog viewWithTag:TAG_STATUS_LABEL];
        statusLabel.hidden = YES;
    } else {
        saveButton.enabled = NO;
    }
}

/*- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    CALayer *dialogLayer = self->addTextNoteDialog.layer;
    const CGFloat newYPosDialog = self->addTextNoteDialog.superview.layer.position.y;
    [UIView animateWithDuration:0.3 animations:^{
        dialogLayer.position = CGPointMake(dialogLayer.position.x, newYPosDialog);
    }];
    
    [textField resignFirstResponder];
	return YES;
}*/


//
-(void)cancelAddingTextNote {
    [self closeaddTextNoteDialog];
}

-(void)saveEditedTextNote:(UIButton*)sender {
    if(self->addTextNoteDialog) {
        UITextView *textView = (UITextView*)[self->addTextNoteDialog viewWithTag:TAG_TEXT_VIEW];
        NSString *text = textView.text;
        LayButton *button = (LayButton*)sender;
        UGCNote *note = (UGCNote*)button.resource;
        if(note) {
            note.text = text;
        } else {
            [self addNewTextNote:text];
        }
        [self closeaddTextNoteDialog];
    }
}

-(UGCNote*)saveEditedNote:(NSString*)text orImage:(UIImage*)image context:(NSManagedObject*)managedObject {
    UGCNote *uNote = nil;
    if([managedObject isKindOfClass:[Catalog class]]) {
        Catalog *catalog = (Catalog*)managedObject;
        LayUserDataStore *uStore = [LayUserDataStore store];
        UGCCatalog *uCatalog = [uStore findCatalogByTitle:catalog.title andPublisher:[catalog publisher]];
        if(!uCatalog) {
            uCatalog = [uStore insertObject:UGC_OBJECT_CATALOG];
            uCatalog.title = catalog.title;
            uCatalog.nameOfPublisher = [catalog publisher];
        }
        uNote = [uStore insertObject:UGC_OBJECT_NOTE];
        uNote.text = text;
        if(image) {
            MWLogDebug([LayVcNotes class], @"Add note with image!");
            UGCMedia *uMedia = [uStore insertObject:UGC_OBJECT_MEDIA];
            uMedia.data = UIImageJPEGRepresentation(image,1.0f);
            uMedia.thumbnail = [self thumbnailDataFromImage:image];
            [uNote setMediaRef:uMedia];
        }
        uNote.catalogRef = uCatalog;
        if(self->explanationParam) {
            UGCExplanation *uExplanation = [uCatalog explanationByName:self->explanationParam.name];
            if(!uExplanation) {
                uExplanation = [uStore insertObject:UGC_OBJECT_EXPLANATION];
                uExplanation.name = self->explanationParam.name;
                uExplanation.title = self->explanationParam.title;
            }
            uExplanation.catalogRef = uCatalog;
            [uExplanation addNoteRefObject:uNote];
        } else if(self->questionParam) {
            UGCQuestion *uQuestion = [uCatalog questionByName:self->questionParam.name];
            if(!uQuestion) {
                uQuestion = [uStore insertObject:UGC_OBJECT_QUESTION];
                uQuestion.name = self->questionParam.name;
                uQuestion.question = self->questionParam.question;
            }
            uQuestion.catalogRef = uCatalog;
            [uQuestion addNoteRefObject:uNote];
        }
    } else {
        MWLogError([LayVcNotes class], @"A catalog context is required!");
    }
    return uNote;
}

- (NSData*)thumbnailDataFromImage:(UIImage *)image
{
    CGSize origImageSize = [image size];
    origImageSize.width = origImageSize.width  / 2.0f;
    origImageSize.height = origImageSize.height  / 2.0f;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    CGFloat textAndImageViewWidth = screenWidth - 2*[styleGuide getHorizontalScreenSpace];
    // The rectangle of the thumbnail
    CGRect newRect = CGRectMake(0, 0, textAndImageViewWidth, g_HEIGHT_OF_THUMBNAIL_VIEW);
    
    // Figure out a scaling ratio to make sure we maintain the same aspect ratio
    float ratio = MIN(newRect.size.width / origImageSize.width,
                      newRect.size.height / origImageSize.height);
    
    MWLogDebug([LayVcNotes class], @"Create thumbnail from image:(w:%f, h:%f) to:(w:%f, h:%f, r:%f)", origImageSize.width, origImageSize.height, textAndImageViewWidth, g_HEIGHT_OF_THUMBNAIL_VIEW, ratio);
    
    // Create a transparent bitmap context with a scaling factor
    // equal to that of the screen
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect
                                                    cornerRadius:0.0];
    [path addClip];
    
    // Center the image in the thumbnail rectangle
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    // Draw the image on it
    [image drawInRect:projectRect];
    
    // Get the image from the image context, keep it as our thumbnail
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Get the PNG representation of the image and set it as our archivable data
    NSData *data = UIImagePNGRepresentation(smallImage);
    
    // Cleanup image context resources, we're done
    UIGraphicsEndImageContext();
    
    return data;
}

-(void)saveUpdatedNotes {
    LayUserDataStore *uStore = [LayUserDataStore store];
    if(![uStore saveChanges]) {
        MWLogError([LayVcNotes class], @"Could not save notes!");
    } else {
        MWLogDebug([LayVcNotes class], @"Saved notes successfully!");
    }
}

@end



