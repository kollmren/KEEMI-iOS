//
//  LayButton.h
//  Lay
//
//  Created by Rene Kollmorgen on 21.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum LayButtonId_ {
    LAY_BUTTON_OPEN_STORE,
    LAY_BUTTON_SEARCH,
    LAY_BUTTON_FAVOURITES,
    LAY_BUTTON_FAVOURITES_SELECTED,
    LAY_BUTTON_NOTES,
    LAY_BUTTON_NOTES_SELECTED,
    LAY_BUTTON_SETTINGS,
    LAY_BUTTON_BACK,
    LAY_BUTTON_RESOURCES,
    LAY_BUTTON_RESOURCES_SELECTED,
    LAY_BUTTON_PREVIOUS,
    LAY_BUTTON_NEXT,
    LAY_BUTTON_DONE,
    LAY_BUTTON_ZOOM_OUT,
    LAY_BUTTON_QUESTION,
    LAY_BUTTON_LEARN,
    LAY_BUTTON_CANCEL,
    LAY_BUTTON_TEXT,
    LAY_BUTTON_CAMERA,
    LAY_BUTTON_TOOLS,
    LAY_BUTTON_INFO,
    LAY_BUTTON_LIST,
    LAY_BUTTON_ARROW_NORTH,
    LAY_BUTTON_ARROW_WEST,
    LAY_BUTTON_ARROW_EAST
} LayButtonId;



@interface LayIconButton : NSObject

+(UIButton*) buttonWithId:(LayButtonId)buttonIdentifier;

+(void)setContentMode:(UIViewContentMode)contentMode to:(UIButton*)layIconButton;

@end

@interface UIButton (Additions)

-(void)setText:(NSString*)text;

@end
