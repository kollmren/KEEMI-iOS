//
//  Catalog+Utilities.m
//  LayCore
//
//  Created by Rene Kollmorgen on 22.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "Catalog+Utilities.h"

#import "LayDataStoreUtilities.h"

#import "LayAppNotifications.h"

#import "LayMediaTypes.h"
#import "Media+Utilities.h"
#import "Thumbnail.h"
#import "Author.h"
#import "Question.h"
#import "Publisher.h"
#import "Explanation.h"
#import "Topic+Utilities.h"
#import "Resource+Utilities.h"
#import "Section+Utilities.h"
#import "About+Utilities.h"

#import "LayUserDataStore.h"
#import "UGCCatalog+Utilities.h"
#import "UGCResource.h"

#import "MWLogging.h"

@implementation Catalog (Utilities)

-(UIImage*)coverImage {
    Media* media = (Media*)self.coverRef;
    NSData* data = media.data;
    UIImage *coverImage_ = [UIImage imageWithData:data];
    return coverImage_;
}

-(void)setCoverImage:(NSData*)coverImage withType:(LayMediaFormat)format {
    if(coverImage) {
        NSManagedObjectContext* context = self.managedObjectContext;
        Media *coverRef = [LayDataStoreUtilities insertDomainObject: LayMedia :context];
        NSURL* catalogIDAsUrl = [[self objectID] URIRepresentation];
        coverRef.catalogID = [catalogIDAsUrl path];
        [coverRef setMediaType:LAY_MEDIA_IMAGE];
        [coverRef setMediaFormat:format];
        coverRef.data = coverImage;
        coverRef.name = @"cover";
        self.coverRef = coverRef;
    }
}

-(NSString*)author {
    return self.authorRef.name;
}

-(void)setAuthorInfo:(NSString *)name_ andEmail:(NSString*)email {
    NSManagedObjectContext* context = self.managedObjectContext;
    Author *author = [LayDataStoreUtilities insertDomainObject: LayAuthor :context];
    author.name = name_;
    author.emailAuthor = email;
    self.authorRef = author;
}

-(NSString*)publisher {
    return self.publisherRef.name;
}

-(NSString*)publisherWebsite {
    return self.publisherRef.website;
}

-(NSString*)publisherEmail {
    return self.publisherRef.emailPublisher;
}

-(void)setPublisher:(NSString *)publisherName {
    NSManagedObjectContext* context = self.managedObjectContext;
    Publisher *publisher = [LayDataStoreUtilities insertDomainObject: LayPublisher :context];
    publisher.name = publisherName;
    self.publisherRef = publisher;
}

-(void)setPublisherWebsite:(NSString*)link {
    if(self.publisherRef) {
        self.publisherRef.website = link;
    }
}

-(void)setPublisherEmail:(NSString*)email {
    if(self.publisherRef) {
        self.publisherRef.emailPublisher = email;
    }
}

-(UIImage*)publisherLogo {
    Media* media = self.publisherRef.logoPublisher;
    NSData* data = media.data;
    UIImage *logoImage_ = [UIImage imageWithData:data];
    return logoImage_;
}

-(void)setPublisherLogo:(NSData*)logo withType:(LayMediaFormat)format {
    if(logo) {
        NSManagedObjectContext* context = self.managedObjectContext;
        Media *logoRef = [LayDataStoreUtilities insertDomainObject: LayMedia :context];
        [logoRef setMediaType:LAY_MEDIA_IMAGE];
        [logoRef setMediaFormat:format];
        logoRef.data = logo;
        logoRef.name = @"logo";
        NSURL* catalogIDAsUrl = [[self objectID] URIRepresentation];
        logoRef.catalogID = [catalogIDAsUrl path];
        self.publisherRef.logoPublisher = logoRef;
    }
}

-(Question*)questionInstance {
    NSManagedObjectContext* context = self.managedObjectContext;
    Question *question = [LayDataStoreUtilities insertDomainObject: LayQuestion :context];
    question.catalogRef = self;
    return question;
}

-(Question*)questionByName:(NSString*)name {
    Question *retQuestion = nil;
    for (Question *question in self.questionRef) {
        if([question.name isEqualToString:name]) {
            retQuestion = question;
            break;
        }
    }
    return retQuestion;
}

-(void)addQuestion:(Question*)question_ {
    [self addQuestionRefObject:question_];
}

-(Media*)mediaInstance {
    NSManagedObjectContext* context = self.managedObjectContext;
    Media *media = [LayDataStoreUtilities insertDomainObject: LayMedia :context];
    NSURL* catalogIDAsUrl = [[self objectID] URIRepresentation];
    media.catalogID = [catalogIDAsUrl path];
    return media;
}

-(Media*)mediaByName:(NSString*)name {
    Media* mediaItem = [LayDataStoreUtilities findMediaInCatalog:self byName:name inContext:self.managedObjectContext];
    return mediaItem;
}

-(Thumbnail*)thumbnailByName:(NSString*)name {
    Thumbnail* thumbnail = [LayDataStoreUtilities findThumbnailInCatalog:self byName:name inContext:self.managedObjectContext];
    return thumbnail;
}

-(BOOL)hasExplanations {
    BOOL hasExplanations = NO;
    if([self.explanationRef count] > 0) {
        hasExplanations = YES;
    }
    return hasExplanations;
}

-(Explanation*)explanationInstance {
    Explanation *explanation = [LayDataStoreUtilities insertDomainObject: LayExplanation :self.managedObjectContext];
    [self addExplanationRefObject:explanation];
    return explanation;
}

-(Explanation*)explanationByName:(NSString*)name {
    Explanation *foundExplanation = nil;
    for (Explanation *explanation in self.explanationRef) {
        if([explanation.name isEqualToString:name]) {
            foundExplanation = explanation;
            break;
        }
    }
    return foundExplanation;
}

-(NSArray*)explanationListSortedByNumber {
    NSMutableArray* sortedExplanationList = [[NSMutableArray alloc]initWithCapacity:[self.explanationRef count]];
    for (Explanation* e in self.explanationRef) {
        [sortedExplanationList addObject:e];
    }
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"number"
                            ascending:YES];
    [sortedExplanationList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    
    return sortedExplanationList;
}

-(NSArray*) questionListSortedByNumber {
    NSMutableArray* sortedQuestionList = [[NSMutableArray alloc]initWithCapacity:[self.questionRef count]];
    for (Question* q in self.questionRef) {
        [sortedQuestionList addObject:q];
    }
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"number"
                            ascending:YES];
    [sortedQuestionList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    
    return sortedQuestionList;
}

-(NSUInteger)numberOfQuestions {
    return [self.questionRef count];
}

-(BOOL)containsQuestionWithName:(NSString*)name {
    BOOL containsQuestion = NO;
    for (Question *question in self.questionRef) {
        if([question.name isEqualToString:name]) {
            if(containsQuestion) {
                MWLogError([Catalog class], @"Upps more than one question with name:%@ in store!", name);
            }
            containsQuestion = YES;
        }
    }
    return containsQuestion;
}

-(BOOL)deleteCatalog {
    BOOL deletedCatalog = NO;
    [self.managedObjectContext deleteObject:self];
    NSError *error = nil;
    deletedCatalog = [self.managedObjectContext save:&error];
    if(!deletedCatalog && error) {
        MWLogError([Catalog class],@"Could not delete:%@! Details:code(%u),message(%@)", self.title, error.domain, [error.userInfo description] );
    }
    return deletedCatalog;
}

-(BOOL)hasTopics {
    BOOL hasTopics = NO;
    if([self.topicRef count]>1) {
        hasTopics = YES;
    }
    return hasTopics;
}

-(BOOL)hasTopicsWithQuestions {
    BOOL hasTopicsWithQuestions = NO;
    for (Topic *topic in [self topicList]) {
        if(![topic isDefaultTopic] && [topic numberOfQuestions]>0) {
            hasTopicsWithQuestions = YES;
            break;
        }
    }
    return hasTopicsWithQuestions;
}

-(BOOL)hasMoreThanOneTopicsWithQuestions {
    BOOL hasTopicsWithQuestions = NO;
    NSInteger topicCouner = 0;
    for (Topic *topic in [self topicList]) {
        if(![topic isDefaultTopic] && [topic numberOfQuestions]>0) {
            topicCouner++;
        }
    }
    if(topicCouner > 1) {
        hasTopicsWithQuestions = YES;
    }
    return hasTopicsWithQuestions;
}

-(BOOL)hasTopicsWithExplanations {
    BOOL hasTopicsWithExplanations = NO;
    for (Topic *topic in [self topicList]) {
        if(![topic isDefaultTopic] && [topic numberOfExplanations]>0) {
            hasTopicsWithExplanations = YES;
            break;
        }
    }
    return hasTopicsWithExplanations;
}

-(NSUInteger)numberOfExplanations {
    return [self.explanationRef count];
}

-(NSArray*)topicList {
    NSMutableArray* sortedTopicList = [[NSMutableArray alloc]initWithCapacity:[self.topicRef count]];
    for (Topic* t in self.topicRef) {
        [sortedTopicList addObject:t];
    }
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"number"
                            ascending:YES];
    [sortedTopicList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    
    return sortedTopicList;
}

-(NSArray *)topicListQuestions {
    NSMutableArray* sortedTopicList = [[NSMutableArray alloc]initWithCapacity:[self.topicRef count]];
    for (Topic* t in self.topicRef) {
        if([t hasQuestions]) {
            [sortedTopicList addObject:t];
        }
    }
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"number"
                            ascending:YES];
    [sortedTopicList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    
    return sortedTopicList;
}

-(Topic*)topicInstanceByName:(NSString*)name {
    Topic *topic = nil;
    for (Topic *t in self.topicRef) {
        if([t.name isEqualToString:name]) {
            topic = t;
        }
    }
    return topic;
}

-(Topic*)topicInstance {
    NSManagedObjectContext* context = self.managedObjectContext;
    Topic *topic = [LayDataStoreUtilities insertDomainObject: LayTopic :context];
    [self addTopicRefObject:topic];
    return topic;
}

-(void)saveWhichTopicsTheUserSelected {
    NSError *error = nil;
    BOOL saved = [self.managedObjectContext save:&error];
    if(!saved) {
        MWLogError([Topic class], @"Could not save which topics the user selected! Details:%@", [error description]);
    }
}

-(void)discardStateOfNewSelectedTopics {
    [self.managedObjectContext rollback];
}

-(void)deleteExplanation:(Explanation*)explanation {
     [self.managedObjectContext deleteObject:explanation];
}

-(void)deleteTopic:(Topic*)topic {
   [self.managedObjectContext deleteObject:topic];
}

-(NSArray*)resourceList {
    NSMutableArray* sortedTopicList = [[NSMutableArray alloc]initWithCapacity:[self.resourceRef count]];
    for (Resource* t in self.resourceRef) {
        [sortedTopicList addObject:t];
    }
    NSSortDescriptor *sd = [NSSortDescriptor
                            sortDescriptorWithKey:@"number"
                            ascending:YES];
    [sortedTopicList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    
    NSArray *ugcResourceList = [self ugcResourceList];
    [sortedTopicList addObjectsFromArray:ugcResourceList];
    
    return sortedTopicList;
}

-(NSArray*)ugcResourceList {
    LayUserDataStore *userDataStore = [LayUserDataStore store];
    UGCCatalog *uCatalog = [userDataStore findCatalogByTitle:self.title andPublisher:[self publisher]];
    NSMutableArray* sortedList = [[NSMutableArray alloc]initWithCapacity:[self.resourceRef count]];
    if(uCatalog) {
        for (UGCResource* t in uCatalog.resourceRef) {
            [sortedList addObject:t];
        }
        NSSortDescriptor *sd = [NSSortDescriptor
                                sortDescriptorWithKey:@"created"
                                ascending:YES];
        [sortedList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    }
    return sortedList;
}

-(Resource*)resourceInstance {
    Resource *resource = [LayDataStoreUtilities insertDomainObject: LayResource :self.managedObjectContext];
    [self addResourceRefObject:resource];
    return resource;
}

-(Resource*)resourceByName:(NSString*)name {
    Resource *foundResource = nil;
    for (Resource *resource in self.resourceRef) {
        if([resource.name isEqualToString:name]) {
            foundResource = resource;
            break;
        }
    }
    return foundResource;
}

-(BOOL)hasResources {
    BOOL hasResources = NO;
    if([self.resourceRef count] > 0) {
        hasResources = YES;
    }
    return hasResources;
}

-(Section*)sectionInstance {
    NSManagedObjectContext* context = self.managedObjectContext;
    Section *section = [LayDataStoreUtilities insertDomainObject: LaySection :context];
    return section;
}

-(NSArray*)noteList {
    LayUserDataStore *userDataStore = [LayUserDataStore store];
    UGCCatalog *uCatalog = [userDataStore findCatalogByTitle:self.title andPublisher:[self publisher]];
    NSMutableArray* sortedList = [[NSMutableArray alloc]initWithCapacity:[self.resourceRef count]];
    if(uCatalog) {
        for (UGCNote* note in uCatalog.noteRef) {
            [sortedList addObject:note];
        }
        NSSortDescriptor *sd = [NSSortDescriptor
                                sortDescriptorWithKey:@"created"
                                ascending:YES];
        [sortedList sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    }
    return sortedList;
}

-(NSUInteger)numberOfFavourites {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Question"
                                              inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"catalogRef = %@  AND favourite = %@",
                              self, [NSNumber numberWithBool:YES]];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSUInteger numberOfFavourites = [[self managedObjectContext] countForFetchRequest:fetchRequest error:&error];
    if (numberOfFavourites == NSNotFound) {
        MWLogError([Catalog class], @"Failure executing fetch:%@", [error description]);
    }
    return numberOfFavourites;
}

-(About*)aboutInstance {
    About *about = [LayDataStoreUtilities insertDomainObject: LayAbout :self.managedObjectContext];
    self.aboutRef = about;
    return about;
}

-(NSArray*)listOfMediaImages {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Media"
                                              inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"catalogID = %@ and type = %u",
                              self, LAY_MEDIA_IMAGE ];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        MWLogError([Catalog class], @"Failure executing fetch:%@", [error description]);
    }
    return fetchedObjects;
}

@end

