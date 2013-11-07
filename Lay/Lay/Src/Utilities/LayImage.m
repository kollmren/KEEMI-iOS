//
//  LayImage.m
//  Lay
//
//  Created by Rene Kollmorgen on 31.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayImage.h"
#import "MWLogging.h"

NSString *const LayIconResourcePath = @"Icons/";

@implementation LayImage

+(UIImage*) imageWithId:(LayImageId)imageIdentifier {
    UIImage *image = nil;
    switch(imageIdentifier) {
        case LAY_IMAGE_MAIL:
            image = [LayImage imageNamed:@"730-envelope-selected.png"];
            break;
        case LAY_PAGE_INDICATOR_ENABLED:
            image = [LayImage imageNamed:@"PageControlIndicatorEnabled.png"];
            break;
        case LAY_IMAGE_CANCEL:
            image = [LayImage imageNamed:@"x.png"];
            break;
        case LAY_IMAGE_FAVOURITES:
            image = [LayImage imageNamed:@"726-star.png"];
            break;
        case LAY_IMAGE_FAVOURITES_SELECTED:
            image = [LayImage imageNamed:@"726-star-selected.png"];
            break;
        case LAY_IMAGE_FAVOURITES_MINI:
            image = [LayImage imageNamed:@"726-star_mini.png"];
            break;
        case LAY_IMAGE_USER_MINI:
            image = [LayImage imageNamed:@"769-male_mini.png"];
            break;
        case LAY_IMAGE_NOTES:
            image = [LayImage imageNamed:@"830-pencil.png"];
            break;
        case LAY_IMAGE_NOTES_SELECTED:
            image = [LayImage imageNamed:@"830-pencil-selected.png"];
            break;
        case LAY_IMAGE_NOTES_MINI:
            image = [LayImage imageNamed:@"830-pencil_mini.png"];
            break;
        case LAY_IMAGE_DONE:
            image = [LayImage imageNamed:@"888-checkmark.png"];
            break;
        case LAY_IMAGE_INFO:
            image = [LayImage imageNamed:@"724-info.png"];
            break;
        case LAY_IMAGE_INFO_HINT:
            image = [LayImage imageNamed:@"724-info_hint.png"];
            break;
        case LAY_IMAGE_LIST:
            image = [LayImage imageNamed:@"854-list.png"];
            break;
        case LAY_IMAGE_FLAG:
            image = [LayImage imageNamed:@"769-male.png"];
            break;
        case LAY_IMAGE_WRONG:
            image = [LayImage imageNamed:@"x.png"];
            break;
        case LAY_IMAGE_QUESTION_BUBBLE:
            image = [LayImage imageNamed:@"739-question-selected.png"];
            break;
        case LAY_IMAGE_ZOOM_OUT:
            image = [LayImage imageNamed:@"737-zoom-out.png"];
            break;
        case LAY_IMAGE_QUERY:
            image = [LayImage imageNamed:@"739-question-selected.png"];
            break;
        case LAY_IMAGE_QUERY_MINI:
            image = [LayImage imageNamed:@"739-question_mini.png"];
            break;
        case LAY_IMAGE_LEARN:
            image = [LayImage imageNamed:@"808-documents-selected.png"];
            break;
        case LAY_IMAGE_LEARN_MINI:
            image = [LayImage imageNamed:@"808-documents_mini.png"];
            break;
        case LAY_IMAGE_CREDITS:
            image = [LayImage imageNamed:@"724-info-selected.png"];
            break;
        case LAY_IMAGE_RESOURCES:
            image = [LayImage imageNamed:@"721-bookmarks.png"];
            break;
        case LAY_IMAGE_RESOURCES_SELECTED:
            image = [LayImage imageNamed:@"721-bookmarks-selected.png"];
            break;
        case LAY_IMAGE_RESOURCES_MINI:
            image = [LayImage imageNamed:@"721-bookmarks_mini.png"];
            break;
        case LAY_IMAGE_STATISTICS:
            image = [LayImage imageNamed:@"249-piechart.png"];
            break;
        case LAY_IMAGE_QUESTION_NAV_FORWARD:
            image = [LayImage imageNamed:@"766-arrow-right.png"];
            break;
            
        case LAY_IMAGE_QUESTION_NAV_BACK:
            image = [LayImage imageNamed:@"765-arrow-left.png"];
            break;
        case LAY_IMAGE_ARROW_NORTH:
            image = [LayImage imageNamed:@"03-arrow-north.png"];
            break;
        case LAY_IMAGE_NAV_BACK:
            image = [LayImage imageNamed:@"09-arrow-west.png"];
            break;
        case LAY_IMAGE_NAV_FORWARD:
            image = [LayImage imageNamed:@"02-arrow-east.png"];
            break;
        case LAY_IMAGE_SEARCH:
            image = [LayImage imageNamed:@"06-magnify.png"];
            break;
        case LAY_IMAGE_TOOLBAR_TOOLS:
            image = [LayImage imageNamed:@"769-male.png"];
            break;
        case LAY_IMAGE_ADD:
            image = [LayImage imageNamed:@"746-plus-circle.png"];
            break;
        case LAY_IMAGE_USER:
            image = [LayImage imageNamed:@"769-male.png"];
            break;
        case LAY_IMAGE_USER_SELECTED:
            image = [LayImage imageNamed:@"769-male-selected.png"];
            break;
        case LAY_IMAGE_UNPACK:
            image = [LayImage imageNamed:@"207-dropbox.png"];
            break;
        case LAY_IMAGE_IMPORT:
            image = [LayImage imageNamed:@"293-database.png"];
            break;
        default:
            break;
    }
    return image;
}

+(UIImage*) imageNamed:(NSString*) nameOfTheIcon {
    NSString *pathToIcon = [NSString stringWithFormat:@"%@%@", LayIconResourcePath, nameOfTheIcon];
    UIImage *icon = [UIImage imageNamed:pathToIcon];
    return icon;
}

@end
