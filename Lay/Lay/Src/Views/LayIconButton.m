//
//  LayButton.m
//  Lay
//
//  Created by Rene Kollmorgen on 21.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayIconButton.h"
#import "LayImage.h"
#import "MWLogging.h"
#import "LayStyleGuide.h"

@implementation LayIconButton

static const NSInteger g_LAY_TEXT_BUTTON_IDENTIFIER = 101;
static const NSInteger g_LAY_TEXT_BUTTON_LABEL_IDENTIFIER = 102;
static const NSInteger g_LAY_BUTTON_IMAGE_IDENTIFIER = 103;

+(UIButton*) buttonWithId:(LayButtonId)buttonIdentifier {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.showsTouchWhenHighlighted = YES;
    CGRect buttonFrame = button.frame;
    buttonFrame.size = [[LayStyleGuide instanceOf:nil] buttonSize];
    button.frame = buttonFrame;
    button.contentMode = UIViewContentModeCenter;
    UIImage *image = nil;
    switch(buttonIdentifier) {
        case LAY_BUTTON_ZOOM_OUT:
            image = [LayImage imageWithId:LAY_IMAGE_ZOOM_OUT];
            break;
        case LAY_BUTTON_RESOURCES:
            image = [LayImage imageWithId:LAY_IMAGE_RESOURCES];
            break;
        case LAY_BUTTON_RESOURCES_SELECTED:
            image = [LayImage imageWithId:LAY_IMAGE_RESOURCES_SELECTED];
            break;
        case LAY_BUTTON_QUESTION:
            image = [LayImage imageWithId:LAY_IMAGE_QUESTION_BUBBLE];
            break;
        case LAY_BUTTON_LIST:
            image = [LayImage imageWithId:LAY_IMAGE_LIST];
            break;
        case LAY_BUTTON_LEARN:
            image = [LayImage imageWithId:LAY_IMAGE_LEARN];
            break;
        case LAY_BUTTON_TEXT: {
            CGRect labelFrame = button.frame;
            labelFrame.origin.y = 10; // HACK:The fucking label can no be centered with the center property!!!
            UILabel *label = [[UILabel alloc]initWithFrame:labelFrame];
            UIFont *font = [UIFont systemFontOfSize:16.0f];
            label.font = font;
            label.tag = g_LAY_TEXT_BUTTON_LABEL_IDENTIFIER;
            //label.center = CGPointMake(button.frame.size.width / 2, button.frame.size.height / 2);
            button.tag = g_LAY_TEXT_BUTTON_IDENTIFIER;
            [button addSubview:label];
            break;
        }
        case LAY_BUTTON_CANCEL:
            image = [LayImage imageWithId:LAY_IMAGE_CANCEL];
            break;
            
        case LAY_BUTTON_NEXT:
            image = [LayImage imageWithId:LAY_IMAGE_QUESTION_NAV_FORWARD];
            break;
        case LAY_BUTTON_PREVIOUS:
            image = [LayImage imageWithId:LAY_IMAGE_QUESTION_NAV_BACK];
            break;
        case LAY_BUTTON_ARROW_NORTH:
            image = [LayImage imageWithId:LAY_IMAGE_ARROW_NORTH];
            break;
        case LAY_BUTTON_ARROW_WEST:
            image = [LayImage imageWithId:LAY_IMAGE_NAV_BACK];
            break;
        case LAY_BUTTON_ARROW_EAST:
            image = [LayImage imageWithId:LAY_IMAGE_NAV_FORWARD];
            break;
        case LAY_BUTTON_INFO:
            image = [LayImage imageWithId:LAY_IMAGE_INFO];
            break;
        case LAY_BUTTON_TOOLS:
            image = [LayImage imageWithId:LAY_IMAGE_TOOLBAR_TOOLS];
            break;
        case LAY_BUTTON_DONE:
            image = [LayImage imageWithId:LAY_IMAGE_DONE];
            break;
        case LAY_BUTTON_BACK:
            image = [LayImage imageWithId:LAY_IMAGE_QUESTION_NAV_BACK];
            break;
        case LAY_BUTTON_SEARCH:
            image = [LayImage imageWithId:LAY_IMAGE_SEARCH];
            break;
        case LAY_BUTTON_FAVOURITES:
            image = [LayImage imageWithId:LAY_IMAGE_FAVOURITES];
            break;
        case LAY_BUTTON_FAVOURITES_SELECTED:
            image = [LayImage imageWithId:LAY_IMAGE_FAVOURITES_SELECTED];
            break;
        case LAY_BUTTON_NOTES:
            image = [LayImage imageWithId:LAY_IMAGE_NOTES];
            break;
        case LAY_BUTTON_NOTES_SELECTED:
            image = [LayImage imageWithId:LAY_IMAGE_NOTES_SELECTED];
            break;

        default:
            button.backgroundColor = [UIColor redColor];
            button.titleLabel.text = @"???";
            MWLogError([LayIconButton class], @"Unknown type:(%d) of LayButton!", buttonIdentifier);
            break;
    }
    
    if(image) {
        UIImageView* imageView = [[UIImageView alloc]initWithImage:image];
        imageView.tag = g_LAY_BUTTON_IMAGE_IDENTIFIER;
        CGRect imageViewFrame = imageView.frame;
        imageViewFrame.size = [[LayStyleGuide instanceOf:nil] buttonSize];
        imageView.frame = imageViewFrame;
        imageView.contentMode = UIViewContentModeCenter;
        [button addSubview:imageView];
    }
    
    return button;
}

+(void)setContentMode:(UIViewContentMode)contentMode to:(UIButton*)layIconButton {
    UIImageView* imageView = (UIImageView* )[layIconButton viewWithTag:g_LAY_BUTTON_IMAGE_IDENTIFIER];
    if(imageView) {
        imageView.contentMode = contentMode;
    }
}

@end


//
// UIButton (Additions)
//
@implementation UIButton (Additions)

-(void)setText:(NSString*)text {
    if(self.tag==g_LAY_TEXT_BUTTON_IDENTIFIER) {
        UIView* subview = [self viewWithTag:g_LAY_TEXT_BUTTON_LABEL_IDENTIFIER];
        if([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = ((UILabel*)subview);
            label.text = text;
            [label sizeToFit];
        } else {
            MWLogError([LayIconButton class], @"Expected an UILabel with tag:%d as subview!", g_LAY_TEXT_BUTTON_LABEL_IDENTIFIER);
        }
        
    } else {
        MWLogWarning([LayIconButton class], @"Method setText can not be applied for this button! Tag is not:%d", g_LAY_TEXT_BUTTON_IDENTIFIER);
    }
}

@end
