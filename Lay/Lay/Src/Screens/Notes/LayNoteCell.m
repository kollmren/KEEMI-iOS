//
//  LayCatalogAbstractListCell.m
//  Lay
//
//  Created by Rene Kollmorgen on 23.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayNoteCell.h"
#import "LayVBoxLayout.h"
#import "LayVBoxView.h"
#import "LayMediaView.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"
#import "LayMiniIconBar.h"
#import "LayCatalogManager.h"
#import "LayVcQuestion.h"

#import "LayVcExplanation.h"
#import "UGCMedia.h"
#import "UGCNote+Utilities.h"

#import "MWLogging.h"

static const CGFloat g_VERTICAL_SPACE = 7.0f;
static const CGFloat g_HORIZONTAL_BORDER = 2.0f;
static CGFloat g_HEIGHT_LINK_LABEL = 15.0f;
static const CGFloat g_WIDTH_NUMBER_LABEL = 40.0f;
static const NSUInteger g_HEIGHT_OF_THUMBNAIL_VIEW = 150.0f;
static const CGFloat linkIndent = 5.0f;
static const NSInteger MAX_NUMBER_LINES_TEXT = 6;

static CGFloat g_cellWidth;
static CGFloat g_TextAndImageViewWidth;

//
// LayVBoxView's
//
@interface NoteCellHeaderView : UIView<LayVBoxView>
@property (nonatomic) CGFloat spaceAbove;
@property (nonatomic) BOOL keepWidth;
@property (nonatomic) CGFloat border;
@end

@interface NoteTextLabel : UILabel<LayVBoxView>
@property (nonatomic) CGFloat spaceAbove;
@property (nonatomic) BOOL keepWidth;
@property (nonatomic) CGFloat border;
@end

@interface NoteImageView : UIImageView<LayVBoxView>
@property (nonatomic) CGFloat spaceAbove;
@property (nonatomic) BOOL keepWidth;
@property (nonatomic) CGFloat border;
@end

//
// LayAbstractCell
//
@interface LayNoteCell() {
    NoteCellHeaderView* headerView;
    UILabel *linkLabel;
    NoteTextLabel *textLabel;
    NoteImageView *imageView;
    CALayer *selectedLayer;
    LayMiniIconBar *miniIconBar;
    UITapGestureRecognizer *editGesture;
    LayVcQuestion *vcQuestion;
}
@end


NSString* const noteCellIdentifier = @"CellResource";

@implementation LayNoteCell

@synthesize note, canOpenLinkedQuestionsOrExplanations;

+(void)initialize {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    g_cellWidth = screenWidth;
    g_HEIGHT_LINK_LABEL = [styleGuide getFont:SmallFont].lineHeight;
    g_TextAndImageViewWidth = g_cellWidth - 2*[styleGuide getHorizontalScreenSpace];
}

+(CGFloat) heightForNote:(UGCNote*)note {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    CGFloat cellHeight = 0.0f;
    cellHeight += g_HEIGHT_LINK_LABEL + g_VERTICAL_SPACE;
    if(note.text) {
        UIFont *fontTitle = [styleGuide getFont:NormalPreferredFont];
        const CGFloat heightText = [LayFrame heightForText:note.text withFont:fontTitle maxLines:MAX_NUMBER_LINES_TEXT andCellWidth:g_cellWidth];
        cellHeight += heightText + g_VERTICAL_SPACE;
    } else if(note.mediaRef) {
        cellHeight += g_HEIGHT_OF_THUMBNAIL_VIEW + g_VERTICAL_SPACE;
    }
    
    cellHeight += 2*g_VERTICAL_SPACE;
    
    return cellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
        self->headerView = [[NoteCellHeaderView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, g_cellWidth, g_HEIGHT_LINK_LABEL)];
        [self setupHeaderView];
        [self.contentView addSubview:self->headerView];
        //
        self->textLabel = [[NoteTextLabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, g_cellWidth-2*hSpace, 0.0f)];
        [self setPropertiesTextLabel];
        [self.contentView addSubview:self->textLabel];
        //
        self->imageView = [[NoteImageView alloc]initWithFrame:CGRectMake(hSpace, 0.0f, g_cellWidth-2*hSpace, g_HEIGHT_OF_THUMBNAIL_VIEW)];
        [self setPropertiesImageView];
        [self.contentView addSubview:self->imageView];
        
        self->editGesture = [[UITapGestureRecognizer alloc]
                           initWithTarget:self action:@selector(editNote:)];
        self->editGesture.numberOfTouchesRequired = 2;
        [self addGestureRecognizer:self->editGesture];
        
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIColor *selectedColor = [styleGuide getColor:ButtonSelectedBackgroundColor];
        UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        selectedBackgroundView.backgroundColor = selectedColor;
        [self setSelectedBackgroundView:selectedBackgroundView];
        //[self setupSelectedLayer];
    }
    return self;
}

-(void)dealloc {
    self->vcQuestion = nil;
    MWLogDebug([LayNoteCell class], @"dealloc");
}

/*- (void)setSelected:(BOOL)selected_ animated:(BOOL)animated
{
    selected = selected_;
    if(selected) {
        self->selectedLayer = [[CALayer alloc]init];
        CGRect layerRect = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
        self->selectedLayer.frame = layerRect;
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        self->selectedLayer.backgroundColor = [styleGuide getColor:WhiteTransparentBackground].CGColor;
        [self.layer addSublayer:selectedLayer];
    } else {
        [self->selectedLayer removeFromSuperlayer];
    }
}*/

-(void)setupHeaderView {
    
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat widthOfLinkLabel = (g_cellWidth - 2*linkIndent) * 0.8f; //TODO calc the correct space for miniIcon
    self->linkLabel = [[UILabel alloc]initWithFrame:CGRectMake(linkIndent, 0.0f, widthOfLinkLabel, g_HEIGHT_LINK_LABEL)];
    linkLabel.textColor = [styleGuide getColor:TextColor];
    linkLabel.numberOfLines = 1;
    linkLabel.font = [styleGuide getFont:SmallFont];
    linkLabel.textAlignment = NSTextAlignmentLeft;
    linkLabel.textColor = [styleGuide getColor:TextColor];
    linkLabel.backgroundColor = [UIColor clearColor];
    self->headerView.backgroundColor = [styleGuide getColor:GrayTransparentBackground];
    self->headerView.keepWidth = YES;
    [self->headerView addSubview:linkLabel];
    self->miniIconBar = [[LayMiniIconBar alloc]initWithWidth:self.frame.size.width];
    self->miniIconBar.showDisabledIcons = NO;
    self->miniIconBar.positionId = MINI_POSITION_TOP;
    self->miniIconBar.showUserIcon = YES;
    [self->headerView addSubview:self->miniIconBar];
}

-(void)setPropertiesImageView {
    self->imageView.contentMode = UIViewContentModeScaleAspectFit;
    self->imageView.spaceAbove = g_VERTICAL_SPACE;
    self->imageView.keepWidth = YES;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    self->imageView.border = hSpace;
}

-(void)setPropertiesTextLabel {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    self->textLabel.spaceAbove = g_VERTICAL_SPACE;
    self->textLabel.border = hSpace;
    self->textLabel.textAlignment = NSTextAlignmentLeft;
    self->textLabel.font = [styleGuide getFont:NormalPreferredFont];
    self->textLabel.backgroundColor = [UIColor clearColor];
    self->textLabel.numberOfLines = MAX_NUMBER_LINES_TEXT;
    self->textLabel.textColor = [styleGuide getColor:TextColor];
}

-(void)setNote:(UGCNote *)note_ {
    // reset
    note = note_;
    self->textLabel.hidden = YES;
    self->imageView.hidden = YES;
    [self->miniIconBar show:NO miniIcon:MINI_USER];
    //
    self->linkLabel.text = [NSDateFormatter localizedStringFromDate:note.created dateStyle: NSDateFormatterShortStyle timeStyle: NSDateFormatterShortStyle];
    [self->linkLabel sizeToFit];
    CGFloat newWidthOfHeaderView = linkIndent + self->linkLabel.frame.size.width + linkIndent;
    [LayFrame setWidthWith:newWidthOfHeaderView toView:self->headerView];
    
    if(note.text) {
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        self->textLabel.font = [styleGuide getFont:NormalPreferredFont];
        self->textLabel.hidden = NO;
        self->textLabel.text = note.text;
        [self->textLabel sizeToFit];
    } else {
        UGCMedia *uMedia = note.mediaRef;
        [self showAsThumbnail:uMedia.thumbnail];
    }
    
    [self layoutCell];
}

-(void)showAsThumbnail:(NSData*)imageData {
    self->imageView.hidden = NO;
    UIImage *image = [UIImage imageWithData:note.mediaRef.thumbnail];
    self->imageView.image = image;
}

-(void)layoutCell {
    [LayVBoxLayout layoutVBoxSubviewsInView:self.contentView];
}

//
// Menu handling callbacks
//
-(BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    BOOL canPerformAction = NO;
    if(self.canOpenLinkedQuestionsOrExplanations) {
        if(action == @selector(openRelatedQuestions:)){
            if([self.note.questionRef count] > 0 ) {
                canPerformAction = YES;
            }
        } else if(action == @selector(openRelatedExplanations:)){
            if([self.note.explanationRef count] > 0 ) {
                canPerformAction = YES;
            }
        }
    }
    
    if(action == @selector(edit:) && self.note.text){
        canPerformAction = YES;
    }
    
    return canPerformAction;
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

// sender is the MenuController
-(void)openRelatedQuestions:(id)sender {
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    catalogManager.selectedQuestions = [self.note questionList];
    self->vcQuestion = [LayVcQuestion new];
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:vcQuestion];
    [navController setNavigationBarHidden:YES animated:NO];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    UIViewController *viewController = [self viewController];
    if(viewController) {
        [viewController presentViewController:navController animated:YES completion:nil];
    } else {
        MWLogError( [LayNoteCell class], @"Could not get a link to the viewcontroller!");
    }
    
}

//
// Menu handlers
//
-(void)openRelatedExplanations:(id)sender {
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    catalogManager.selectedExplanations = [self.note explanationList];
    LayVcExplanation *vcExplanation = [LayVcExplanation new];
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:vcExplanation];
    [navController setNavigationBarHidden:YES animated:NO];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    UIViewController *viewController = [self viewController];
    if(viewController) {
        [viewController presentViewController:navController animated:YES completion:nil];
    } else {
        MWLogError( [LayNoteCell class], @"Could not get a link to the viewcontroller(Explanation)!");
    }
}

-(void)edit:(id)sender {
    if(self.delegate) {
        [self.delegate editNote:self.note];
    }
}

- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController*)nextResponder;
        }
    }
    
    return nil;
}

//
// Action handlers
//
- (void)editNote:(UITapGestureRecognizer *)recognizer {
    LayNoteCell *noteCell = (LayNoteCell *)recognizer.view;
    if(self.delegate) {
        [self.delegate editNote:noteCell.note];
    }
}

@end

//
//
//
@implementation NoteCellHeaderView
@synthesize spaceAbove, keepWidth, border;
@end

@implementation NoteTextLabel
@synthesize spaceAbove, keepWidth, border;
@end

@implementation NoteImageView
@synthesize spaceAbove, keepWidth, border;
@end

