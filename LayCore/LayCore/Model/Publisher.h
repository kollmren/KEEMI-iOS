//
//  Publisher.h
//  LayCore
//
//  Created by Rene Kollmorgen on 12.06.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Catalog, Media;

@interface Publisher : NSManagedObject

@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * descr;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *catalogRef;
@property (nonatomic, retain) Media *logoPublisher;
@property (nonatomic, retain) NSString * emailPublisher;

@end

@interface Publisher (CoreDataGeneratedAccessors)

- (void)addCatalogRefObject:(Catalog *)value;
- (void)removeCatalogRefObject:(Catalog *)value;
- (void)addCatalogRef:(NSSet *)values;
- (void)removeCatalogRef:(NSSet *)values;

@end
