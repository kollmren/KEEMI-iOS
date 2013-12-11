//
//  LayAnswerViewOrder.m
//  KEEMI
//
//  Created by Rene Kollmorgen on 11.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayAnswerViewOrder.h"
#import "LayAnswerButton.h"
#import "LayStyleGuide.h"
#import "LayFrame.h"
#import "LayButton.h"
#import "LayImage.h"
#import "LayInfoDialog.h"

#import "Answer+Utilities.h"
#import "AnswerItem+Utilities.h"

#import "MWLogging.h"

//
// LayAnswerButtonCell
@interface LayAnswerButtonCell : UITableViewCell<LayAnswerButtonDelegate> {
    @public
    AnswerItem* answerItem;
    LayAnswerButton* answerButton;
    LayButton* explanationButton;
}

-(id)initWithAnswerItem:(AnswerItem*)answerItem andWidth:(CGFloat)width;

-(id)initWithExplanationButton:(LayButton*)button;

@end

//
// LayAnswerViewOrder
@implementation LayAnswerViewOrder

static Class g_classObj = nil;
static const NSInteger TAG_TABLE_VIEW = 1123;

#pragma mark - initialization
+(void) initialize {
    g_classObj = [LayAnswerViewOrder class];
}

-(void)dealloc {
    MWLogDebug(g_classObj, @"dealloc!");
}

#pragma mark - setup the view
-(void) setupViewWithSize:(CGSize)initialSize {
    [LayFrame setSizeWith:initialSize toView:self];
    UITableView *tblView = (UITableView*)[self viewWithTag:TAG_TABLE_VIEW];
    if( !tblView ) {
        const CGRect tableRect = CGRectMake(0.0f, 0.0f, initialSize.width, initialSize.height);
        UITableView *tblView = [[UITableView alloc]initWithFrame:tableRect style:UITableViewStylePlain];
        tblView.tag = TAG_TABLE_VIEW;
        tblView.editing = YES;
        tblView.contentInset = UIEdgeInsetsMake(70.0f, 0.0f, 0.0f, 0.0f);
        tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tblView.dataSource = self;
        tblView.delegate = self;
        [self addSubview:tblView];
    } else {
        [tblView reloadData];
    }
}

-(void)addButtonWithExplanationFor:(Answer*)answer_ {
    if([answer_ hasExplanation]) {
        LayStyleGuide *style = [LayStyleGuide instanceOf:nil];
        const CGFloat hSpace = 0.0f;//[style getHorizontalScreenSpace];
        CGFloat widthOfButton = self.frame.size.width - 2 * hSpace;
        const CGRect buttonRect = CGRectMake(hSpace, 0.0f, widthOfButton, [style maxHeightOfAnswerButton]);
        NSString *label = NSLocalizedString(@"QuestionSessionAnswerExplanation", nil);
        UIImage *iconImage = [LayImage imageWithId:LAY_IMAGE_INFO_HINT];
        LayMediaData *mediaData = [LayMediaData byUIImage:iconImage];
        LayButton *additionalInfoButton = [[LayButton alloc]initWithFrame:buttonRect label:label mediaData:mediaData font:[style getFont:NormalPreferredFont] andColor:[style getColor:ClearColor]];
        additionalInfoButton.showMediaWithBorder = NO;
        [additionalInfoButton fitToHeight];
        additionalInfoButton.topBottomLayer = YES;
        [additionalInfoButton addTarget:self action:@selector(showAddtionalInfoToAnswer) forControlEvents:UIControlEventTouchUpInside];
        LayAnswerButtonCell* explanationButtonCell = [[LayAnswerButtonCell alloc]initWithExplanationButton:additionalInfoButton];
        [self->answerItemColumnList insertObject:explanationButtonCell atIndex:0];
    }
}

#pragma mark - setup datasource
-(void) setupAnswerCellListWithAnswer:(Answer*)answer_ andSize:(CGSize)size {
    self->answer = answer_;
    NSArray* answerItemList = [self->answer answerItemListSessionOrderPreserved];
    self->answerItemColumnList = [NSMutableArray arrayWithCapacity:[answerItemList count]];
    for (AnswerItem *item in answerItemList) {
        LayAnswerButtonCell* answerButtonCell = [[LayAnswerButtonCell alloc]initWithAnswerItem:item andWidth:size.width];
        [self->answerItemColumnList addObject:answerButtonCell];
    }
}

#pragma mark - LayAnswerView impl
-(id<LayAnswerView>)initAnswerView {
    return [super initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
}

-(UIView*)answerView {
    return self;
}

-(CGSize)showAnswer:(Answer*)answer_ andSize:(CGSize)viewSize userCanSetAnswer:(BOOL)userCanSetAnswer {
    self->userSetAnswer = NO;
    self->userAnswerIsCorrect = NO;
    UITableView *tblView = (UITableView*)[self viewWithTag:TAG_TABLE_VIEW];
    if( tblView ) {
        tblView.editing = YES;
        if( [self->answer hasExplanation] ) {
            [self->answerItemColumnList removeObjectAtIndex:0];
            NSIndexPath *firstRow = [NSIndexPath indexPathForRow:0 inSection:0];
            [tblView deleteRowsAtIndexPaths:@[firstRow] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    
    [self setupAnswerCellListWithAnswer:answer_ andSize:viewSize];
    [self setupViewWithSize:viewSize];
    return viewSize;
}


-(void)showSolution {
    NSInteger itemPositionInOrderView = 1;
    BOOL userOrderCorrect = YES;
    for (LayAnswerButtonCell* answerButtonCell in self->answerItemColumnList) {
        AnswerItem* answerItem = answerButtonCell->answerItem;
        NSInteger correctPositionOfItem = [answerItem.number integerValue];
        [answerButtonCell->answerButton mark];
        if(correctPositionOfItem != itemPositionInOrderView ) {
            userOrderCorrect = NO;
            answerButtonCell->answerButton.showAsWrong = YES;
        }
        [answerButtonCell->answerButton showCorrectness];
        itemPositionInOrderView++;
        
        if([answerItem hasExplanation] || [answerItem hasMedia]) {
            answerButtonCell->answerButton.enabled = YES;
        }
    }
    if( userOrderCorrect ) {
        self->userAnswerIsCorrect = YES;
    }
    
    if([self->answer hasExplanation]) {
        [self addButtonWithExplanationFor:self->answer];
    }
    
    UITableView *tblView = (UITableView*)[self viewWithTag:TAG_TABLE_VIEW];
    if( tblView ) {
        tblView.editing = NO;
        [tblView reloadData];
    } else {
        MWLogError(g_classObj, @"Cound adjust view to show solution!");
    }
    
}

-(BOOL)userSetAnswer {
    return self->userSetAnswer;
}


-(BOOL)isUserAnswerCorrect {
    return self->userAnswerIsCorrect;
}

-(void)setDelegate:(id<LayAnswerViewDelegate>)delegate_ {
    self->delegate = delegate_;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self->answerItemColumnList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LayAnswerButtonCell* answerButtonCell = [self->answerItemColumnList objectAtIndex:[indexPath row]];
    return answerButtonCell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath {
    LayAnswerButtonCell* answerButtonCell = [self->answerItemColumnList objectAtIndex:[sourceIndexPath row]];
    [self->answerItemColumnList removeObjectAtIndex:[sourceIndexPath row]];
    [self->answerItemColumnList insertObject:answerButtonCell atIndex:[destinationIndexPath row]];
    self->userSetAnswer = YES;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LayAnswerButtonCell* answerButtonCell = [self->answerItemColumnList objectAtIndex:[indexPath row]];
    return answerButtonCell.frame.size.height;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    BOOL canPerformAction = YES;
    if(action == @selector(delete:)){
        canPerformAction = NO;
    }
    return canPerformAction;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

#pragma mark - Event handler
-(void) showAddtionalInfoToAnswer {
    if([self->answer hasExplanation]) {
        Explanation *explanation = [self->answer explanation];
        [self showExplanation:explanation];
    }
}

-(void)showExplanation:(Explanation*)explanation {
    LayInfoDialog *infoDlg = [[LayInfoDialog alloc]initWithWindow:self.window];
    [infoDlg showShortExplanation:explanation];
}

@end

//
// LayAnswerButtonCell
@implementation LayAnswerButtonCell

-(id)initWithAnswerItem:(AnswerItem*)answerItem_ andWidth:(CGFloat)width {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if( self ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self->answerItem = answerItem_;
        LayStyleGuide *styleGuide = [LayStyleGuide instanceOf:nil];
        const CGRect buttonRect = CGRectMake(0.0f, 0.0f, width, [styleGuide maxHeightOfAnswerButton]);
        self->answerButton = [[LayAnswerButton alloc]initWithFrame:buttonRect and:answerItem_];
        self->answerButton.answerButtonDelegate = self;
        self->answerButton.showMarkIndicator = NO;
        self->answerButton.showAsMarked = YES;
        self->answerButton.enabled = NO;
        [self addSubview:answerButton];
        [LayFrame setHeightWith:answerButton.frame.size.height toView:self animated:NO];
    } else {
        MWLogError([LayAnswerButtonCell class], @"Could not initialize cell!");
    }
    return self;
}

-(id)initWithExplanationButton:(LayButton*)button {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if( self ) {
        self->answerItem = nil;
        self->explanationButton = button;
        [self addSubview:button];
        [LayFrame setSizeWith:button.frame.size toView:self];
    } else {
        MWLogError([LayAnswerButtonCell class], @"Could not initialize cell (LayButton)!");
    }
    return self;
}

// AnswerButtonDelegate
-(void)tapped:(LayAnswerButton*)answerButton_ wasSelected:(BOOL)wasSelected {
    AnswerItem *item = answerButton_.answerItem;
    if([item hasExplanation]) {
        LayInfoDialog *infoDlg = [[LayInfoDialog alloc]initWithWindow:self.window];
        Explanation *explanation = [item explanation];
        [infoDlg showShortExplanation:explanation];
    }
}

// Is called when the button changed its size e.g. when the info-icon is shown.
-(void) resized {
    [LayFrame setHeightWith:answerButton.frame.size.height toView:self animated:NO];

}


@end
