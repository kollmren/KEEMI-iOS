//
//  LayVcCatalogHeader.m
//  Lay
//
//  Created by Rene Kollmorgen on 18.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayVcStatisticListHeader.h"
#import "LayMediaData.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"
#import "LaySectionViewMetaInfo.h"
#import "LayCatalogManager.h"
#import "UGCCatalog+Utilities.h"
#import "LayUserDataStore.h"
#import "LayImage.h"
#import "LayMediaView.h"

#import "Catalog+Utilities.h"
#import "Media+Utilities.h"

#import "MWLogging.h"

@interface LayVcStatisticListHeader() {
    UIView *circle;
    UIView *legend;
}
@end

//
//
static const CGFloat YPOS_COVER = 10;
static const NSInteger TAG_MEDIA_VIEW = 1001;

@implementation LayVcStatisticListHeader

@synthesize catalogTitle, delegate;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
    }
    return self;
}

-(void)setCover:(Media *)cover_ {
    UIView *subview = [self.view viewWithTag:TAG_MEDIA_VIEW];
    if(subview) {
        [subview removeFromSuperview];
        subview = nil;
    }
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGSize coverSize = [styleGuide coverMediaSize];
    const CGRect coverMediaRect = CGRectMake(hSpace, YPOS_COVER, coverSize.width, coverSize.height);
    LayMediaData *coverMediaData = [LayMediaData byMediaObject:cover_];
    LayMediaView *mediaView = [[LayMediaView alloc]initWithFrame:coverMediaRect andMediaData:coverMediaData];
    mediaView.scaleToFrame = YES;
    mediaView.ignoreEvents = YES;
    mediaView.zoomable = NO;
    mediaView.tag = TAG_MEDIA_VIEW;
    [mediaView layoutMediaView];
    [self.view addSubview:mediaView];
}

-(void)dealloc {
    MWLogDebug([LayVcStatisticListHeader class], @"dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    
    const NSUInteger numberOfQuestions = [catalog numberOfQuestions];
    //const NSUInteger numberOfExplanations = [catalog numberOfExplanations];
    NSString *numberOfQuestionsLabel = NSLocalizedString(@"CatalogNumberOfQuestionsLabel", nil);
    NSString *textToShow = [NSString stringWithFormat:numberOfQuestionsLabel, numberOfQuestions];
    /*if(numberOfExplanations > 0) {
        NSString *numberOfExplanationsLabel = NSLocalizedString(@"CatalogNumberOfExplanationsLabel", nil);
        NSString *textWithExplanations = [NSString stringWithFormat:numberOfExplanationsLabel, numberOfExplanations];
        textToShow = [NSString stringWithFormat:@"%@  %@", textToShow, textWithExplanations];
    }*/
    const CGRect labelFrame = CGRectMake(self.catalogTitle.frame.origin.x, 0.0f, self.catalogTitle.frame.size.width, 0.0f);
    UILabel *summaryLabel = [[UILabel alloc]initWithFrame:labelFrame];
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    summaryLabel.font = [styleGuide getFont:SubInfoFont];
    summaryLabel.text = textToShow;
    summaryLabel.textColor = [UIColor darkGrayColor];
    summaryLabel.backgroundColor = [UIColor clearColor];
    summaryLabel.numberOfLines = 1;
    [summaryLabel sizeToFit];
    
    self.catalogTitle.font = [styleGuide getFont:NormalFont];
    self.catalogTitle.textColor = [styleGuide getColor:TextColor];
    self.catalogTitle.text = catalog.title;
    [self.catalogTitle sizeToFit];
    [self setCover:catalog.coverRef];
    
    const CGFloat newYPoslabel = self.catalogTitle.frame.origin.y + self.catalogTitle.frame.size.height + 10.0f;
    [LayFrame setYPos:newYPoslabel toView:summaryLabel];
    [self.view addSubview:summaryLabel];
    
    const CGFloat space = 15.0f;
    const CGSize coverSize = [styleGuide coverMediaSize];
    const CGFloat hSpace = [styleGuide getHorizontalScreenSpace];
    const CGFloat yPosCircle = YPOS_COVER + coverSize.height + space;
    const CGFloat dimensionCircle = self.view.frame.size.height - yPosCircle - space;
    const CGFloat xPosCircle = hSpace + (coverSize.width-dimensionCircle)/2.0f;
    const CGRect frameCircle = CGRectMake(xPosCircle, yPosCircle, dimensionCircle, dimensionCircle);
    self->circle = [[UIView alloc]initWithFrame:frameCircle];
    self->circle.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(circlePressed)];
    [self->circle addGestureRecognizer:tapGesture];
    [self.view addSubview:self->circle];
    
    [self drawCircle:catalog];
    [self setupLegend];
}

-(void)viewWillAppear:(BOOL)animated {
    Catalog *catalog = [LayCatalogManager instance].currentSelectedCatalog;
    [self drawCircle:catalog];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#define DEGREES_TO_RADIANS(degrees)  ((3.14159265359 * degrees)/ 180)

-(void)drawCircle:(Catalog*)catalog {
    LayUserDataStore *uStore = [LayUserDataStore store];
    UGCCatalog *uCatalog = [uStore findCatalogByTitle:catalog.title andPublisher:[catalog publisher]];
    const NSUInteger numberOfQuestionsTotal = [catalog numberOfQuestions];
    CGFloat  ratioAnsweredQuestions = 0.0f;
    CGFloat  ratioAnsweredCorrect = 0.0f;
    if(uCatalog) {
        NSUInteger numberOfQuestionsAlreadyAnswered = [[uCatalog alreadyAnsweredQuestions] count];
        if(numberOfQuestionsTotal > 0) {
            ratioAnsweredQuestions = (CGFloat)numberOfQuestionsAlreadyAnswered / (CGFloat)numberOfQuestionsTotal;
        }
        const NSUInteger totalCorrectAnswered = [uCatalog totalNumberCorrectAnsweredQuestions];
        const NSUInteger totalIncorrectAnswered = [uCatalog totalNumberIncorrectAnsweredQuestions];
        CGFloat percentAnsweredCorrect = totalCorrectAnswered * 100.0f / (totalCorrectAnswered + totalIncorrectAnswered);
        ratioAnsweredCorrect = percentAnsweredCorrect / 100.0f;
    }
    
    [self drawCircleWithRatioAnswered:ratioAnsweredQuestions correct:ratioAnsweredCorrect];
}


-(void)drawCircleWithRatioAnswered:(CGFloat)ratioAnswered correct:(CGFloat)ratioCorrect {
    NSArray *layerArray = [[self->circle.layer sublayers]copy];
    for (CALayer* layer in layerArray) {
        [layer removeFromSuperlayer];
    }
    
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    int radius = self->circle.frame.size.height/2;
    const CGFloat fullDegree = 360.0f;
    const CGFloat lineWidth = 3.0f;
    CGFloat currentDegree = 0.0f;
    // Part not answered questions
    const CGFloat ratioNotAnswered = 1.0f - ratioAnswered;
    currentDegree = ratioNotAnswered * fullDegree;
    CAShapeLayer *circleLayer1 = [CAShapeLayer layer];
    UIBezierPath *bPath1 = [UIBezierPath bezierPath];
    [bPath1 moveToPoint:CGPointMake(radius, radius)];
    [bPath1 addLineToPoint:CGPointMake(self->circle.frame.size.height, radius)];
    [bPath1 addArcWithCenter:CGPointMake(radius, radius)
                     radius:radius
                 startAngle:0
                   endAngle:DEGREES_TO_RADIANS(currentDegree)
                  clockwise:YES];
    CGPoint lastArcEndPoint = bPath1.currentPoint;
    [bPath1 addLineToPoint:CGPointMake(radius, radius)];
    circleLayer1.path = bPath1.CGPath;
    circleLayer1.fillColor = [styleGuide getColor:ButtonBorderColor].CGColor;
    [self->circle.layer addSublayer:circleLayer1];
    // Part answered / correct
    CAShapeLayer *circleLayer2 = [CAShapeLayer layer];
    UIBezierPath *bPath2 = [UIBezierPath bezierPath];
    CGFloat nextDegree = currentDegree + (ratioAnswered * fullDegree * ratioCorrect);
    [bPath2 moveToPoint:lastArcEndPoint];
    [bPath2 addArcWithCenter:CGPointMake(radius, radius)
                      radius:radius
                  startAngle:DEGREES_TO_RADIANS(currentDegree)
                    endAngle:DEGREES_TO_RADIANS(nextDegree)
                   clockwise:YES];
    CGPoint startPointAnsweredQuestions = lastArcEndPoint;
    lastArcEndPoint = bPath2.currentPoint;
    CGFloat startAngleAnsweredQuestions = currentDegree;
    currentDegree = nextDegree;
    [bPath2 addLineToPoint:CGPointMake(radius, radius)];
    circleLayer2.path = bPath2.CGPath;
    circleLayer2.fillColor = [styleGuide getColor:AnswerCorrect].CGColor;
    [self->circle.layer addSublayer:circleLayer2];
    // Part answered / not correct
    CAShapeLayer *circleLayer3 = [CAShapeLayer layer];
    UIBezierPath *bPath3 = [UIBezierPath bezierPath];
    nextDegree = currentDegree + (ratioAnswered * fullDegree * (1.0 - ratioCorrect));
    [bPath3 moveToPoint:lastArcEndPoint];
    [bPath3 addArcWithCenter:CGPointMake(radius, radius)
                      radius:radius
                  startAngle:DEGREES_TO_RADIANS(currentDegree)
                    endAngle:DEGREES_TO_RADIANS(nextDegree)
                   clockwise:YES];
    [bPath3 addLineToPoint:CGPointMake(radius, radius)];
    circleLayer3.path = bPath3.CGPath;
    circleLayer3.fillColor = [styleGuide getColor:AnswerWrong].CGColor;
    [self->circle.layer addSublayer:circleLayer3];
    //
    CAShapeLayer *circleLayer4 = [CAShapeLayer layer];
    UIBezierPath *bPath4 = [UIBezierPath bezierPath];
    [bPath4 moveToPoint:startPointAnsweredQuestions];
    [bPath4 addArcWithCenter:CGPointMake(radius, radius)
                      radius:radius
                  startAngle:DEGREES_TO_RADIANS(startAngleAnsweredQuestions)
                    endAngle:DEGREES_TO_RADIANS(nextDegree)
                   clockwise:YES];
    circleLayer4.path = bPath4.CGPath;
    circleLayer4.lineWidth = lineWidth;
    circleLayer4.fillColor = [styleGuide getColor:ClearColor].CGColor;
    circleLayer4.strokeColor = [styleGuide getColor:ButtonSelectedColor].CGColor;
    [self->circle.layer addSublayer:circleLayer4];
}

-(void)setupLegend {
    const CGRect frameCircle = self->circle.frame;
    const CGFloat space = 15.0f;
    const CGFloat xPos = frameCircle.origin.x + frameCircle.size.width + space;
    const CGFloat initalYPos = frameCircle.origin.y;
    const CGFloat initialWidth = self.view.frame.size.width - xPos -space;
    const CGFloat initialHeight = frameCircle.size.height;
    const CGRect initialFrame = CGRectMake(xPos, initalYPos, initialWidth, initialHeight);
    self->legend = [[UIView alloc]initWithFrame:initialFrame];
    // columns and rows
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    // row 1
    NSString *labelText = NSLocalizedString(@"CatalogStatisticLegendAnswered", nil);;
    UIColor *color = [styleGuide getColor:ButtonSelectedColor];
    [self addRowWithWidth:initialWidth textforLabel:labelText andColor:color];
    // row 2
    labelText = NSLocalizedString(@"CatalogStatisticLegendCorrect", nil);;
    color = [styleGuide getColor:AnswerCorrect];
    [self addRowWithWidth:initialWidth textforLabel:labelText andColor:color];
    // row 3
    labelText = NSLocalizedString(@"CatalogStatisticLegendIncorrect", nil);;
    color = [styleGuide getColor:AnswerWrong];
    [self addRowWithWidth:initialWidth textforLabel:labelText andColor:color];
    // row 4
    labelText = NSLocalizedString(@"CatalogStatisticLegendNeverAnswered", nil);;
    color = [styleGuide getColor:ButtonBorderColor];
    [self addRowWithWidth:initialWidth textforLabel:labelText andColor:color];
    
    CGFloat currentYPos = 0.0f;
    for (UIView *row in [self->legend subviews]) {
        [row sizeToFit];
        [LayFrame setYPos:currentYPos toView:row];
        currentYPos += row.frame.size.height + space;
    }
    
    [LayFrame setHeightWith:currentYPos toView:self->legend animated:NO];
    // center vertical
    const CGFloat newYPos = frameCircle.origin.y + (frameCircle.size.height - currentYPos) / 2.0f;
    [LayFrame setYPos:newYPos toView:self->legend];
    
    [self.view addSubview:self->legend];
    
}

-(void)addRowWithWidth:(CGFloat)width textforLabel:(NSString*)text andColor:(UIColor*)color {
    LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
    const CGFloat space = 10.0f;
    const CGSize sizeOfColorIndicators = CGSizeMake(10.0f, 10.0f);
    const CGRect frameColorIndicators = CGRectMake(0.0f, 0.0f, sizeOfColorIndicators.width, sizeOfColorIndicators.height);
    const CGFloat widthLabel = width - sizeOfColorIndicators.width - space;
    const CGFloat xPosLabel = sizeOfColorIndicators.width + space;
    const CGRect labelRect = CGRectMake(xPosLabel, 0.0f, widthLabel, 0.0f);
    const CGRect rowRect = CGRectMake(0.0f, 0.0f, width, 0.0f);
    const NSUInteger TAG_COLUMN = 100;
    const NSUInteger TAG_LABEL = 100;
    // row 1
    UIView *columnColorIndicator = [[UIView alloc]initWithFrame:frameColorIndicators];
    columnColorIndicator.backgroundColor = color;
    UILabel *label = [[UILabel alloc]initWithFrame:labelRect];
    label.backgroundColor = [UIColor clearColor];
    label.text = text;
    label.font = [styleGuide getFont:LabelFont];
    [label sizeToFit];
    columnColorIndicator.tag = TAG_COLUMN;
    label.tag = TAG_LABEL;
    UIView *row = [[UIView alloc]initWithFrame:rowRect];
    [row addSubview:columnColorIndicator];
    [row addSubview:label];
    [self->legend addSubview:row];
}

-(void)animateCircleTapping {
    CABasicAnimation *animation = [CABasicAnimation
                                   animationWithKeyPath:@"transform"];
    CATransform3D scaleMatrix = CATransform3DMakeScale(0.9f, 0.9f, 1.0f);
    CATransform3D identMatrix = CATransform3DIdentity;
    NSValue *scaleMatrixNsValue = [NSValue valueWithCATransform3D:scaleMatrix];
    NSValue *identMatrixNsValue = [NSValue valueWithCATransform3D:identMatrix];
    [animation setFromValue:identMatrixNsValue];
    [animation setToValue:scaleMatrixNsValue];
    [animation setDuration:0.1f];
    CALayer *buttonLayer = self->circle.layer;
    // Start the animation
    [CATransaction begin];
    [buttonLayer addAnimation:animation forKey:@"scaleDown"];
    [CATransaction commit];
}


//
// Action handlers
//
-(void)circlePressed {
    if(self.delegate) {
        [self animateCircleTapping];
        [self.delegate circlePressed];
    }
}

@end


