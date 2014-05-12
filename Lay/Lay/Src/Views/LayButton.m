//
//  LayButton.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 15.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayButton.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"
#import "LayMediaView.h"
#import "LayMediaData.h"
#import "LayImage.h"
#import "LayInfoDialog.h"
#import "LayVBoxLayout.h"

static const NSInteger TAG_LABEL = 101;
static const NSInteger TAG_TEXT_LABEL = 104;
static const NSInteger TAG_IMAGE = 102;
static const NSInteger TAG_ADD_INFO = 105;
static const NSInteger TAG_CONTAINER = 103;

@interface LayButton() {
    UILabel* labelView;
    LayMediaView* mediaView;
    UIView *container;
    UIFont* font;
    CGFloat initialMaxWidth;
    //
    CALayer *topLayer;
    CALayer *bottomLayer;
    CALayer *selectedLayer;
    //
    UIView *additionalInfoButton;
    UIButton *additionalInfoIconButton;
    //
    UIView *deleteButton;
    UIButton *deleteIconButton;
}

@end

@implementation LayButton

@synthesize label, isSelectable, showMediaWithBorder, topBottomLayer, addionalDetailInfoText, resource, delegate, normalBackgroundColor;

-(id)initWithFrame:(CGRect)frame label:(NSString*)label_ font:(UIFont *)font_ andColor:(UIColor *)color{
    self = [super initWithFrame:frame];
    if(self) {
        //UIImage *backgroundImage = [LayImage imageNamed:@"LayButtonBackgroundImage.png"];
        //[self setBackgroundImage:backgroundImage forState:UIControlStateHighlighted];
        self.isSelectable = NO;
        self.backgroundColor = color;
        self.normalBackgroundColor = color;
        initialMaxWidth = frame.size.width;
        self.selected = NO;
        label = label_;
        font = font_;
        const CGRect labelFrame = CGRectMake(0.0f, 0.0f, frame.size.width, 0.0f);
        self->labelView = [[UILabel alloc] initWithFrame:labelFrame];
        self->labelView.tag = TAG_LABEL;
        self->labelView.textAlignment = NSTextAlignmentLeft;
        self->labelView.font = font_;
        self->labelView.numberOfLines = 3;
        self->labelView.text = label;
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        self->labelView.textColor = [styleGuide getColor:ButtonSelectedColor];
        self->labelView.backgroundColor = [UIColor clearColor];
        const CGRect containerFrame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
        self->container = [[UIView alloc]initWithFrame:containerFrame];
        self->container.userInteractionEnabled = NO;
        self->container.tag = TAG_CONTAINER;
        self->container.backgroundColor = [UIColor clearColor];
        [self->container addSubview:self->labelView];
        [self addSubview:self->container];
        
        [self addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame label:(NSString*)label_ mediaData:(LayMediaData*)mediaData font:(UIFont*)font_ andColor:(UIColor *)color {
    self = [self initWithFrame:frame label:label_ font:font_ andColor:color];
    if(self) {
        const CGRect mediaViewFrame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
        self->mediaView = [[LayMediaView alloc]initWithFrame:mediaViewFrame andMediaData:mediaData];
        self->mediaView.zoomable = NO;
        self->mediaView.tag = TAG_IMAGE;
        self->mediaView.fitToContent = YES;
        self->mediaView.border = NO;
        [self->mediaView layoutMediaView];
        [self->container addSubview:mediaView];
    }
    return self;
}

-(void)setTopBottomLayer:(BOOL)topBottomLayer_ {
    topBottomLayer = topBottomLayer_;
    if(topBottomLayer) {
        //[self->borderLayer removeFromSuperlayer];
        //self.layer.cornerRadius = 0.0f;
        //[self->markedIconLayer removeFromSuperlayer];
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        self->labelView.textColor = [styleGuide getColor:TextColor];
        [self addTopAndBottomLayer];
    } else {
        [self->topLayer removeFromSuperlayer];
        [self->bottomLayer removeFromSuperlayer];
    }
}

-(void)setHighlighted:(BOOL)highlighted {
    if(highlighted) {
        LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
        self.backgroundColor = [style getColor:ButtonSelectedBackgroundColor];
    } else {
        self.backgroundColor = self.normalBackgroundColor;
    }
}

-(void)setAddionalDetailInfoText:(NSString *)addionalDetailInfoText_ {
    addionalDetailInfoText = addionalDetailInfoText_;
    [self addAddionalInfoButton];
}

-(void)setLabel:(NSString *)label_ {
    self->labelView.text = label_;
}

-(void)setShowMediaWithBorder:(BOOL)showMediaWithBorder_ {
    showMediaWithBorder = showMediaWithBorder_;
    if(showMediaWithBorder_) {
        self->mediaView.border = YES;
    } else {
        self->mediaView.border = NO;
    }
    [self->mediaView layoutMediaView];
}

-(void)addAddionalInfoButton {
    if(self->additionalInfoButton) {
        [self->additionalInfoButton removeFromSuperview];
        self->additionalInfoButton = nil;
    }
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGSize additionalInfoButtonSize = CGSizeMake(50.0f, 30.0f);
    const CGRect additionalInfoButtonFrame = CGRectMake(0.0f, 0.0f, additionalInfoButtonSize.width,
                                                        additionalInfoButtonSize.height);
    self->additionalInfoButton = [[UIView alloc] initWithFrame:additionalInfoButtonFrame];
    self->additionalInfoIconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self->additionalInfoIconButton.titleLabel.font = [styleGuide getFont:SmallFont];
    [self->additionalInfoIconButton setTitle:@"..." forState:UIControlStateNormal];
    [self->additionalInfoIconButton setTitleColor:[styleGuide getColor:TextColor] forState:UIControlStateNormal];
    [LayFrame setSizeWith:additionalInfoButtonSize toView:self->additionalInfoIconButton];
    self->additionalInfoIconButton.center = self->additionalInfoButton.center;
    [additionalInfoIconButton addTarget:self action:@selector(showAddionalInfo) forControlEvents:UIControlEventTouchUpInside];
    [self->additionalInfoButton addSubview:self->additionalInfoIconButton];
    [styleGuide makeRoundedBorder:self->additionalInfoButton withBackgroundColor:GrayTransparentBackground andBorderColor:ClearColor];
    const CGFloat xPosButton = self.frame.size.width - self->additionalInfoButton.frame.size.width;
    const CGFloat yPosButton = (self.frame.size.height - self->additionalInfoButton.frame.size.height) / 2.0f;
    const CGPoint posButton = CGPointMake(xPosButton, yPosButton);
    [LayFrame setPos:posButton toView:self->additionalInfoButton];
    [self addSubview:self->additionalInfoButton];
}

-(void)showAddionalInfo {
    LayInfoDialog *infoDlg = [[LayInfoDialog alloc]initWithWindow:self.window];
    NSArray *info = [NSArray arrayWithObject:self->addionalDetailInfoText];
    [infoDlg showInfo:info withTitle:self.label];
}

-(void)layoutContainer {
    [LayFrame setWidthWith:self->initialMaxWidth toView:self->container];
    const CGSize containerSize = self->container.frame.size;
    LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
    const CGFloat hIndent = [style getHorizontalScreenSpace];
    const CGFloat vIndent = [style buttonIndentVertical];
    CGFloat hSpace = 0.0f;
    CGFloat yPos = vIndent;
    UIView *addInfoView = [self->container viewWithTag:TAG_ADD_INFO];
    if(addInfoView) {
        const CGFloat infoSpace = 5.0f;
        [LayFrame setYPos:infoSpace toView:addInfoView];
        [LayFrame setXPos:infoSpace toView:addInfoView];
        yPos = infoSpace + addInfoView.frame.size.height + infoSpace;
    }
     
    UIView *mediaView_ = [self->container viewWithTag:TAG_IMAGE];
    CGSize mediaViewSize = CGSizeMake(0.0f, 0.0f);
    CGFloat xPos = hIndent;
    if(mediaView_) {
        mediaViewSize = mediaView.frame.size;
        [LayFrame setXPos:xPos toView:mediaView_];
        [LayFrame setYPos:yPos toView:mediaView_];
        xPos += mediaViewSize.width + hIndent;
        hSpace = hIndent;
    }
    const CGFloat availableWidthForLabel = containerSize.width - mediaViewSize.width - hSpace - 2 * hIndent;
    UILabel *labelView_ = (UILabel*)[self->container viewWithTag:TAG_LABEL];
    [LayFrame setWidthWith:availableWidthForLabel toView:labelView_];
    [labelView_ sizeToFit];
    [LayFrame setXPos:xPos toView:labelView_];
    const CGFloat newContainerWidth = xPos + labelView_.frame.size.width + hIndent;
    CGFloat newContainerHeight = yPos + labelView_.frame.size.height + vIndent;
    if(mediaView_ && mediaView_.frame.size.height > labelView_.frame.size.height) {
        newContainerHeight = vIndent + mediaView_.frame.size.height + vIndent;
    }
    yPos = (newContainerHeight - labelView_.frame.size.height) / 2.0f;
    [LayFrame setYPos:yPos toView:labelView_];
    
    UIView *textLabelView_ = [self->container viewWithTag:TAG_TEXT_LABEL];
    if(textLabelView_) {
        const CGFloat yPosTextLabel = newContainerHeight - vIndent/2.0f;
        const CGFloat xPosTextLabel = hIndent;
        const CGPoint posTextlabel = CGPointMake(xPosTextLabel, yPosTextLabel);
        [LayFrame setPos:posTextlabel toView:textLabelView_];
        newContainerHeight += textLabelView_.frame.size.height + vIndent;
    }
    
    // the media is vertical centered
    const CGFloat newYposMedia = (newContainerHeight - mediaView_.frame.size.height) / 2.0f;
    [LayFrame setYPos:newYposMedia toView:mediaView_];
    
    const CGSize newContainerSize = { newContainerWidth, newContainerHeight };
    [LayFrame setSizeWith:newContainerSize toView:self->container];
}

-(void)fitToContent {
    [self layoutContainer];
    [LayFrame setSizeWith:self->container.frame.size toView:self];
    [LayFrame setHeightWith:self->container.frame.size.height toView:self animated:NO];
    self->container.center = CGPointMake(self.frame.size.width/2.0f, self.frame.size.height/2.0f);
    self->bottomLayer.position = CGPointMake(0.0f, self.frame.size.height);
    [self adjustFrameOfMarkIndicatorLayer];
}

-(void)fitToHeight {
    [self layoutContainer];
    [LayFrame setHeightWith:self->container.frame.size.height toView:self animated:NO];
    //self->container.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    const CGPoint newPosContainer = CGPointMake(0.0f, 0.0f);
    [LayFrame setPos:newPosContainer toView:self->container];
    self->bottomLayer.position = CGPointMake(0.0f, self.frame.size.height);
    [self adjustFrameOfMarkIndicatorLayer];
}

-(void)addAddionalInfo:(NSString*)text asBubble:(BOOL)asBubble {
    UIView* infoView = [self viewWithTag:TAG_ADD_INFO];
    if(infoView) {
        [infoView removeFromSuperview];
    }
    
    const CGFloat indent = 10.0f;
    const CGRect frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, 0.0f);
    UILabel *info = [[UILabel alloc]initWithFrame:frame];
    info.text = text;
    info.backgroundColor = [UIColor clearColor];
    info.userInteractionEnabled = NO;
    info.textAlignment = NSTextAlignmentCenter;
    LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
    info.font = [style getFont:SmallFont];
    [info sizeToFit];
    const CGFloat newWidth = info.frame.size.width + indent;
    const CGFloat newHeight = info.frame.size.height + indent/2.0f;
    [LayFrame setWidthWith:newWidth toView:info];
    [LayFrame setHeightWith:newHeight toView:info animated:NO];
    
    if(asBubble) {
        const CGFloat newYPos = -(newHeight * 0.5f);
        [LayFrame setYPos:newYPos toView:info];
        [style makeRoundedBorder:info withBackgroundColor:WhiteBackground andBorderColor:ButtonBorderColor];
        info.layer.zPosition = 10.0f;
        const CGFloat xPos = self.frame.size.width - info.frame.size.width - indent;
        [LayFrame setXPos:xPos toView:info];
        [self addSubview:info];
    } else {
        [style makeRoundedBorder:info withBackgroundColor:GrayTransparentBackground];
        info.tag = TAG_ADD_INFO;
        [self->container addSubview:info];
    }
}

-(void)addText:(NSString*)text {
    LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
    const CGFloat hIndent = [style getHorizontalScreenSpace];
    const CGRect labelFrame = CGRectMake(0.0f, 0.0f, self.frame.size.width - 2*hIndent, 0.0f);
    UILabel *textLabel = [[UILabel alloc] initWithFrame:labelFrame];
    textLabel.tag = TAG_TEXT_LABEL;
    textLabel.textAlignment = NSTextAlignmentLeft;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    textLabel.font = [styleGuide getFont:SmallFont];
    textLabel.numberOfLines = [styleGuide numberOfLines];
    textLabel.text = text;
    textLabel.backgroundColor = [UIColor clearColor];
    [textLabel sizeToFit];
    [self->container addSubview:textLabel];
}

-(void)showTopBorderOnly {
    if(self->bottomLayer) {
        [self->bottomLayer removeFromSuperlayer];
    }
}

-(void)hiddeBorders:(BOOL)yesNo {
    if(self->bottomLayer && self->topLayer) {
        self->bottomLayer.hidden =yesNo;
        self->topLayer.hidden = yesNo;
    }
}

-(void)animateTap {
    //self.highlighted = YES;
    // Setup the properties of the animation
    /*CABasicAnimation *animation = [CABasicAnimation
                                   animationWithKeyPath:@"transform"];
    CATransform3D scaleMatrix = CATransform3DMakeScale(0.9f, 0.9f, 1.0f);
    CATransform3D identMatrix = CATransform3DIdentity;
    NSValue *scaleMatrixNsValue = [NSValue valueWithCATransform3D:scaleMatrix];
    NSValue *identMatrixNsValue = [NSValue valueWithCATransform3D:identMatrix];
    [animation setFromValue:identMatrixNsValue];
    [animation setToValue:scaleMatrixNsValue];
    [animation setDuration:0.1f];
    CALayer *buttonLayer = self.layer;
    // Start the animation
    [CATransaction begin];
    [buttonLayer addAnimation:animation forKey:@"scaleDown"];
    [CATransaction commit];*/
}

-(void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    UILabel *labelView_ = (UILabel*)[self->container viewWithTag:TAG_LABEL];
    labelView_.enabled = enabled;
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self showAsSelected:selected];
}

-(void)showAsSelected:(BOOL)selected {
    if(!self.isSelectable) return;
    if(selected) {
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        self->selectedLayer.backgroundColor = [styleGuide getColor:ButtonSelectedColor].CGColor;
    } else {
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        self->selectedLayer.backgroundColor = [styleGuide getColor:NoColor].CGColor;
    }
}

-(void)adjustFrameOfMarkIndicatorLayer {
    const CGSize buttonSize = self.frame.size;
    self->selectedLayer.bounds = CGRectMake(0.0f, 0.0f, self->selectedLayer.frame.size.width, buttonSize.height );
}

-(void)addTopAndBottomLayer {
    CGSize buttonSize = self.frame.size;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat borderHeight = [styleGuide getBorderWidth:NormalBorder];
    self->topLayer = [[CALayer alloc]init];
    self->topLayer.bounds = CGRectMake(0.0f, 0.0f, buttonSize.width, borderHeight);
    self->topLayer.anchorPoint = CGPointMake(0.0f, 0.5f);
    self->topLayer.position = CGPointMake(0.0f, 0.0f);
    self->topLayer.backgroundColor = [styleGuide getColor:ButtonBorderColor].CGColor;
    self->topLayer.zPosition = 1;
    [self.layer addSublayer:self->topLayer];
    self->bottomLayer = [[CALayer alloc]init];
    self->bottomLayer.anchorPoint = CGPointMake(0.0f, 0.5f);
    self->bottomLayer.position = CGPointMake(0.0f, buttonSize.height);
    self->bottomLayer.bounds = CGRectMake(0.0f, 0.0f, buttonSize.width, borderHeight);
    self->bottomLayer.backgroundColor = [styleGuide getColor:ButtonBorderColor].CGColor;
    self->bottomLayer.zPosition = 1;
    [self.layer addSublayer:self->bottomLayer];
    self->selectedLayer = [[CALayer alloc]init];
    self->selectedLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
    self->selectedLayer.position = CGPointMake(0.0f, 0.0f);
    self->selectedLayer.bounds = CGRectMake(0.0f, 0.0f, borderHeight * 5.0f, buttonSize.height );
    self->selectedLayer.backgroundColor = [styleGuide getColor:NoColor].CGColor;
    self->selectedLayer.zPosition = 1;
    [self.layer addSublayer:self->selectedLayer];
}

//
// Action handlers
//
-(void)buttonClicked {
    [self animateTap];
    self.selected = !self.selected;
}

@end
