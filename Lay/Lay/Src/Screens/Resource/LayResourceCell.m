//
//  LayCatalogAbstractListCell.m
//  Lay
//
//  Created by Rene Kollmorgen on 23.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayResourceCell.h"
#import "LayVBoxLayout.h"
#import "LayVBoxView.h"
#import "LayMediaView.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"
#import "LayMiniIconBar.h"
#import "LayCatalogManager.h"
#import "LayVcQuestion.h"
#import "LayVcExplanation.h"

#import "Resource+Utilities.h"
#import "UGCResource+Utilities.h"

#import "MWLogging.h"

static const CGFloat g_VERTICAL_SPACE = 7.0f;
static const CGFloat g_HORIZONTAL_BORDER = 2.0f;
static CGFloat g_HEIGHT_LINK_LABEL = 15.0f;
static const CGFloat g_WIDTH_NUMBER_LABEL = 40.0f;
static const CGFloat linkIndent = 5.0f;
static const NSInteger g_maxNumberOfLines = 500;

static CGFloat g_cellWidth;
static CGFloat g_titleAndTextWidth;

//
// LayVBoxView's
//
@interface HeaderView : UIView<LayVBoxView>
@property (nonatomic) CGFloat spaceAbove;
@property (nonatomic) BOOL keepWidth;
@property (nonatomic) CGFloat border;
@end

@interface ResourceTitleLabel : UILabel<LayVBoxView>
@property (nonatomic) CGFloat spaceAbove;
@property (nonatomic) BOOL keepWidth;
@property (nonatomic) CGFloat border;
@end

@interface TextLabel : UILabel<LayVBoxView>
@property (nonatomic) CGFloat spaceAbove;
@property (nonatomic) BOOL keepWidth;
@property (nonatomic) CGFloat border;
@end

//
// LayAbstractCell
//
@interface LayResourceCell() {
    HeaderView* headerView;
    UILabel *linkLabel;
    ResourceTitleLabel *titleLabel;
    TextLabel *textLabel;
    CALayer *selectedLayer;
    LayMiniIconBar *miniIconBar;
    LayVcQuestion *vcQuestion;
}
@end


NSString* const resourceCellIdentifier = @"CellResource";

@implementation LayResourceCell

@synthesize resource, canOpenLinkedQuestionsOrExplanations;

+(void)initialize {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    g_cellWidth = screenWidth;
    g_HEIGHT_LINK_LABEL = [styleGuide getFont:SmallFont].lineHeight;
    g_titleAndTextWidth = g_cellWidth - 2*[styleGuide getHorizontalScreenSpace];
}

+(CGFloat) heightForResource:(Resource*)resource {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    CGFloat cellHeight = 0.0f;
    LayResourceTypeIdentifier resourceType = [resource resourceType];
    cellHeight += g_HEIGHT_LINK_LABEL + g_VERTICAL_SPACE;
    UIFont *fontTitle = [styleGuide getFont:NormalPreferredFont];
    const CGFloat heightTitle = [LayFrame heightForText:resource.title withFont:fontTitle maxLines:g_maxNumberOfLines andCellWidth:g_titleAndTextWidth];
    cellHeight += heightTitle + g_VERTICAL_SPACE;
    if(resourceType == RESOURCE_TYPE_BOOK) {
        // resource of type BOOK
        UIFont *fontText = [styleGuide getFont:SmallPreferredFont];
        CGFloat heightText = [LayFrame heightForText:resource.text withFont:fontText maxLines:g_maxNumberOfLines andCellWidth:g_titleAndTextWidth];
        cellHeight += heightText + g_VERTICAL_SPACE;
    }
    
    cellHeight += 2*g_VERTICAL_SPACE;
    
    return cellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.canOpenLinkedQuestionsOrExplanations = NO;
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
        self->headerView = [[HeaderView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, g_cellWidth, g_HEIGHT_LINK_LABEL)];
        [self setupHeaderView];
        [self.contentView addSubview:self->headerView];
        //
        self->titleLabel = [[ResourceTitleLabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, g_cellWidth-2*hSpace, 0.0f)];
        [self setPropertiesTitleLabel];
        [self.contentView addSubview:self->titleLabel];
        //
        self->textLabel = [[TextLabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, g_cellWidth-2*hSpace, 0.0f)];
        self->textLabel.hidden = YES;
        [self setPropertiesTextLabel];
        [self.contentView addSubview:self->textLabel];
 
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIColor *selectedColor = [styleGuide getColor:ButtonSelectedBackgroundColor];
        UIView * selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        selectedBackgroundView.backgroundColor = selectedColor;
        [self setSelectedBackgroundView:selectedBackgroundView];
    }
    return self;
}

-(void)dealloc {
    self->vcQuestion = nil;
    MWLogDebug([LayResourceCell class], @"dealloc");
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

-(void)setPropertiesTitleLabel {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    self->titleLabel.spaceAbove = g_VERTICAL_SPACE;
    self->titleLabel.border = hSpace;
    self->titleLabel.textAlignment = NSTextAlignmentLeft;
    self->titleLabel.font = [styleGuide getFont:NormalPreferredFont];
    self->titleLabel.textColor = [styleGuide getColor:TextColor];
    self->titleLabel.backgroundColor = [UIColor clearColor];
    self->titleLabel.numberOfLines = g_maxNumberOfLines;
}

-(void)setPropertiesTextLabel {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    self->textLabel.spaceAbove = g_VERTICAL_SPACE;
    self->textLabel.border = hSpace;
    self->textLabel.textAlignment = NSTextAlignmentLeft;
    self->textLabel.font = [styleGuide getFont:SmallPreferredFont];
    self->textLabel.backgroundColor = [UIColor clearColor];
    self->textLabel.numberOfLines = g_maxNumberOfLines;
    self->textLabel.textColor = [styleGuide getColor:TextColor];
}

-(void)setResource:(Resource *)resource_ {
    // reset
    resource = resource_;
    self->textLabel.hidden = YES;
    [self->miniIconBar show:NO miniIcon:MINI_USER];
    //
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    LayResourceTypeIdentifier resourceType = [resource resourceType];
    if(resourceType == RESOURCE_TYPE_BOOK) {
        self->textLabel.hidden = NO;
        self->textLabel.font = [styleGuide getFont:SmallPreferredFont];
        self->textLabel.text = resource.text;
        [self->textLabel sizeToFit];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    self->linkLabel.text = [self host:resource.link ofType:resourceType];
    [self->linkLabel sizeToFit];
    CGFloat newWidthOfHeaderView = linkIndent + self->linkLabel.frame.size.width + linkIndent;
    [LayFrame setWidthWith:newWidthOfHeaderView toView:self->headerView];
    self->titleLabel.font = [styleGuide getFont:NormalPreferredFont];
    self->titleLabel.text = resource.title;
    [self->titleLabel sizeToFit];
    
    if([resource_ isKindOfClass:[UGCResource class]]) {
        [self->miniIconBar show:YES miniIcon:MINI_USER];
    }
    
    [self layoutCell];
}

-(void)layoutCell {
    [LayVBoxLayout layoutVBoxSubviewsInView:self.contentView];
}

-(NSString*)host:(NSString*)link ofType:(LayResourceTypeIdentifier)resourceTypeId {
    NSString *linkAbstract = nil;
    if(resourceTypeId==RESOURCE_TYPE_WEB || resourceTypeId==RESOURCE_TYPE_FILE) {
        NSURL *url = [NSURL URLWithString:link];
        if(url) {
            linkAbstract = [url host];
        }
    } else if(resourceTypeId==RESOURCE_TYPE_BOOK) {
        linkAbstract = NSLocalizedString(@"ResourceBookLinkValue", nil);
    }
    return linkAbstract;
}

//
// Menu handling callbacks
//
-(BOOL) canPerformAction:(SEL)action withSender:(id)sender {
    BOOL canPerformAction = NO;
    if(self.canOpenLinkedQuestionsOrExplanations) {
        if(action == @selector(openRelatedQuestions:)){
            if([self.resource.questionRef count] > 0 ) {
                canPerformAction = YES;
            }
        } else if(action == @selector(openRelatedExplanations:)){
            if([self.resource.explanationRef count] > 0 ) {
                canPerformAction = YES;
            }
        }
    }
    
    if(action == @selector(edit:)){
        if([self.resource isKindOfClass:[UGCResource class]]) {
            canPerformAction = YES;
        }
    }
    
    return canPerformAction;
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

// sender is the MenuController
-(void)openRelatedQuestions:(id)sender {
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    catalogManager.selectedQuestions = [self.resource questionList];
    self->vcQuestion = [LayVcQuestion new];;
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:vcQuestion];
    [navController setNavigationBarHidden:YES animated:NO];
    [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];

    UIViewController *viewController = [self viewController];
    if(viewController) {
        [viewController presentViewController:navController animated:YES completion:nil];
    } else {
        MWLogError( [LayResourceCell class], @"Could not get a link to the viewcontroller(Question)!");
    }

}

//
// Menu handlers
//
-(void)openRelatedExplanations:(id)sender {
    LayCatalogManager *catalogManager = [LayCatalogManager instance];
    catalogManager.selectedExplanations = [self.resource explanationList];
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
        MWLogError( [LayResourceCell class], @"Could not get a link to the viewcontroller(Explanation)!");
    }
}

-(void)edit:(id)sender {
    if(self.delegate) {
        [self.delegate editResource:self.resource];
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


@end

//
//
//
@implementation HeaderView
@synthesize spaceAbove, keepWidth, border;
@end

@implementation ResourceTitleLabel
@synthesize spaceAbove, keepWidth, border;
@end

@implementation TextLabel
@synthesize spaceAbove, keepWidth, border;
@end

