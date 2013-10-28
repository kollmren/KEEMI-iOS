//
//  MediaImageMap.h
//  
//
//  Created by Rene Kollmorgen on 28.10.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Media;

@interface MediaImageMap : NSManagedObject

@property (nonatomic, retain) NSString * catalogID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * positionX;
@property (nonatomic, retain) NSNumber * positionY;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * sessionString;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) Media *mediaRef;

@end
