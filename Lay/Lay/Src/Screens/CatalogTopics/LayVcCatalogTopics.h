//
//  LayVcImport.h
//  KEEMI
//
//  Created by Rene Kollmorgen on 13.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayVcNavigationBarDelegate.h"

typedef enum StartWithSelectedTopicMode_ {
    START_TOPIC_MODE_QUERY,
    START_TOPIC_MODE_EXPLANATION
    } StartWithSelectedTopicMode;

@interface LayVcCatalogTopics : UIViewController<LayVcNavigationBarDelegate>

-(id)initWithTopicList:(NSArray*)listOfTopics andMode:(StartWithSelectedTopicMode)mode;

@end
