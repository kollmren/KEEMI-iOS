//
//  Catalog+Utilities.h
//  LayCore
//
//  Created by Rene Kollmorgen on 22.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Catalog.h"
#import "LayMediaTypes.h"

@class Media;
@class Explanation;
@class Topic;
@class Resource;
@class Section;
@class About;
@class Thumbnail;
@interface Catalog (Utilities)

-(UIImage*)coverImage;
-(void)setCoverImage:(NSData*)coverImage withType:(LayMediaFormat)format;

-(NSString*)author;
-(void)setAuthorInfo:(NSString *)name_ andEmail:(NSString*)email;

-(NSString*)publisher;
-(NSString*)publisherWebsite;
-(NSString*)publisherEmail;
-(void)setPublisher:(NSString*)publisher;
-(void)setPublisherWebsite:(NSString*)link;
-(void)setPublisherEmail:(NSString*)email;

-(UIImage*)publisherLogo;
-(void)setPublisherLogo:(NSData*)logo withType:(LayMediaFormat)format;

-(Question*)questionInstance;
-(Question*)questionByName:(NSString*)name;
-(void)addQuestion:(Question*)question;
-(NSArray*) questionListSortedByNumber;
-(NSUInteger)numberOfQuestions;
-(BOOL)containsQuestionWithName:(NSString*)name;

-(Media*)mediaInstance;
-(Media*)mediaByName:(NSString*)name;
-(Thumbnail*)thumbnailByName:(NSString*)name;

-(BOOL)hasExplanations;
-(Explanation*)explanationInstance;
-(Explanation*)explanationByName:(NSString*)name;
-(NSArray*)explanationListSortedByNumber;
-(NSUInteger)numberOfExplanations;

-(BOOL)hasTopics;
-(NSArray*)topicList;
-(NSArray *)topicListQuestions;
-(Topic*)topicInstanceByName:(NSString*)name;
-(Topic*)topicInstance;
-(void)saveWhichTopicsTheUserSelected;
-(void)discardStateOfNewSelectedTopics;

-(BOOL)hasTopicsWithQuestions;
-(BOOL)hasMoreThanOneTopicsWithQuestions;
-(BOOL)hasTopicsWithExplanations;

//-(BOOL)showInstruction;
-(BOOL)deleteCatalog;

-(void)deleteExplanation:(Explanation*)explanation;
-(void)deleteTopic:(Topic*)topic;

-(NSArray*)resourceList;
-(Resource*)resourceInstance;
-(Resource*)resourceByName:(NSString*)name;
-(BOOL)hasResources;

-(Section*)sectionInstance;

-(NSArray*)noteList;

-(NSUInteger)numberOfFavourites;

-(About*)aboutInstance;

-(NSArray*)listOfMediaImages;

@end

