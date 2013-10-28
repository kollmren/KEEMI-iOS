#import <Foundation/Foundation.h>


@interface LayColorProgress : NSObject {
    UIView *_progress;
    UIView *_amount;

    int _amountQuestions;

    CGSize _size;
}

- (id) initWithView:(UIView*)view amountOfQuestions:(int)amountQuestions;

- (void)setCorrectAnswers:(int)amount;

- (void)setRanking:(float)ranking;

@end
