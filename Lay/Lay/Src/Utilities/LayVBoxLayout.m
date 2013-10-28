//
//  LayVBoxLayout.m
//  Lay
//
//  Created by Rene Kollmorgen on 03.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayVBoxLayout.h"
#import "LayVBoxView.h"
#import "LayFrame.h"

#import "MWLogging.h"

@implementation LayVBoxLayout

+(CGFloat)layoutVBoxSubviewsInView:(UIView*)superView {
    CGFloat currentOffsetY = 0.0f;
    UIView<LayVBoxView> *layUiView = nil;
    for (UIView *subview in superView.subviews) {
        if([subview conformsToProtocol:@protocol(LayVBoxView)] && !subview.hidden) {
            layUiView = (UIView<LayVBoxView>*)subview;
            //NSInteger tag = layUiView.tag;
            // handle width (x-pos and width)
            [self adjustWidthOfVBoxView:layUiView toSuperView:superView];
            // handle y-Pos
            currentOffsetY += layUiView.spaceAbove;
            [LayFrame setYPos:currentOffsetY toView:layUiView];
            currentOffsetY += subview.frame.size.height;
        }
    }
    return currentOffsetY;
}

+(CGFloat)layoutVerticalSubviewsWithTagOrder:(NSUInteger*)tagList numberOfTags:(NSUInteger)numberOfTags inView:(UIView*)superView withSpace:(CGFloat)space {
    CGFloat currentOffsetY = 0.0f;
    for (NSUInteger tagIndex = 0; tagIndex < numberOfTags; ++tagIndex) {
        NSUInteger currentTag = tagList[tagIndex];
        UIView* subview = [superView viewWithTag:currentTag];
        if(subview) {
            if(tagIndex==0) {
                currentOffsetY = subview.frame.origin.y;
            }
            [LayFrame setYPos:currentOffsetY toView:subview];
            currentOffsetY += subview.frame.size.height + space;
        } else {
            MWLogWarning([LayVBoxLayout class], @"No subview with tag:%d found!", currentTag);
        }
    }
    return currentOffsetY;
}

+(CGFloat)layoutSubviewsOfView:(UIView*)superView withSpace:(CGFloat)space {
    CGFloat currentOffsetY = 0.0f;
    for (UIView *subview in superView.subviews) {
        if(!subview.hidden) {
            CGRect subViewFrame = subview.frame;
            // y-Pos
            subViewFrame.origin.y = currentOffsetY;
            subview.frame = subViewFrame;
            currentOffsetY += subview.frame.size.height + space;
        }
    }
    return currentOffsetY;
}

+(CGFloat)layoutSubviewsOfView:(UIView*)superView withSpace:(CGFloat)space andBorder:(CGFloat)border {
    CGFloat currentOffsetY = 0.0f;
    for (UIView *subview in superView.subviews) {
        if(!subview.hidden) {
            CGRect subViewFrame = subview.frame;
            // handle width
            CGFloat subViewWidth = superView.frame.size.width - 2 * border;
            subViewFrame.origin.x = border;
            subViewFrame.size.width = subViewWidth;
            // y-Pos
            subViewFrame.origin.y = currentOffsetY;
            subview.frame = subViewFrame;
            currentOffsetY += subview.frame.size.height + space;
        }
    }
    return currentOffsetY;
}

+(CGFloat)layoutSubviewsOfView:(UIView*)superView withSpace:(CGFloat)space andBorder:(CGFloat)border ignore:(NSInteger)tag {
    CGFloat currentOffsetY = 0.0f;
    for (UIView *subview in superView.subviews) {
        if(!subview.hidden && subview.tag!=tag) {
            CGRect subViewFrame = subview.frame;
            // handle width
            CGFloat subViewWidth = superView.frame.size.width - 2 * border;
            subViewFrame.origin.x = border;
            subViewFrame.size.width = subViewWidth;
            // y-Pos
            subViewFrame.origin.y = currentOffsetY;
            subview.frame = subViewFrame;
            currentOffsetY += subview.frame.size.height + space;
        }
    }
    return currentOffsetY;
}

+(CGFloat)neededHeightOfSubviewsOfView:(UIView*)superView {
    CGFloat neededHeight = 0.0f;
    CGFloat yPosHighest = 0.0;
    CGFloat heightHighest = 0.0;
    for (UIView *subview in superView.subviews) {
        if(subview.hidden) continue;
        CGFloat yPos = subview.frame.origin.y ;
        if(yPos > yPosHighest) {
            yPosHighest = yPos;
            CGFloat height = subview.frame.size.height;
            if(height > heightHighest) {
                heightHighest = height;
                neededHeight = yPosHighest + heightHighest;
            }
        }
    }
    return neededHeight;
}

+(void)setHeight:(CGFloat)newHeight forView:(UIView*)view {
    CGRect viewFrame = view.frame;
    viewFrame.size.height = newHeight;
    view.frame = viewFrame;
}

+(void)adjustWidthOfVBoxView:(UIView<LayVBoxView>*)layUiView toSuperView:(const UIView* const)view{
    CGFloat widthOfView = view.frame.size.width;
    CGFloat widthOfVBoxView = widthOfView - 2 * layUiView.border;
    CGRect layVBoxFrame = layUiView.frame;
    layVBoxFrame.origin.x = layUiView.border;
    if(!layUiView.keepWidth) {
        layVBoxFrame.size.width = widthOfVBoxView;
    }
    layUiView.frame = layVBoxFrame;
}

@end
