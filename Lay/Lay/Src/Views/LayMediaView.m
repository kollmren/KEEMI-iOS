//
//  LayMediaView.m
//  Lay
//
//  Created by Rene Kollmorgen on 07.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayMediaView.h"
#import "LayFrame.h"
#import "LayStyleGuide.h"
#import "LayAdditionalButton.h"
#import "LayAppNotifications.h"
#import "LayInfoDialog.h"
#import "LayIconButton.h"

#import "MWLogging.h"

@interface LayMediaView() {
    LayMediaData* mediaData;
    UIView *contentSubview;
    UILabel *label;
    UIButton *labelButton;
    BOOL labelIsShownCompletely;
    CGFloat initialViewWidth;
    BOOL answerWasEvaluated;
    BOOL storedWebviewPageLoaded; // prevent opening links in HTML
}
@end

static const CGFloat DEFAULT_BORDER_WIDTH = 5.0f;
static const CGFloat HSPACE_LABEL = 4.0f;
static const NSInteger TAG_IMAGE_FULLSCREEN_BACKGROUND = 1005;

@implementation LayMediaView

@synthesize border, borderWidth, fitToContent, fitLabelToFitContent, scaleToFrame, showLabel, ignoreEvents, zoomable, showFullscreen, removeAfterClosedFullscreen;

- (id)initWithFrame:(CGRect)frame_ andMediaData:(LayMediaData*)mediaData_
{
    self = [self initWithFrame:frame_];
    if (self) {
        self.fitLabelToFitContent = NO;
        self->labelIsShownCompletely = NO;
        self->answerWasEvaluated = NO;
        self->storedWebviewPageLoaded = NO;
        self->initialViewWidth = frame_.size.width;
        self->mediaData = mediaData_;
        self.borderWidth = DEFAULT_BORDER_WIDTH;
        self.scaleToFrame = NO;
        self.zoomable = YES;
        self.showFullscreen = NO;
        self.removeAfterClosedFullscreen = NO;
        [self setupView];
        //[self layoutMediaView];
        [self registerEvents];
    }
    return self;
}

-(void) dealloc {
    MWLogDebug([LayMediaView class], @"dealloc / mediaView with name:%@", self->mediaData.name);
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

-(void)setIgnoreEvents:(BOOL)ignoreEvents_ {
    ignoreEvents = ignoreEvents_;
    if(ignoreEvents) {
        [self unregisterEvents];
    }
}

-(void)setBorder:(BOOL)border_ {
    border = border_;
    if(border_) {
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        self.backgroundColor = [styleGuide getColor:ButtonBorderColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

-(void) setShowLabel:(BOOL)showLabel_ {
    showLabel = showLabel_;
    if(showLabel && mediaData.label && !self->label) {
        MWLogDebug([LayMediaView class], @"Set label for media with label:%@",self->mediaData.label);
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        CGRect frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 0.0f);
        self->label = [[UILabel alloc]initWithFrame:frame];
        self->label.numberOfLines = 1;
        self->label.font = [styleGuide getFont:SmallFont];
        self->label.textAlignment = NSTextAlignmentCenter;
        self->label.text = mediaData.label;
        self->label.backgroundColor = [styleGuide getColor:WhiteTransparentBackground];
        //self->label.layer.borderColor = [styleGuide getColor:BorderColor].CGColor;
        //self->label.layer.borderWidth = [styleGuide getBorderWidth:NormalBorder];
        self->labelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self->labelButton.showsTouchWhenHighlighted = YES;
        [self->labelButton addTarget:self action:@selector(showFullLabel) forControlEvents:UIControlEventTouchUpInside];
        [LayFrame setSizeWith:self->label.frame.size toView:self->labelButton];
        [self->labelButton addSubview:self->label];
        [self addSubview:self->labelButton];
        [self adjustLabelFrame];
    } else if(!showLabel_) {
        if(self->labelButton) {
            [self->labelButton removeFromSuperview];
            self->labelButton = nil;
            self->label = nil;
        }
    }
}

-(void)adjustLabelFrame {
    if(self->labelButton) {
        //
        // adjust the size
        //
        CGFloat labelWidth = self->initialViewWidth - 2*HSPACE_LABEL;
        if(self.fitLabelToFitContent) {
            labelWidth = self.frame.size.width;
        }
        [LayFrame setWidthWith:labelWidth toView:self->label];
        [self->label  sizeToFit];
        const CGSize hintLabelSize = self->label.frame.size;
        const CGFloat heightOfHint = hintLabelSize.height + 2*HSPACE_LABEL;
        if(hintLabelSize.width > labelWidth) {
            [LayFrame setSizeWith:CGSizeMake(labelWidth, heightOfHint) toView:self->label];
        } else {
            [LayFrame setHeightWith:heightOfHint toView:self->label animated:NO];
        }
        CGFloat yPos = 0.0f;
        CGFloat xPos = 0.0f;
        if(self.showFullscreen) {
            yPos = self.frame.size.height - heightOfHint - 10.0f;
            // We make the label a little smaller here so that the minimized buttons does not overlap the label.
            LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
            const CGFloat newLabelWidth = labelWidth - 2 * [styleGuide buttonSize].width - 2 * HSPACE_LABEL;
            [LayFrame setWidthWith:newLabelWidth toView:self->label];
        } else {

            yPos = self.frame.size.height - heightOfHint;
        }
        [LayFrame setSizeWith:self->label.frame.size toView:self->labelButton];
        //
        // adjust position
        //
        [LayFrame setYPos:yPos toView:self->labelButton];
        
        // center
        xPos = (self.frame.size.width - self->label.frame.size.width) / 2;
        
        [LayFrame setXPos:xPos toView:self->labelButton];
    }
}

-(void)setupView {
    if(nil!=self->mediaData) {
        if(self->mediaData.type == LAY_MEDIA_XML) {
            [self showInWebView:self->mediaData];
        } if(self->mediaData.type == LAY_MEDIA_IMAGE) {
            [self showInImageView:self->mediaData];
        }
    }
}

-(void)showInWebView:(LayMediaData*)mediaData_ {
    CGRect webViewFrame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    UIWebView *webView = [[UIWebView alloc]initWithFrame:webViewFrame];
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    if(mediaData_.format == LAY_FORMAT_HTML) {
        [webView loadData:mediaData_.data MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:nil];
        //[webView stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom = 3.0;"];
    } else {
        MWLogError([LayMediaView class], @"Todo:Unknown media type for webview!");
    }

    /*[webView setOpaque:NO];
    webView.backgroundColor = [UIColor yellowColor];*/
    [self addSubview:webView];
    self->contentSubview = webView;
}

-(void)showInImageView:(LayMediaData*)mediaData_ {
    UIImage *imageToShow = nil;
    if([mediaData_ uiimage]) {
        imageToShow = [mediaData_ uiimage];
    } else if(mediaData_.data) {
        imageToShow = [UIImage imageWithData:mediaData_.data];
        imageToShow = [UIImage imageWithCGImage:imageToShow.CGImage scale:2.0f orientation:imageToShow.imageOrientation];
        //imageToShow = [UIImage imageWithData:mediaData_.data scale:2.0f];
    }
    if(imageToShow) {
        CGRect imageViewFrame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageViewFrame];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeCenter;//UIViewContentModeScaleAspectFit;
        imageView.image = imageToShow;
        [self addSubview:imageView];
        self->contentSubview = imageView;
        
    } else {
        MWLogError([LayMediaView class], @"Image:%@ was not set!", mediaData_.name);
    }
}

-(void)addAdditionalButton {
    if( self->mediaData && self->mediaData.type == LAY_MEDIA_XML && !self.showFullscreen) {
        // Is shown in webview. As we dont know if the xml or html is rendered entirely we give the user the chance to open in in fullscreen.
        const CGFloat xPosAddButton = self.frame.size.width - additionalButtonSize.width;
        const CGFloat yPosAddButton = self.frame.size.height - additionalButtonSize.height;
        LayAdditionalButton *additionalButton = [[LayAdditionalButton alloc]initWithPosition:CGPointMake(xPosAddButton, yPosAddButton)];
        [self addSubview:additionalButton];
        
        [additionalButton->button addTarget:self action:@selector(showContentInFullScreen) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)layoutMediaView {
    if(self.showFullscreen) {
        if(self->mediaData.type == LAY_MEDIA_IMAGE) {
            UIImageView *imageView = (UIImageView*)self->contentSubview;
            // The image should be shown as fitted into the whole visible frame
            UIImage *imageToShow = imageView.image;
            CGSize sizeToFitImageView = [self sizeThatFitsImage:imageToShow intoMaxSize:imageView.frame.size mustBeDownScaled:nil];
            [LayFrame setSizeWith:sizeToFitImageView toView:imageView];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [imageView removeFromSuperview];
            imageView.userInteractionEnabled = NO;
            imageView.backgroundColor = [UIColor grayColor];
            
            UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.frame];
            scrollView.contentSize = imageView.frame.size;
            scrollView.minimumZoomScale = 1.0f;
            scrollView.maximumZoomScale = 5.0f;
            scrollView.delegate = self;
            scrollView.center = self.center;
            imageView.center = scrollView.center;
            [scrollView addSubview:imageView];
            [self addSubview:scrollView];
            
            UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(handleDoubleTap:)];
            doubleTap.numberOfTapsRequired = 2;
            [scrollView addGestureRecognizer:doubleTap];
        }
    } else {
        if(self->mediaData.type == LAY_MEDIA_IMAGE) {
            [self layoutMediaViewWithImage];
        } else if(self->mediaData.type == LAY_MEDIA_XML) {
            UIWebView *webView = (UIWebView*)self->contentSubview;
            webView.scalesPageToFit = NO;
            webView.userInteractionEnabled = NO;
            //webView.delegate = self;
        }
        
        if(self.zoomable) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(showContentInFullScreen)];
            [self addGestureRecognizer:tap];
        }
    }
    [self addAdditionalButton];
}

-(void)layoutMediaViewWithImage {
    CGFloat maxHeightOfContent = self.frame.size.height;
    CGFloat maxWidthOfContent = self.frame.size.width;
    if(self.border) {
        maxHeightOfContent -= 2 * self.borderWidth;
        maxWidthOfContent -= 2 * self.borderWidth;
    }
    CGSize newViewSize = self.frame.size;
    CGSize newContentViewSize = newViewSize;
    if(self->contentSubview && [self->contentSubview isKindOfClass:[UIImageView class]]) {
        MWLogDebug([LayMediaView class], @"Layout mediaView with no large image:%@!", self->mediaData.name );
        UIImageView *imageView = (UIImageView*)self->contentSubview;
        UIImage *imageToShow = imageView.image;
        CGSize imageSize = [imageToShow size];
        if(self.fitToContent) {
            // fitToContent adjusts the frame of the media-view only smaller not greater!
            MWLogDebug([LayMediaView class], @"Fit frame of view to content!" );
            CGSize maxSize = CGSizeMake(maxWidthOfContent, maxHeightOfContent);
            BOOL downScaleImage = NO; 
            newContentViewSize = [self sizeThatFitsImage:imageToShow intoMaxSize:maxSize mustBeDownScaled:&downScaleImage];
            newViewSize = newContentViewSize;
            if(downScaleImage) {
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                const CGSize imageSize = [imageToShow size];
                const CGFloat imageWidth = imageSize.width;
                const CGFloat imageHeight = imageSize.height;
                MWLogDebug([LayMediaView class], @"Downscale image:%@ to width:%f and height:%f", self->mediaData.name, imageWidth, imageHeight );
            }
        } else if(self.scaleToFrame) {
            UIImageView *imageView = (UIImageView*)self->contentSubview;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            MWLogDebug([LayMediaView class], @"Scale image:%@ to size of view:%f, %f!", self->mediaData.name, imageSize.width, imageSize.height  );
        }
    }
    
    if(self.border) {
        newViewSize = CGSizeMake(newViewSize.width + 2 * self.borderWidth, newViewSize.height + 2 * self.borderWidth);
    }
    
    [LayFrame setSizeWith:newViewSize toView:self];
    [LayFrame setSizeWith:newContentViewSize toView:self->contentSubview];
    self->contentSubview.center = CGPointMake(newViewSize.width / 2.0, newViewSize.height / 2.0);
}

-(CGSize)sizeThatFitsImage:(UIImage*)image intoMaxSize:(CGSize)maxSize mustBeDownScaled:(BOOL*)downScale {
    BOOL downScaleImage = NO;
    CGSize imageSize = [image size];
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
    if(imageWidth > maxSize.width ) {
        imageHeight = imageHeight * (maxSize.width/imageWidth);
        imageWidth = maxSize.width;
        downScaleImage = YES;
    }
    
    if(imageHeight > maxSize.height ) {
        imageWidth = imageWidth * (maxSize.height/imageHeight);
        imageHeight = maxSize.height;
        downScaleImage = YES;
    }
    if(downScale) {
        *downScale = downScaleImage;
    }
    
    CGSize sizeThatFitsImage = CGSizeMake(imageWidth, imageHeight);
    
    return sizeThatFitsImage;
}

-(void)registerEvents {
    if(mediaData.label) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(showLabelForEvent:) name:(NSString*)LAY_NOTIFICATION_ANSWER_EVALUATED object:nil];
        [nc addObserver:self selector:@selector(showLabelForEvent:) name:(NSString*)LAY_NOTIFICATION_QUESTION_PRESENTED object:nil];
        [nc addObserver:self selector:@selector(showLabelForEvent:) name:(NSString*)LAY_NOTIFICATION_EXPLANATION_PRESENTED object:nil];
        [nc addObserver:self selector:@selector(showLabelForEvent:) name:(NSString*)LAY_NOTIFICATION_DONT_SHOW_MEDIA_LABELS object:nil];
    }
}

-(void)unregisterEvents {
    MWLogDebug([LayMediaView class], @"Unregister events");
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

-(void)showLabelForEvent:(NSNotification*)notification {
    BOOL shouldShowLabel = NO;
    if([notification.name isEqualToString:(NSString*)LAY_NOTIFICATION_QUESTION_PRESENTED]) {
        if(self->answerWasEvaluated || [self showLabelBeforeEvaluated]) {
            shouldShowLabel = YES;
        }
    } else if([notification.name isEqualToString:(NSString*)LAY_NOTIFICATION_ANSWER_EVALUATED]) {
        shouldShowLabel = YES;
        self->answerWasEvaluated = YES;
    } else if([notification.name isEqualToString:(NSString*)LAY_NOTIFICATION_EXPLANATION_PRESENTED]) {
        shouldShowLabel = YES;
    } else if([notification.name isEqualToString:(NSString*)LAY_NOTIFICATION_DONT_SHOW_MEDIA_LABELS]) {
        shouldShowLabel = NO;
        MWLogDebug([LayMediaView class], @"Hide label for media with label:%@",self->mediaData.label);
    }
    
    // show the label only when there is one and the view is currently visible
    if(shouldShowLabel) {
        self.showLabel = YES;
    } else {
        self.showLabel = NO;
    }
}

-(BOOL)showLabelBeforeEvaluated {
    BOOL show = NO;
    NSString* valueSetIncatalogValue = [self->mediaData.showLabel lowercaseString];
    if([valueSetIncatalogValue isEqualToString:(NSString*)SHOW_LABEL_BEFORE_EVALUATED]) {
        show = YES;
    }
    return show;
}

-(void)showContentInFullScreen {
    if(self->mediaData.type == LAY_MEDIA_IMAGE) {
        [self showImageFullScreenInWindow];
    } else if( self->mediaData.type == LAY_MEDIA_XML ) {
        [self showWebViewContentFullScreen];
    } else {
        MWLogDebug([LayMediaView class], @"Unknown media-type:%d for fullscreen mode!", self->mediaData.type);
    }
}

-(void)showImageFullScreenInWindow {
    UIWindow *windowToShowIn = self.window;
    if(!windowToShowIn) {
        MWLogWarning( [LayMediaView class], @"Can not show image in fullscreen mode (window is nil)!");
        return;
    }
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    UIView *background = [[UIView alloc] initWithFrame:windowToShowIn.frame];
    background.tag = TAG_IMAGE_FULLSCREEN_BACKGROUND;
    background.backgroundColor = [[LayStyleGuide instanceOf:nil] getColor:InfoBackgroundColor];
    [windowToShowIn addSubview:background];
    
    UIView *container = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, background.frame.size.width, 0.0f)];
    container.clipsToBounds = YES;
    UIImage *image = [UIImage imageWithData:self->mediaData.data];
    LayMediaData *data = [LayMediaData byUIImage:image];
    const CGRect mediaViewRect = CGRectMake(0.0f, 0.0f, background.frame.size.width, background.frame.size.height);
    LayMediaView *mediaView = [[LayMediaView alloc]initWithFrame:mediaViewRect andMediaData:data];
    mediaView.showFullscreen = YES;
    [mediaView layoutMediaView];
    [container addSubview:mediaView];
    /*UIImageView *imageView = [UIImageView new];
     imageView.contentMode = UIViewContentModeScaleAspectFit;
     [LayFrame setSizeWith:backgound.frame.size toView:imageView];
     imageView.center = backgound.center;
     imageView.image = image;
     [container addSubview:imageView];
     */
    [background addSubview:container];
    //
    const CGFloat indent = 10.0f;
    const CGSize closeButtonSize = CGSizeMake(50.0f + indent, 30.0f);
    const CGFloat yPosCloseButton = background.frame.size.height - closeButtonSize.height;
    const CGFloat xPosCloseButton = -closeButtonSize.width;
    const CGRect closeButtonFrame = CGRectMake(xPosCloseButton, yPosCloseButton, closeButtonSize.width, closeButtonSize.height);
    UIView *closeButton = [[UIView alloc]initWithFrame:closeButtonFrame];
    UIButton *iconButon = [LayIconButton buttonWithId:LAY_BUTTON_CANCEL];
    [closeButton addSubview:iconButon];
    iconButon.center = CGPointMake(closeButtonSize.width/2.0f + indent, closeButtonSize.height/2.0f);
    [iconButon addTarget:self action:@selector(closeFullScreenMode) forControlEvents:UIControlEventTouchUpInside];
    [styleGuide makeRoundedBorder:closeButton withBackgroundColor:GrayTransparentBackground andBorderColor:ClearColor];
    [background addSubview:closeButton];
    
    const CGPoint dialogCenter = CGPointMake(0.0f, background.frame.size.height/2.0f);
    [LayFrame setPos:dialogCenter toView:container];
    const CGFloat dialogHeight = background.frame.size.height;//imageView.frame.size.height;
    CALayer *dialogLayer = container.layer;
    [UIView animateWithDuration:0.3 animations:^{
        dialogLayer.bounds = CGRectMake(0.0f, 0.0f, container.frame.size.width, dialogHeight);
    }];
    
    CALayer *closeButtonLayer = closeButton.layer;
    [UIView animateWithDuration:0.4 animations:^{
        closeButtonLayer.position = CGPointMake((closeButtonSize.width/2.0f) - indent,
                                                closeButtonLayer.position.y);
        
    }];
}

//
// Action handlers
//
-(void)closeFullScreenMode {
    UIWindow *window = self.window;
    UIView *fullScreenBackground = [window viewWithTag:TAG_IMAGE_FULLSCREEN_BACKGROUND];
    [fullScreenBackground removeFromSuperview];
    if(self.removeAfterClosedFullscreen) {
        MWLogDebug([LayMediaView class], @"Remove MediaView from superView!");
        [self removeFromSuperview];
    }
}

-(void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    UIView *view = gestureRecognizer.view;
    if([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView*)view;
        [scrollView setZoomScale:1.0f animated:YES];
    }
}

-(void)showFullLabel {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    UIFont *labelFont = [styleGuide getFont:SmallPreferredFont];
    const CGFloat currentLabelWidth = self->label.frame.size.width;
    NSString *currentLabelText = self->label.text;
    const CGFloat neededHeightForText = [LayFrame heightForText:currentLabelText withFont:labelFont maxLines:10 andCellWidth:currentLabelWidth];
    const CGFloat currentLabelHeight = self->label.frame.size.height;
    if(!self->labelIsShownCompletely && neededHeightForText > currentLabelHeight) {
        self->label.numberOfLines = 0;
        self->labelIsShownCompletely = YES;
        /*const CGFloat newLabelHeight = neededSizeForText.height + 2*HSPACE_LABEL;
        const CGSize newLabelSize = CGSizeMake( currentLabelWidth, newLabelHeight);
        [LayFrame setSizeWith:newLabelSize toView:self->label];
        [LayFrame setSizeWith:newLabelSize toView:self->labelButton];*/
        [self adjustLabelFrame];
    } else if(self->labelIsShownCompletely) {
       self->label.numberOfLines = 1;
        self->labelIsShownCompletely = NO;
        [self adjustLabelFrame];
    }
}

-(void)showWebViewContentFullScreen {
    LayInfoDialog *infoDlg = [[LayInfoDialog alloc]initWithWindow:self.window];
    NSString *title = self->mediaData.label;
    [infoDlg showResource:title link:self->mediaData.data];
}

//
// UIWebViewDelegate
//

 - (void)webViewDidFinishLoad:(UIWebView *)theWebView {
    /*
    CGSize contentSize = theWebView.scrollView.contentSize;
    CGSize viewSize = self.bounds.size;
    CGFloat scaleFactor = viewSize.width / contentSize.width;
    theWebView.scrollView.minimumZoomScale =scaleFactor;
    theWebView.scrollView.maximumZoomScale = 5.0f;
    theWebView.scrollView.zoomScale = scaleFactor; // this scales the already rendered image only!!
     */
     self->storedWebviewPageLoaded = YES;
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return !self->storedWebviewPageLoaded;
}

//
// UIScrollViewDelegate
//
-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    //CGSize contentSize = scrollView.contentSize;
    //MWLogDebug([LayMediaView class], @"ScrollView gets view to scroll with contentSize:%f, %f", contentSize.width, contentSize.height );
    return self->contentSubview;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    self->contentSubview.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
    
    
    /*
     CGSize contentSize = scrollView.contentSize;
     MWLogDebug([LayMediaView class], @"ScrollView zoomed:%f ,contentSize:%f, %f", scrollView.zoomScale, contentSize.width, contentSize.height );
    const CGRect imageViewFrame = self->contentSubview.frame;
    MWLogDebug([LayMediaView class], @"ScrollView zoomed. Frame imageView:%f, %f, %f, %f", imageViewFrame.origin.x, imageViewFrame.origin.y, imageViewFrame.size.width, imageViewFrame.size.height );
     MWLogDebug([LayMediaView class], @"ScrollView zoomed. Offset:%f, %f",scrollView.contentOffset.x, scrollView.contentOffset.y );
     */
}

@end
