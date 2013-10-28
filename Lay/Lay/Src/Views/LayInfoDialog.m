//
//  LayInfoDialogViewController.m
//  Lay
//
//  Created by Luis Remirez on 07.03.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayInfoDialog.h"
#import "LayFrame.h"
#import "LayStyleGuide.h"
#import "LayImageRibbon.h"
#import "LayImage.h"
#import "LayMediaData.h"
#import "LayAppNotifications.h"
#import "LayIconButton.h"
#import "LayExplanationView.h"

#import "Explanation+Utilities.h"
#import "Resource+Utilities.h"

#import "MWLogging.h"

static const CGSize ICON_SIZE = { 28.0f, 28.0f };
static const NSInteger HEIGTH_FILLED_RIBBON = 190.0f;
static const NSInteger TAG_IMAGE_RIBBON = 1001;
static const NSInteger TAG_TITLE_CONTAINER = 1002;
static const NSUInteger TAG_WEB_VIEW = 1004;
static const NSUInteger TAG_CLOSE_BUTTON = 1006;

@interface LayInfoDialog() {
    UIView* externalMainView;
    UIScrollView* scrollView;
    UIView* webPage;
    UIActivityIndicatorView *activity;
    UIView* infoView;
    UIImageView* icon;
    UILabel *title;
    UIView *titleContainer;
    NSDictionary* images;
    CGFloat titleLabelWidth;
    
    CGFloat maxHeightOfInfoView;
    __weak id caller;
    SEL selector;
}

@end

@implementation LayInfoDialog

-(id) initWithWindow:(UIWindow*)mainView_ {
    self = [super initWithFrame:mainView_.frame];
    if (self) {
        externalMainView = mainView_;
        [self registerIcons];
        [self setupViews];
        
        maxHeightOfInfoView = mainView_.frame.size.height * 0.8f;
    }
    
    return self;
}

-(void)dealloc {
    MWLogDebug([LayInfoDialog class], @"dealloc");
}

-(void)registerIcons {
    UIImage *infoIcon = [LayImage imageWithId:LAY_IMAGE_INFO];
    UIImage *statisticIcon = [LayImage imageWithId:LAY_IMAGE_STATISTICS];
    images = [[NSDictionary alloc] initWithObjectsAndKeys:
              infoIcon, @"INFO", statisticIcon, @"STATISTIC",
              nil];
}

static const CGFloat SPACE_ICON_TITLE = 10.0f;
-(void) setupViews {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    self.backgroundColor = [[LayStyleGuide instanceOf:nil] getColor:InfoBackgroundColor];
    [externalMainView addSubview:self];
    //
    const CGSize sizeEventView = self.frame.size;
    const CGFloat yPosInfoView = 30.0f;
    const CGFloat widthOfInfoView = sizeEventView.width;
    infoView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, yPosInfoView, widthOfInfoView, 0.0f)];
    infoView.backgroundColor = [styleGuide getColor:BackgroundColor];
    infoView.clipsToBounds = TRUE;
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, widthOfInfoView, 0.0f)];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bouncesZoom = YES;
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    scrollView.backgroundColor = [UIColor clearColor];
    [infoView addSubview:scrollView];
    // title
    const CGFloat yPosTitle = 10.0f;
    const CGFloat hIndent = [styleGuide getHorizontalScreenSpace];
    const CGFloat withOfSubViews = widthOfInfoView - 2*hIndent;
    const CGRect titleContainerRect = CGRectMake(hIndent, yPosTitle, withOfSubViews, 0.0f);
    self->titleContainer = [[UIView alloc]initWithFrame:titleContainerRect];
    self->titleContainer.tag = TAG_TITLE_CONTAINER;
    self->titleContainer.backgroundColor = [styleGuide getColor:WhiteTransparentBackground];
    icon = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, ICON_SIZE.width, ICON_SIZE.height)];
    [self->titleContainer addSubview:icon];
    const CGFloat xPosLabel = ICON_SIZE.width + SPACE_ICON_TITLE;
    self->titleLabelWidth = withOfSubViews - xPosLabel;
    title = [[UILabel alloc] initWithFrame:CGRectMake(xPosLabel, 0.0f, self->titleLabelWidth , 0.0f)];
    title.numberOfLines = [styleGuide numberOfLines];
    title.textAlignment =  NSTextAlignmentLeft;
    title.backgroundColor = [UIColor clearColor];
    title.font = [styleGuide getFont:HeaderPreferredFont];
    title.textColor = [styleGuide getColor:TextColor];
    [self->titleContainer addSubview:title];
    [scrollView addSubview:self->titleContainer];
    [self addSubview:infoView];
}

-(void)layoutTitle {
    CGFloat xPos = 0.0f;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hIndent = [styleGuide getHorizontalScreenSpace];
    const CGFloat withOfSubViews = self.frame.size.width - 2*hIndent;
    self->titleLabelWidth = withOfSubViews - xPos;
    if(!self->icon.hidden) {
        [LayFrame setXPos:xPos toView:self->icon];
        xPos += ICON_SIZE.width + SPACE_ICON_TITLE;
        self->titleLabelWidth -= xPos;
    }
    
    [LayFrame setWidthWith:self->titleLabelWidth  toView:self->title];
    [LayFrame setXPos:xPos toView:self->title];
    
}

-(void)setTitle:(NSString*)title_ andShowIcon:(BOOL)showIcon {
    self->icon.hidden = !showIcon;
    [self layoutTitle];
    //
    title.text = title_;
    [title sizeToFit];
    CGFloat newContainerHeight = title.frame.size.height;
    const CGFloat iconHeight = self->icon.frame.size.height;
    if(showIcon && iconHeight > newContainerHeight) {
        newContainerHeight = iconHeight;
    }
    [LayFrame setHeightWith:newContainerHeight toView:self->titleContainer animated:NO];
}

-(UIView*) showStatistic:(NSArray*)info withTitle:(NSString*)title_ caller:(id)caller_ selector:(SEL)selector_ {
    UIImage* image = [images objectForKey:@"STATISTIC"];
    return [self showInfo:info withTitle:title_ andIcon:image mediaList:nil caller:caller_ selector:selector_];
}

-(UIView*) showShortExplanation:(Explanation*)explanation {
    icon.image = [images objectForKey:@"INFO"];
    scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
    [LayFrame setHeightWith:0.0f toView:self->infoView animated:NO];
    const CGPoint infoViewCenter = CGPointMake(self->infoView.frame.origin.x, self->externalMainView.frame.size.height/2);
    [LayFrame setPos:infoViewCenter toView:self->infoView];
    
    for(UIView* subView in [scrollView subviews]) {
        [subView removeFromSuperview];
    }
    
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hIndent = [styleGuide getHorizontalScreenSpace];
    const CGFloat widthOfInfoItemText = self->infoView.frame.size.width - 2*hIndent;
    const CGFloat vSpace = 10.0f;
    CGFloat yPos = vSpace;
    const CGRect explanationViewRect = CGRectMake(hIndent, yPos, widthOfInfoItemText, 0.0f);
    LayExplanationView *explanationView = [[LayExplanationView alloc]initWithFrame:explanationViewRect andExplanation:explanation];
    yPos += explanationView.frame.size.height;
    [scrollView addSubview:explanationView];
    
    CGSize size = CGSizeMake(scrollView.frame.size.width, yPos);
    scrollView.contentSize = size;
    if(yPos>maxHeightOfInfoView) {
        yPos = maxHeightOfInfoView;
    }
    
    [LayFrame setHeightWith:yPos toView:scrollView animated:NO];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(hide)];
    [self addGestureRecognizer:singleTap];
    
    NSNotification *note = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_EXPLANATION_PRESENTED object:self];
    [[NSNotificationCenter defaultCenter] postNotification:note];

    [self open];
    return infoView;
}

-(UIView*) showResource:(NSString*)title_ link:(NSObject*)resource {
    icon.image = [images objectForKey:@"INFO"];
    
    [LayFrame setHeightWith:0.0f toView:self->infoView animated:NO];
    const CGPoint infoViewCenter = CGPointMake(self->infoView.frame.origin.x, self->externalMainView.frame.size.height/2);
    [LayFrame setPos:infoViewCenter toView:self->infoView];
    [self setTitle:title_ andShowIcon:NO];
    
    UIView *closeButton = [self->infoView viewWithTag:TAG_CLOSE_BUTTON];
    if(closeButton) {
        [closeButton removeFromSuperview];
    }
    
    if(self->activity) {
       [self->activity removeFromSuperview];
        self->activity = nil;
    }
    
    if(self->webPage) {
        [self->webPage removeFromSuperview];
        self->webPage = nil;
        
    }
    
    const CGFloat vSpace = 10.0f;
    const CGFloat xPosWebPage = 20.0f;
    const CGFloat heightWebPage = self->externalMainView.frame.size.height;
    const CGFloat widthWebPage = self->externalMainView.frame.size.width;
    const CGRect webPageFrame = CGRectMake(0.0f, xPosWebPage, widthWebPage, heightWebPage);
    self->webPage = [[UIView alloc]initWithFrame:webPageFrame];
    [self->webPage addSubview:self->titleContainer];
    const CGFloat yPosWebView = self->titleContainer.frame.origin.y + self->titleContainer.frame.size.height + vSpace;
    const CGFloat heightWebView = heightWebPage - yPosWebView - vSpace;
    const CGRect webViewFrame = CGRectMake(0.0f, yPosWebView, widthWebPage, heightWebView);
    UIWebView *webView = [[UIWebView alloc]initWithFrame:webViewFrame];
    webView.scalesPageToFit = YES;
    webView.tag = TAG_WEB_VIEW;
    webView.delegate = self;
    [self->webPage addSubview:webView];
    
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    if([resource isKindOfClass:[NSString class]]) {
        NSString *link_ = (NSString*)resource;
        NSURL *link = [NSURL URLWithString:link_];
        if(link) {
            activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activity.color = [styleGuide getColor:ButtonSelectedColor];
            activity.center = CGPointMake(CGRectGetMidX(webPage.layer.bounds), CGRectGetMidY(webPage.layer.bounds));
            [self->webPage addSubview:activity];
            NSURLRequest *request = [NSURLRequest requestWithURL:link];
            [webView loadRequest:request];
        } else {
            MWLogError([LayInfoDialog class], @"Can not open link:%@", link_);
        }
    } else if([resource isKindOfClass:[NSData class]]) {
         NSData *data = (NSData*)resource;
         [webView loadData:data MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
    } else {
        MWLogError([LayInfoDialog class], @"Can not open resource of type:%@", resource);
    }
    
    [self->scrollView removeFromSuperview];
    [self->infoView addSubview:self->webPage];
    [self openWebPage];
    
    const CGFloat indent = 10.0f;
    const CGSize closeButtonSize = CGSizeMake(50.0f + indent, 30.0f);
    const CGFloat yPosCloseButton = self->infoView.frame.size.height - closeButtonSize.height;
    const CGFloat xPosCloseButton = -closeButtonSize.width;
    const CGRect closeButtonFrame = CGRectMake(xPosCloseButton, yPosCloseButton, closeButtonSize.width, closeButtonSize.height);
    closeButton = [[UIView alloc]initWithFrame:closeButtonFrame];
    UIButton *iconButon = [LayIconButton buttonWithId:LAY_BUTTON_CANCEL];
    [closeButton addSubview:iconButon];
    iconButon.center = CGPointMake(closeButtonSize.width/2.0f + indent, closeButtonSize.height/2.0f);
    [iconButon addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [styleGuide makeRoundedBorder:closeButton withBackgroundColor:GrayTransparentBackground andBorderColor:ClearColor];
    [self->infoView addSubview:closeButton];

    CALayer *closeButtonLayer = closeButton.layer;
    [UIView animateWithDuration:0.4 animations:^{
        closeButtonLayer.position = CGPointMake((closeButtonSize.width/2.0f) - indent,
                                                closeButtonLayer.position.y);
        
    }];
    
    return infoView;

}

-(UIView*) showInfo:(NSArray*)info withTitle:(NSString*)title_ {
    return [self showInfo:info withTitle:title_ caller:nil selector:nil];
}

-(UIView*) showInfo:(NSArray*)info withTitle:(NSString*)title_ andMediaList:(NSArray*)mediaList {
    return [self showInfo:info withTitle:title_ mediaList:mediaList caller:nil selector:nil];
}

-(UIView*) showInfo:(NSArray*)info withTitle:(NSString*)title_ caller:(id)caller_ selector:(SEL)selector_ {
    UIImage* image = [images objectForKey:@"INFO"];
    return [self showInfo:info withTitle:title_ andIcon:image mediaList:nil caller:caller_ selector:selector_];
}


-(UIView*) showInfo:(NSArray*)info withTitle:(NSString*)title_ mediaList:(NSArray*)mediaList caller:(id)caller_ selector:(SEL)selector_ {
    UIImage* image = [images objectForKey:@"INFO"];
    return [self showInfo:info withTitle:title_ andIcon:image mediaList:mediaList caller:caller_ selector:selector_];
}

-(UIView*) showInfo:(NSArray*)info withTitle:(NSString*)title_ andIcon:(UIImage*)icon_ mediaList:(NSArray*)mediaList caller:(id)caller_ selector:(SEL)selector_ {
    caller = caller_;
    selector = selector_;
    scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
    
    [LayFrame setHeightWith:0.0f toView:self->infoView animated:NO];
    const CGPoint infoViewCenter = CGPointMake(self->infoView.frame.origin.x, self->externalMainView.frame.size.height/2);
    [LayFrame setPos:infoViewCenter toView:self->infoView];
    
    icon.image = icon_;
    
    BOOL showIcon = YES;
    UIImage* image = [images objectForKey:@"INFO"];
    if(icon_ == image) {
        showIcon = NO; // Do not display the info icon its useless, more space for text ...
    }
    
    [self setTitle:title_ andShowIcon:showIcon];
    
    NSArray* children = [scrollView subviews];
    for(UIView* child in children) {
        if(child.tag != TAG_TITLE_CONTAINER)
            [child removeFromSuperview];
    }
    
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hIndent = [styleGuide getHorizontalScreenSpace];
    const CGFloat widthOfInfoItemText = self->infoView.frame.size.width - 2*hIndent;
    const CGFloat vSpace = 10.0f;
    CGFloat yPos = self->titleContainer.frame.origin.y + self->titleContainer.frame.size.height + vSpace;
    CGRect frame = scrollView.frame;
    
    for(NSString* s in info) {
        UIView* entry = [self newEntry:s withWith:widthOfInfoItemText];
        entry.backgroundColor = [UIColor clearColor];
        [LayFrame setXPos:hIndent toView:entry];
        [LayFrame setYPos:yPos toView:entry];
        [scrollView addSubview:entry];
        yPos += entry.frame.size.height + vSpace;
    }
    //
    if(mediaList && [mediaList count]>0) {
        const CGRect ribbonFrame = CGRectMake(0.0f, 0.0f, infoView.frame.size.width, HEIGTH_FILLED_RIBBON);
        
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        const CGSize ribbonEntrySize = [styleGuide maxRibbonEntrySize];
        LayImageRibbon *imageRibbon = [[LayImageRibbon alloc]initWithFrame:ribbonFrame entrySize:ribbonEntrySize andOrientation:HORIZONTAL];
        imageRibbon.tag = TAG_IMAGE_RIBBON;
        imageRibbon.pageMode = YES;
        imageRibbon.entriesInteractive = YES;
        imageRibbon.animateTap = NO;
        imageRibbon.ribbonDelegate = self;
        for (Media* answerMedia in mediaList) {
            LayMediaData *mediaData = [LayMediaData byMediaObject:answerMedia];
            [imageRibbon addEntry:mediaData withIdentifier:0];
        }
        if([imageRibbon numberOfEntries]>0) {
            [imageRibbon layoutRibbon];
        }
        [LayFrame setYPos:yPos toView:imageRibbon];
        [imageRibbon fitHeightOfRibbonToEntryContent];
        [scrollView addSubview:imageRibbon];
        yPos += imageRibbon.frame.size.height + vSpace;
    }
    NSNotification *note = [NSNotification notificationWithName:(NSString*)LAY_NOTIFICATION_EXPLANATION_PRESENTED object:self];
    [[NSNotificationCenter defaultCenter] postNotification:note];
    
    CGSize size = CGSizeMake(frame.size.width, yPos);
    scrollView.contentSize = size;
    if(yPos>maxHeightOfInfoView) {
        yPos = maxHeightOfInfoView;
    }
    
    frame.size = CGSizeMake(frame.size.width, yPos);
    scrollView.frame = frame;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(hide)];
    [self addGestureRecognizer:singleTap];

    [self open];
    return infoView;
}

-(void) open {
    const CGFloat newInfoViewHeight = scrollView.frame.size.height;
    const CGFloat widthOfInfoView = self->infoView.frame.size.width;
    CALayer *infoViewLayer = self->infoView.layer;
    [UIView animateWithDuration:0.3 animations:^{
        infoViewLayer.position = self->externalMainView.layer.position;
        infoViewLayer.bounds = CGRectMake(0.0f, 0.0f, widthOfInfoView, newInfoViewHeight);
    }];
}

-(void) openWebPage {
    const CGFloat newInfoViewHeight = self->webPage.frame.size.height;
    const CGFloat widthOfInfoView = self->infoView.frame.size.width;
    CALayer *infoViewLayer = self->infoView.layer;
    [UIView animateWithDuration:0.3 animations:^{
        infoViewLayer.position = self->externalMainView.layer.position;
        infoViewLayer.bounds = CGRectMake(0.0f, 0.0f, widthOfInfoView, newInfoViewHeight);
    }];
}

-(void)cleanupView {
    UIView *closeButton = [self->infoView viewWithTag:TAG_CLOSE_BUTTON];
    if(closeButton) {
        [closeButton removeFromSuperview];
    }
    
    if(self->activity) {
        [self->activity removeFromSuperview];
        self->activity = nil;
    }
    
    if(self->webPage) {
        UIWebView *webView = (UIWebView*)[self->webPage viewWithTag:TAG_WEB_VIEW];
        webView.delegate = nil;
        [self->webPage removeFromSuperview];
        self->webPage = nil;
        
    }
}


-(void) hide {
    [self cleanupView];
    
    if(caller && [caller respondsToSelector:selector]) {
        [caller performSelector:selector];
    }
    if(self->scrollView.superview == nil) {
        // if the webview was shown
        [self->scrollView addSubview:self->titleContainer];
        [self->infoView addSubview:self->scrollView];
    } else if(self->titleContainer.superview == nil) {
        // if an explanation was shown
        [self->scrollView addSubview:self->titleContainer];
    }
    
    [self removeFromSuperview];
}

-(UIView*) newEntry:(NSString*)text withWith:(int)width{
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, width, 0.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    label.font = [styleGuide getFont:NormalPreferredFont];
    label.textColor = [styleGuide getColor:TextColor];
    label.numberOfLines = [styleGuide numberOfLines];
    label.text = text;
    [label sizeToFit];
    return label;
}

// LayImageRibbonDelegate
-(void)entryTapped:(NSInteger)identifier {
    [self hide];
}

-(void)scrolledToPage:(NSInteger)page {
    
}

//
// UIWebViewDelegate
//

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if(self->activity) {
        [self->activity stopAnimating];
        [self->activity removeFromSuperview];
        self->activity = nil;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if(self->activity) {
        [self->activity startAnimating];
       
    }
}



@end
