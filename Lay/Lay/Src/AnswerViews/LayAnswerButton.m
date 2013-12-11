//
//  LayAnswerButton.m
//  Lay
//
//  Created by Rene Kollmorgen on 12.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayAnswerButton.h"
#import "LayInfoIconView.h"
#import "LayImage.h"
#import "LayMediaView.h"
#import "LayFrame.h"
#import "LayStyleGuide.h"

#import "AnswerItem+Utilities.h"
#import "Explanation+Utilities.h"

@interface LayButtonBorderLayer : NSObject
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL correct;
@property (nonatomic) BOOL showCorrectness;
@end

@interface LayAnswerButton() {
    LayInfoIconView *infoIcon;
    CALayer *markedIconLayer;
    CALayer *correctIconLayer;
    CALayer *incorrectIconLayer;
    CALayer *topLayer;
    CALayer *bottomLayer;
    CALayer *rightLayer;
    CALayer *leftLayer;
    CALayer *selectedLayer;
    CALayer *highlightLayer;
    BOOL evaluated;
    BOOL borderForMedia;
    NSTimer *highlightTimer;
}
@end

@implementation LayAnswerButton

@synthesize answerItem, width, height, XPos, YPos, showBorder,
showInfoIconIfEvaluated, showCorrectnessIconIfEvaluated, showMarkIndicator, buttonStyle, showIfHighlighted, showAsMarked, showAsWrong;

- (id)initWithFrame:(CGRect)frame and:(AnswerItem*)answerItem_
{
    return [self initWithFrame:frame and:answerItem_ andBorderForMedia:NO];
}

- (id)initWithFrame:(CGRect)frame and:(AnswerItem*)answerItem_ andBorderForMedia:(BOOL)borderForMedia_
{
    self = [super initWithFrame:frame];
    if (self) {
        self->infoIcon = nil;
        self.buttonStyle = StyleColumnLeft;
        self.showBorder = YES;
        self.showInfoIconIfEvaluated = YES;
        self.showCorrectnessIconIfEvaluated = YES;
        self.showMarkIndicator = YES;
        self.showIfHighlighted = YES;
        evaluated = NO;
        answerItem = answerItem_;
        self.tag = [answerItem_.number unsignedIntegerValue];
        self.answerButtonDelegate = nil;
        self.selected = NO;
        self->borderForMedia = borderForMedia_;
        self.backgroundColor = [UIColor clearColor];
        [self initLayer];
        [self setupButton:answerItem_];
        [self adjustBorder];
    }
    
    return self;
}

-(void)setButtonStyle:(LayButtonStyle)buttonStyle_ {
    buttonStyle = buttonStyle_;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    if(buttonStyle == StyleColumnLeft) {
        self->rightLayer.backgroundColor = [styleGuide getColor:ButtonBorderColor].CGColor;
    } else {
        self->leftLayer.backgroundColor = [styleGuide getColor:ButtonBorderColor].CGColor;
        self->selectedLayer.anchorPoint = CGPointMake(1.0f, 0.0f);
        self->selectedLayer.position = CGPointMake(self.frame.size.width, 0.0f);
    }
    [self adjustLayerTo:self.frame];
}

-(void)setupButton:(AnswerItem*)answerItem_ {
    if([answerItem_ hasMedia]) {
        [self setupButtonWithMedia:answerItem_];
    } else {
        [self setupButtonWithTextOnly:answerItem_];
    }
}

static const NSInteger TAG_TEXT = 100;
static const NSInteger TAG_MEDIA = 101;

-(void)setupButtonWithMedia:(AnswerItem*)answerItem_ {
    LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
    const CGFloat hIndent = [style getHorizontalScreenSpace];
    const CGFloat vIndent = [style buttonIndentVertical];
    const CGSize buttonFrameSize = self.frame.size;
    if(answerItem_.text) {
        // setup with text and media
        // media and text get the same space the half of the button
        const CGFloat itemWidth = (buttonFrameSize.width / 2.0f) - 3 * hIndent;
        const CGRect mediaFrame = CGRectMake(hIndent, vIndent, itemWidth, buttonFrameSize.height-2*vIndent);
        LayMediaData* mediaData = [self.answerItem mediaData];
        LayMediaView *mediaView = [[LayMediaView alloc]initWithFrame:mediaFrame andMediaData:mediaData];
        mediaView.fitLabelToFitContent = YES;
        mediaView.fitToContent = YES;
        //mediaView.border = self->borderForMedia;
        [mediaView layoutMediaView];
        mediaView.tag = TAG_MEDIA;
        [self addSubview:mediaView];
        const CGFloat xPosTextLabel = hIndent + mediaView.frame.size.width + hIndent;
        const CGFloat textWidth = buttonFrameSize.width - xPosTextLabel;
        const CGRect textLabelFrame = CGRectMake(xPosTextLabel, vIndent, textWidth, buttonFrameSize.height - 2*vIndent);
        UILabel *textLabel = [[UILabel alloc]initWithFrame:textLabelFrame];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.tag = TAG_TEXT;
        textLabel.font = [style getFont:NormalPreferredFont];
        textLabel.textColor = [style getColor:TextColor];
        textLabel.numberOfLines = [style numberOfLines];
        textLabel.text = answerItem_.text;
        [textLabel sizeToFit];
        //[LayFrame setWidthWith:itemWidth toView:textLabel];
        [self addSubview:textLabel];
        [self adjustButtonHeight];
        [self adjustLayerTo:self.frame];
    } else {
        // media only
        const CGRect mediaFrame = CGRectMake(hIndent, vIndent, buttonFrameSize.width - 2*hIndent, buttonFrameSize.height-2*vIndent);
        LayMediaData* mediaData = [self.answerItem mediaData];
        LayMediaView *mediaView = [[LayMediaView alloc]initWithFrame:mediaFrame andMediaData:mediaData];
        //mediaView.fitLabelToFitContent = YES;
        mediaView.fitToContent = YES;
        [mediaView layoutMediaView];
        mediaView.tag = TAG_MEDIA;
        [self addSubview:mediaView];
        [self adjustButtonHeight];
        [self adjustLayerTo:self.frame];
        mediaView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
}

-(void)setupButtonWithTextOnly:(AnswerItem*)answerItem_ {
    const CGSize buttonFrameSize = self.frame.size;
    LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
    const CGFloat hIndent = [style getHorizontalScreenSpace];
    const CGFloat vIndent = [style buttonIndentVertical];
    const CGFloat widthOfTextLabel = buttonFrameSize.width - 2*hIndent;
    const CGRect buttonLabelFrame = CGRectMake(hIndent, vIndent, widthOfTextLabel, buttonFrameSize.height - 2*vIndent);
    UILabel *textLabel = [[UILabel alloc]initWithFrame:buttonLabelFrame];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.tag = TAG_TEXT;
    textLabel.font = [style getFont:NormalPreferredFont];
    textLabel.numberOfLines = [style numberOfLines];
    textLabel.text = answerItem_.text;
    [textLabel sizeToFit]; // adjust the height only
    /*const CGFloat maxLabelHeight = buttonFrameSize.height - 2*vIndent;
    if(textLabel.frame.size.height > maxLabelHeight) {
        [LayFrame setHeightWith:maxLabelHeight toView:textLabel animated:NO];
    }
    // center label vertically
    [LayFrame setWidthWith:widthOfTextLabel toView:textLabel];
     */
    [self addSubview:textLabel];
    // adjust the height only
    [self adjustButtonHeight];
    [self adjustLayerTo:self.frame];
}

-(void)adjustButtonHeight {
    CGFloat newButtonHeight = 0.0f;
    UIView *media = [self viewWithTag:TAG_MEDIA];
    LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
    const CGFloat vIndent = [style buttonIndentVertical];
    if(media) {
        // The newButtonHeight can be max. of [style maxHeightOfAnswerButton]
        // ,here the button is adjusted to be smaller than the max height.
        newButtonHeight = media.frame.origin.y + media.frame.size.height + vIndent;
    }
    
    UIView *text = [self viewWithTag:TAG_TEXT];
    if(text) {
        CGFloat textHeight = text.frame.origin.y + text.frame.size.height + vIndent;
        if(textHeight > newButtonHeight) {
            newButtonHeight = textHeight;
        }
    }
    /*const CGSize buttonFrameSize = self.frame.size;
    const CGFloat maxButtonHeight = buttonFrameSize.height;
    if(maxButtonHeight < newButtonHeight) {
        // Only possible when the text-label is higher. The mediaView is scaled down into its given
        // size of frame.
        [LayFrame setHeightWith:maxButtonHeight toView:text animated:NO];
    }*/
    [LayFrame setHeightWith:newButtonHeight toView:self animated:NO];
}

-(void)setShowBorder:(BOOL)showBorder_ {
    showBorder = showBorder_;
    [self adjustBorder];
}

-(void)setShowMarkIndicator:(BOOL)showMarkIndicator_ {
    showMarkIndicator = showMarkIndicator_;
    if(showMarkIndicator) {
        [self->markedIconLayer setHidden:NO];
    } else {
        [self->markedIconLayer setHidden:YES];
    }
}

-(void)setShowAsMarked:(BOOL)showAsMarked_ {
    showAsMarked = showAsMarked_;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    if(showAsMarked) {
        self->selectedLayer.backgroundColor = [styleGuide getColor:ButtonSelectedColor].CGColor;
    } else {
        self->selectedLayer.backgroundColor = [styleGuide getColor:ClearColor].CGColor;
    }
}

-(void)doTap {
    [self tap];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self tap];
}


-(void)unhighlight {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    self->highlightLayer.backgroundColor = [styleGuide getColor:NoColor].CGColor;
}

-(void)highlight {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    self->highlightLayer.backgroundColor = [styleGuide getColor:ButtonSelectedBackgroundColor].CGColor;
    self->highlightTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(unhighlight) userInfo:nil repeats:NO];
}

-(void)mark {
    if(!self.selected) {
        self.selected = YES;
        if(self.showMarkIndicator) [self->markedIconLayer setHidden:NO];
        self.answerItem.setByUser = [NSNumber numberWithBool:YES];
    } else {
        [self unmark];
    }
    [self adjustBorder];
}

-(void)unmark {
    self.selected = NO;
    self.answerItem.setByUser = [NSNumber numberWithBool:NO];
    [self->markedIconLayer setHidden:YES];
    [self adjustBorder];
}

-(void) adjustBorder {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    if(showBorder) {
        self->topLayer.backgroundColor = [styleGuide getColor:ButtonBorderColor].CGColor;
        self->bottomLayer.backgroundColor = [styleGuide getColor:ButtonBorderColor].CGColor;
        if(self.selected) {
            self->selectedLayer.backgroundColor = [styleGuide getColor:ButtonSelectedColor].CGColor;
        } else {
            self->selectedLayer.backgroundColor = [styleGuide getColor:NoColor].CGColor;
        }
    } else {
        self->topLayer.backgroundColor = [styleGuide getColor:ClearColor].CGColor;
        self->bottomLayer.backgroundColor = [styleGuide getColor:ClearColor].CGColor;
    }
    
    [self adjustBorderEvaluated];
}

-(void) adjustBorderEvaluated {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    if(self->evaluated) {
        if([self.answerItem.correct boolValue] && self.showBorder && !self.showAsWrong ) {
            self->selectedLayer.backgroundColor = [styleGuide getColor:AnswerCorrect].CGColor;
        } else if(self.selected && self.showBorder) {
            self->selectedLayer.backgroundColor = [styleGuide getColor:AnswerWrong].CGColor;
        }
    }
}

-(void)adjustLayerTo:(CGRect)frame_ {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    CGSize iconButtonSize = [styleGuide iconButtonSize];
    CGFloat iconHeight = iconButtonSize.width / 2.0;
    CGFloat iconWidth = iconButtonSize.height / 2.0f;
    const CGSize buttonSize = frame_.size;
    const CGFloat indent = 6.0f;
    const CGFloat yIndent = 2.0f;
    if(!self->evaluated) {
        if(self.buttonStyle == StyleColumnLeft) {
            self->markedIconLayer.frame = CGRectMake(indent, yIndent, iconWidth, iconHeight);
        } else {
            const CGFloat xPos = buttonSize.width - indent - iconWidth;
            self->markedIconLayer.frame = CGRectMake(xPos, yIndent, iconWidth, iconHeight);
        }
        
    }
    const CGFloat borderHeight = [styleGuide getBorderWidth:NormalBorder];
    self->topLayer.bounds = CGRectMake(0.0f, 0.0f, buttonSize.width, borderHeight);
    self->bottomLayer.bounds = CGRectMake(0.0f, 0.0f, buttonSize.width, borderHeight);
    self->bottomLayer.position = CGPointMake(0.0f, buttonSize.height);
    self->selectedLayer.bounds = CGRectMake(0.0f, 0.0f, self->selectedLayer.bounds.size.width, buttonSize.height);
    self->leftLayer.bounds = CGRectMake(0.0f, 0.0f, self->leftLayer.bounds.size.width, buttonSize.height);
    self->rightLayer.bounds = CGRectMake(0.0f, 0.0f, self->rightLayer.bounds.size.width, buttonSize.height);
    self->highlightLayer.bounds = CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height);
    self->highlightLayer.position = CGPointMake(buttonSize.width / 2.0f, buttonSize.height / 2.0f);
}

-(void)showCorrectness {
    self->evaluated = YES;
    [self adjustBorder];
 //   if(self.showCorrectnessIconIfEvaluated || self.showInfoIconIfEvaluated || self.showMarkIndicator ) {
        [self adjustIconsForStateEvaluated];
  //  }
}

-(void)adjustIconsForStateEvaluated {
    // position icons
    CGRect buttonFrame = self.frame;
    const CGFloat buttonWidth = buttonFrame.size.width;
    static const CGFloat SPACE = 15.0f;
    UIView *media = [self viewWithTag:TAG_MEDIA];
    UIView *text = [self viewWithTag:TAG_TEXT];
    const CGFloat yDimensionMedia = media.frame.origin.y + media.frame.size.height;
    const CGFloat yDimensionText = text.frame.origin.y + text.frame.size.height;
    const CGFloat maxDimensionSubview = fmaxf(yDimensionMedia,yDimensionText);
    const CGFloat yPosIcon = maxDimensionSubview + SPACE;
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    CGSize iconButtonSize = [styleGuide iconButtonSize];
    CGFloat iconHeight = iconButtonSize.width;
    CGFloat iconWidth = iconButtonSize.height;
    BOOL correct = [self.answerItem.correct boolValue];
    if(self.showAsWrong) {
        correct = NO;
    }
    self->markedIconLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
    self->markedIconLayer.bounds = CGRectMake(self->markedIconLayer.position.x, self->markedIconLayer.position.y, iconWidth, iconHeight);
    BOOL answerButtonSizeChanged = NO;
    if([self->answerItem hasExplanation] && self.showInfoIconIfEvaluated) {
        if(infoIcon == nil) {
            self->infoIcon = [LayInfoIconView icon];
        }
        if([self->answerItem.setByUser boolValue] && self.showMarkIndicator) {
            [self->markedIconLayer setHidden:NO];
            CGFloat xPosIcon = (buttonWidth - 3 * iconWidth - 2 * SPACE) / 2;
            self->infoIcon.frame = CGRectMake(xPosIcon, yPosIcon, iconWidth, iconHeight);
            xPosIcon += iconWidth + SPACE;
            CGPoint newPosMarkIcon = CGPointMake(xPosIcon, yPosIcon);
            [self->markedIconLayer setPosition:newPosMarkIcon];
            xPosIcon += iconWidth + SPACE;
            self->correctIconLayer.frame = CGRectMake(xPosIcon, yPosIcon, iconWidth, iconHeight);
            self->incorrectIconLayer.frame = CGRectMake(xPosIcon, yPosIcon, iconWidth, iconHeight);
        } else if(correct && self.showCorrectnessIconIfEvaluated) {
            CGFloat xPosIcon = (buttonWidth - 2 * iconWidth - SPACE) / 2;
            self->infoIcon.frame = CGRectMake(xPosIcon, yPosIcon, iconWidth, iconHeight);
            xPosIcon += iconWidth + SPACE;
            self->correctIconLayer.frame = CGRectMake(xPosIcon, yPosIcon, iconWidth, iconHeight);
            self->incorrectIconLayer.frame = CGRectMake(xPosIcon, yPosIcon, iconWidth, iconHeight);
        } else {
            CGFloat xPosIcon = (buttonWidth - iconWidth) / 2;
            self->infoIcon.frame = CGRectMake(xPosIcon, yPosIcon, iconWidth, iconHeight);
        }
        [self addSubview:self->infoIcon];
        // adjust the height of the button
        const CGFloat newHeight = yPosIcon + iconHeight + SPACE;;
        if(newHeight > buttonFrame.size.height) {
            buttonFrame.size.height = yPosIcon + iconHeight + SPACE;
            answerButtonSizeChanged = YES;
        }
    } else if([self->answerItem.setByUser boolValue] && self.showMarkIndicator) {
        // center the mark icon
        [self->markedIconLayer setHidden:NO];
        CGFloat xPosIcon = (buttonWidth - 2 * iconWidth - SPACE) / 2;
        CGPoint newPosMarkIcon = CGPointMake(xPosIcon, yPosIcon);
        [self->markedIconLayer setPosition:newPosMarkIcon];
        xPosIcon += iconWidth + SPACE;
        self->correctIconLayer.frame = CGRectMake(xPosIcon, yPosIcon, iconWidth, iconHeight);
        self->incorrectIconLayer.frame = CGRectMake(xPosIcon, yPosIcon, iconWidth, iconHeight);
        // adjust the height of the button
        const CGFloat newHeight = yPosIcon + iconHeight + SPACE;;
        if(newHeight > buttonFrame.size.height) {
            buttonFrame.size.height = yPosIcon + iconHeight + SPACE;
            answerButtonSizeChanged = YES;
        }
    } else if(correct && self.showCorrectnessIconIfEvaluated){
        CGFloat xPosIcon = (buttonWidth - iconWidth) / 2;
        self->correctIconLayer.frame = CGRectMake(xPosIcon, yPosIcon, iconWidth, iconHeight);
        self->incorrectIconLayer.frame = CGRectMake(xPosIcon, yPosIcon, iconWidth, iconHeight);
        // adjust the height of the button
        const CGFloat newHeight = yPosIcon + iconHeight + SPACE;;
        if(newHeight > buttonFrame.size.height) {
            buttonFrame.size.height = yPosIcon + iconHeight + SPACE;
            answerButtonSizeChanged = YES;
        }
    }
    
    if(answerButtonSizeChanged) {
        self.frame = buttonFrame;
        [self adjustLayerTo:buttonFrame];
        if(self.answerButtonDelegate) {
            [self.answerButtonDelegate resized];
        }
    }
    
    if(self.selected) {
        if(correct && self.showCorrectnessIconIfEvaluated) {
            [self->correctIconLayer setHidden:NO];
            [self bringSublayerToFront:self->correctIconLayer];
        } else if(self.showCorrectnessIconIfEvaluated) {
            [self->incorrectIconLayer setHidden:NO];
            [self bringSublayerToFront:self->incorrectIconLayer];
        }
    } else if(correct && self.showCorrectnessIconIfEvaluated) {
        [self->correctIconLayer setHidden:NO];
        [self bringSublayerToFront:self->correctIconLayer];
    }
}

-(void)setWidth:(CGFloat)width_ {
    width = width_;
    CGRect frame = self.frame;
    frame.size.width = width_;
    self.frame = frame;
}

-(void)setHeight:(CGFloat)height_ {
    height = height_;
    CGRect frame = self.frame;
    frame.size.height = height_;
    self.frame = frame;
}

-(void)setXPos:(CGFloat)XPos_ {
    XPos = XPos_;
    CGRect frame = self.frame;
    frame.origin.x = XPos_;
    self.frame = frame;
}

-(void)setYPos:(CGFloat)YPos_ {
    YPos = YPos_;
    CGRect frame = self.frame;
    frame.origin.y = YPos_;
    self.frame = frame;
}

-(void)initLayer {
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
    self->leftLayer = [[CALayer alloc]init];
    self->leftLayer.anchorPoint = CGPointMake(0.5f, 0.0f);
    self->leftLayer.position = CGPointMake(0.0f, 0.0f);
    self->leftLayer.bounds = CGRectMake(0.0f, 0.0f, borderHeight, buttonSize.height);
    self->leftLayer.backgroundColor = [styleGuide getColor:ClearColor].CGColor;
    self->leftLayer.zPosition = 1;
    [self.layer addSublayer:self->leftLayer];
    self->rightLayer = [[CALayer alloc]init];
    self->rightLayer.anchorPoint = CGPointMake(0.5f, 0.0f);
    self->rightLayer.position = CGPointMake(buttonSize.width, 0.0f);
    self->rightLayer.bounds = CGRectMake(0.0f, 0.0f, borderHeight, buttonSize.height);
    self->rightLayer.backgroundColor = [styleGuide getColor:ClearColor].CGColor;
    self->rightLayer.zPosition = 1;
    [self.layer addSublayer:self->rightLayer];
    
    self->selectedLayer = [[CALayer alloc]init];
    self->selectedLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
    self->selectedLayer.position = CGPointMake(0.0f, 0.0f);
    self->selectedLayer.bounds = CGRectMake(0.0f, 0.0f, borderHeight * 5.0f, buttonSize.height );
    self->selectedLayer.backgroundColor = [styleGuide getColor:NoColor].CGColor;
    self->selectedLayer.zPosition = 1;
    [self.layer addSublayer:self->selectedLayer];
    //
    self->markedIconLayer = [[CALayer alloc]init];
    self->markedIconLayer.contentsGravity = kCAGravityResizeAspect;
    self->markedIconLayer.zPosition = 100;
    UIImage *margedImageIcon = [LayImage imageWithId:LAY_IMAGE_FLAG];
    CGImageRef iconMarked = [margedImageIcon CGImage];
    [self->markedIconLayer setContents:(__bridge id)(iconMarked)];
    [self->markedIconLayer setHidden:YES];
    [self.layer addSublayer:self->markedIconLayer];
    
    self->correctIconLayer = [[CALayer alloc]init];
    self->correctIconLayer.contentsGravity = kCAGravityResizeAspect;
    self->correctIconLayer.zPosition = 100;
    CGImageRef iconCorrect = [[LayImage imageWithId:LAY_IMAGE_DONE] CGImage];
    [self->correctIconLayer setContents:(__bridge id)(iconCorrect)];
    [self->correctIconLayer setHidden:YES];
    [self.layer addSublayer:self->correctIconLayer];
    
    self->incorrectIconLayer = [[CALayer alloc]init];
    self->incorrectIconLayer.contentsGravity = kCAGravityResizeAspect;
    self->incorrectIconLayer.zPosition = 100;
    CGImageRef iconIncorrect = [[LayImage imageWithId:LAY_IMAGE_WRONG] CGImage];
    [self->incorrectIconLayer setContents:(__bridge id)(iconIncorrect)];
    [self->incorrectIconLayer setHidden:YES];
    [self.layer addSublayer:self->incorrectIconLayer];
    
    self->highlightLayer = [[CALayer alloc]init];
    self->highlightLayer.backgroundColor = [styleGuide getColor:NoColor].CGColor;
    self->highlightLayer.zPosition = 200;
    [self.layer addSublayer:self->highlightLayer];
}

- (void)bringSublayerToFront:(CALayer *)layer {
    NSUInteger countSubLayers = [[self.layer sublayers]count];
    layer.zPosition = countSubLayers -1;
}

//
// Action handler
//
-(void)tap {
    if(showIfHighlighted) {
        [self highlight];
    }
    
    if(self->evaluated) {
        if([self->answerItem hasExplanation]) {
            if(self.answerButtonDelegate) {
                [self.answerButtonDelegate tapped:self wasSelected:self.selected];
            }
        }
    } else {
        [self mark];
        if(self.answerButtonDelegate) {
            [self.answerButtonDelegate tapped:self wasSelected:!self.selected];
        }
    }
    [self adjustBorder];
}

@end
