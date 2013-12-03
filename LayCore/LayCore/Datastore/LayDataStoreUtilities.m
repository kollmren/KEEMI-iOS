//
//  LayDataStoreUtilities.m
//  LayCore
//
//  Created by Rene Kollmorgen on 06.12.12.
//  Copyright (c) 2012 Rene. All rights reserved.
//

#import "LayDataStoreUtilities.h"
#import "LayImageUtilities.h"

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"
#import "Media+Utilities.h"
#import "Explanation+Utilities.h"
#import "Thumbnail.h"

#import "MWLogging.h"

static Class g_classObj = nil;

@implementation LayDataStoreUtilities

+(void) initialize {
    g_classObj = [LayDataStoreUtilities class];
}

+(id) insertDomainObject:(LayModelObject)identifier : (NSManagedObjectContext *) managedObjectContext {
    id domainObject = nil;
    switch (identifier) {
        case LayCatalog:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"Catalog"
                                                         inManagedObjectContext:managedObjectContext];
            break;
        case LayAuthor:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"Author"
                                                         inManagedObjectContext:managedObjectContext];
            break;
        case LayQuestion:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"Question"
                                                         inManagedObjectContext:managedObjectContext];
            break;
        case LayMedia:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"Media"
                                                         inManagedObjectContext:managedObjectContext];
            break;
        case LayPublisher:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"Publisher"
                                                         inManagedObjectContext:managedObjectContext];
            break;
        case LayAnswer:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"Answer"
                                                         inManagedObjectContext:managedObjectContext];
            break;
        case LayAnswerItem:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"AnswerItem"
                                                         inManagedObjectContext:managedObjectContext];
            break;
        case LayAnswerMedia:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"AnswerMedia"
                                                         inManagedObjectContext:managedObjectContext];
            break;
        case LayExplanation:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"Explanation"
                                                         inManagedObjectContext:managedObjectContext];
            break;
        case LaySection:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"Section"
                                                         inManagedObjectContext:managedObjectContext];
            break;
        case LaySectionText:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"SectionText"
                                                         inManagedObjectContext:managedObjectContext];
            break;
        case LaySectionMedia:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"SectionMedia"
                                                         inManagedObjectContext:managedObjectContext];
            break;
        case LaySectionQuestion:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"SectionQuestion"
                                                         inManagedObjectContext:managedObjectContext];
            break;

        case LayTopic:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"Topic"
                                                         inManagedObjectContext:managedObjectContext];
            break;
        case LayResource:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"Resource"
                                                         inManagedObjectContext:managedObjectContext];
            break;
        case LayAbout:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"About"
                                                         inManagedObjectContext:managedObjectContext];
            break;
        case LayThumbnail:
            domainObject = [NSEntityDescription insertNewObjectForEntityForName:@"Thumbnail"
                                                         inManagedObjectContext:managedObjectContext];
            break;

        default:
            MWLogError(g_classObj, @"!!!! Identifier:%d has no mapping !!!!", identifier);
            ;            break;
    }
    return domainObject;
}

+(Media *)findMediaInCatalog:(Catalog*)catalog
                      byName:(NSString*)nameOfMedia
                   inContext:(NSManagedObjectContext*)managedObjectContext {
    Media *media = nil;
    const NSURL *catalogIDAsUrl = [[catalog objectID]URIRepresentation];
    const NSString* catalogIDAsString = [catalogIDAsUrl path];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Media"
                                              inManagedObjectContext:managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@ AND catalogID = %@",
                              nameOfMedia, catalogIDAsString];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        MWLogError(g_classObj, @"Failure executing fetch:%@", [error description]);
    } else if([fetchedObjects count] > 1) {
        media = [fetchedObjects objectAtIndex:0];
        MWLogWarning(g_classObj, @"There are two media-entries with the same name:%@ in the store!", nameOfMedia);
    } else if([fetchedObjects count] == 1){
        media = [fetchedObjects objectAtIndex:0];
    }
    return media;
}

+(Thumbnail *)findThumbnailInCatalog:(Catalog*)catalog
                      byName:(NSString*)nameOfThumbnail
                   inContext:(NSManagedObjectContext*)managedObjectContext {
    Thumbnail *thumbnail = nil;
    const NSURL *catalogIDAsUrl = [[catalog objectID]URIRepresentation];
    const NSString* catalogIDAsString = [catalogIDAsUrl path];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Thumbnail"
                                              inManagedObjectContext:managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@ AND catalogID = %@",
                              nameOfThumbnail, catalogIDAsString];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        MWLogError(g_classObj, @"Failure executing fetch:%@", [error description]);
    } else if([fetchedObjects count] > 1) {
        thumbnail = [fetchedObjects objectAtIndex:0];
        MWLogWarning(g_classObj, @"There are two thumbnail-entries with the same name:%@ in the store!", nameOfThumbnail);
    } else if([fetchedObjects count] == 1){
        thumbnail = [fetchedObjects objectAtIndex:0];
    }
    return thumbnail;
}

+(NSUInteger)createThumbnailsForImagesInCatalog:(Catalog*)catalog withStateDelegate:(id<LayImportProgressDelegate>)stateDelegate {
    MWLogInfo(g_classObj, @"Create thumbnails for images in catalog:%@", catalog.title);
    NSUInteger numberOfCreatedThumbnails = 0;
    NSUInteger numberOfQuestion = 0;
    if(stateDelegate) {
        [stateDelegate setMaxSteps:[catalog.questionRef count]];
    }
    for (Question* question in [catalog questionListSortedByNumber]) {
        numberOfQuestion++;
        NSArray *questionImageMediaList = [question imageMediaList];
        for (Media* mediaImage in questionImageMediaList) {
            Thumbnail *existingThumbnail = [LayDataStoreUtilities findThumbnailInCatalog:catalog byName:mediaImage.name inContext:catalog.managedObjectContext];
            if(existingThumbnail) {
                [existingThumbnail addQuestionRefObject:question];
            } else {
                Thumbnail *thumbnail = [LayDataStoreUtilities insertDomainObject:LayThumbnail :catalog.managedObjectContext];
                const NSURL *catalogIDAsUrl = [[catalog objectID]URIRepresentation];
                NSString* catalogIDAsString = [catalogIDAsUrl path];
                thumbnail.catalogID = catalogIDAsString;
                thumbnail.number = [NSNumber numberWithUnsignedInteger:++numberOfCreatedThumbnails];
                thumbnail.name = mediaImage.name;
                thumbnail.mediaRef = mediaImage; // !! An image which must not be scallled down to fit the thumbnail-size will only refer to the media-object
                [thumbnail addQuestionRefObject:question];
                BOOL mustBeThumbnailed = [LayImageUtilities mustBeThumbnaild:mediaImage.data];
                if(mustBeThumbnailed) {
                    MWLogDebug(g_classObj, @"Create thumbnail for image:%@", mediaImage.name);
                    LayImageMetaData *imgMetaData = [LayImageUtilities thumbnail:mediaImage.data];
                    if(imgMetaData) {
                        thumbnail.data = imgMetaData.data;
                        // The number is a catalog wide number
                        thumbnail.width = [NSNumber numberWithFloat:imgMetaData.width];
                        thumbnail.height = [NSNumber numberWithFloat:imgMetaData.height];
                    } else {
                        MWLogError(g_classObj, @"Could not create thumbnail for image:%@", mediaImage.name);
                    }
                }
            }
        } // for Media
        if(stateDelegate) {
            [stateDelegate setStep:numberOfQuestion];
        }
    } // for Questions
    
    MWLogDebug(g_classObj, @"%u thumbnails created for:%@", numberOfCreatedThumbnails, catalog.title);
    
    return numberOfCreatedThumbnails;
}

@end
