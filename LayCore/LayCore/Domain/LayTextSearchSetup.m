//
//  LayTextSearchSetup.m
//  LayCore
//
//  Created by Rene Kollmorgen on 19.12.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayTextSearchSetup.h"
#import "LayTokenizer.h"
#import "LayDataStoreUtilities.h"

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"
#import "Answer+Utilities.h"
#import "AnswerItem+Utilities.h"
#import "Introduction+Utilities.h"
#import "Explanation+Utilities.h"
#import "Section+Utilities.h"
#import "SearchWord+Utilities.h"
#import "SearchWordRelation+Utilities.h"

#import "MWLogging.h"

@implementation LayTextSearchSetup

+(void)setupTextSearchForQuestion:(Question*)question {
    //
    // Prepare searchable text for the question
    //
    NSMutableString *textToPrepareForSearch = [NSMutableString stringWithString:question.question];
    if( question.title ) {
        [textToPrepareForSearch appendFormat:@" %@", question.title];
    }
    
    if(question.introRef) {
        Introduction *intro = question.introRef;
        if( intro.title ) {
            [textToPrepareForSearch appendFormat:@" %@",intro.title];
        }
        NSString* stringFromSections = [LayTextSearchSetup stringFromSectionSet:intro.sectionRef];
        [textToPrepareForSearch appendFormat:@" %@",stringFromSections];
    }
    
    Answer *answer = question.answerRef;
    for (AnswerItem *answerItem in answer.answerItemRef) {
        if(answerItem.text) {
            [textToPrepareForSearch appendFormat:@" %@",answerItem.text];
        }
    }
    
    //
    // Get or create SearchWord and SearchWordRelations for the catalog
    //
    Catalog* catalog = question.catalogRef;
    NSArray *searchWordRelationsForCatalog = [LayTextSearchSetup searchWordRelationsFrom:textToPrepareForSearch linkedWithCatalog:catalog];
    // Link the relations with the question
    for (SearchWordRelation *searchWordRelation in searchWordRelationsForCatalog) {
        [LayTextSearchSetup linkSearchWordRelation:searchWordRelation withManagedObject:question];
    }
}

+(void)setupTextSearchForExplanation:(Explanation*)explanation {
    //
    // Prepare searchable text for the explanation
    //
    NSMutableString *textToPrepareForSearch = nil;
    if(explanation.title) {
        textToPrepareForSearch = [NSMutableString stringWithString:explanation.title];
    } else {
        textToPrepareForSearch = [NSMutableString stringWithCapacity:200];
    }
    
    NSString *appendFormat = @" %@";
    NSArray *sectionList = [explanation sectionList];
    for (Section* section in sectionList) {
        if(section.title) {
            [textToPrepareForSearch appendFormat:appendFormat, section.title];
        }
        NSSet *sectionTextSet = section.sectionTextRef;
        for (SectionText* sectionText in sectionTextSet) {
            [textToPrepareForSearch appendFormat:appendFormat, sectionText.text];
        }
    }
    
    //
    // Get or create SearchWord and SearchWordRelations for the catalog
    //
    Catalog* catalog = explanation.catalogRef;
    NSArray *searchWordRelationsForCatalog = [LayTextSearchSetup searchWordRelationsFrom:textToPrepareForSearch linkedWithCatalog:catalog];
    // Link the relations with the explanation
    for (SearchWordRelation *searchWordRelation in searchWordRelationsForCatalog) {
        [LayTextSearchSetup linkSearchWordRelation:searchWordRelation withManagedObject:explanation];
    }
}

+(BOOL)linkSearchWordRelation:(SearchWordRelation*)searchWordRelation withManagedObject:(NSManagedObject*)managedObject {
    // Check if a relation exist for the question already
    BOOL linked = NO;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchWordRelation" inManagedObjectContext:managedObject.managedObjectContext];
    NSString *managedObjectContextText = nil;
    NSString *nameOfReferencedManagedObjectProperty = @"questionRef";
    if([managedObject isKindOfClass:[Explanation class]]) {
        managedObjectContextText = ((Explanation*)managedObject).name;
        nameOfReferencedManagedObjectProperty = @"explanationRef";
    } else {
        managedObjectContextText = ((Question*)managedObject).name;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF = %@ AND %K = %@", searchWordRelation,nameOfReferencedManagedObjectProperty, managedObject];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *searchWordRelationList = [managedObject.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if( !searchWordRelationList ) {
        MWLogError([LayTextSearchSetup class], @"Failure executing fetch:%@", [error description] );
    } else if([searchWordRelationList count] > 1) {
        MWLogError([LayTextSearchSetup class], @"Only one link can exist between a SearchWordRelation and a Question:%@!", managedObjectContextText);
    } else if( [searchWordRelationList count] == 0 ) {
        MWLogDebug([LayTextSearchSetup class], @"Link SearchWordRelation with question:%@!", managedObjectContextText);
        if([managedObject isKindOfClass:[Explanation class]]) {
            Explanation *explanation = (Explanation*)managedObject;
            [searchWordRelation addExplanationRefObject:explanation];
        } else {
            Question *question = (Question*)managedObject;
            [searchWordRelation addQuestionRefObject:question];
        }
        linked = YES;
    } /*else {
        // link already exists
    }*/
    
    return linked;
}

// Returns a list of SearchWordRelations linked with catalog.
+(NSArray*)searchWordRelationsFrom:(NSString*)text linkedWithCatalog:(Catalog*)catalog {
    NSMutableArray *searchWordRelationCatalogList = [NSMutableArray arrayWithCapacity:100];
    LayTokenizer *tokenizer = [LayTokenizer sharedTokenizer];
    NSSet *tokenSet = [tokenizer tokenize:text];
    for (NSString *word in tokenSet) {
        SearchWord *searchWord = [LayTextSearchSetup searchWordFor:word inManagedObjectContext:catalog.managedObjectContext];
        if(searchWord) {
            SearchWordRelation* searchWordRelation = [LayTextSearchSetup searchWordRelationListFor:searchWord inCatalog:catalog];
            [searchWordRelationCatalogList addObject:searchWordRelation];
        } else {
            MWLogError([LayTextSearchSetup class], @"No SearchWord object created!");
        }
    }
    return searchWordRelationCatalogList;
}

+(SearchWord*)searchWordFor:(NSString*)word inManagedObjectContext:(NSManagedObjectContext*)managedObjContext {
    SearchWord *searchWord = nil;
    // Check if the keyword exist already in the sore
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchWord" inManagedObjectContext:managedObjContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"word = %@",word];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *serachWordList = [managedObjContext executeFetchRequest:fetchRequest error:&error];
    if( !serachWordList ) {
        MWLogError([LayTextSearchSetup class], @"Failure executing fetch:%@", [error description] );
    } else if( [serachWordList count] > 1 ) {
        MWLogError([LayTextSearchSetup class], @"More than one searchWord:%@ in the list!", word );
         searchWord = [serachWordList objectAtIndex:0];
    } else if( [serachWordList count] == 0 ) {
        MWLogDebug([LayTextSearchSetup class], @"Create new SearchObject entry for word:%@!", word );
        searchWord = [LayDataStoreUtilities insertDomainObject:LaySearchWord :managedObjContext];
        searchWord.word = word;
    } else {
        searchWord = [serachWordList objectAtIndex:0];
    }
    
    return searchWord;
}

+(SearchWordRelation*)searchWordRelationListFor:(SearchWord*)searchWord inCatalog:(Catalog*)catalog {
    // Check if a relation exist for the catalog already
    SearchWordRelation *searchWordRelation = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchWordRelation" inManagedObjectContext:catalog.managedObjectContext];
    NSPredicate *predicateCatalog = [NSPredicate predicateWithFormat:@"catalogRef = %@", catalog];
    NSPredicate *predicateSearchWord = [NSPredicate predicateWithFormat:@"searchWordRef = %@", searchWord];
    NSPredicate *catalogAndSearchWord =  [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateCatalog, predicateSearchWord]];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:catalogAndSearchWord];
    NSError *error;
    NSArray *searchWordRelationList = [catalog.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if( !searchWordRelationList ) {
        MWLogError([LayTextSearchSetup class], @"Failure executing fetch:%@", [error description] );
    } else if( [searchWordRelationList count] > 1 ) {
        MWLogError([LayTextSearchSetup class], @"Only one link can exist between a SearchWord:%@ and a Catalog:%@!", searchWord.word, catalog.title );
    } else if( [searchWordRelationList count] == 0 ) {
        MWLogDebug([LayTextSearchSetup class], @"Create new SearchWordRelation entry for word:%@ with catalog:%@!", searchWord.word, catalog.title );
        searchWordRelation = [LayDataStoreUtilities insertDomainObject:LaySearchWordRelation :catalog.managedObjectContext];
        searchWordRelation.searchWordRef = searchWord;
        searchWordRelation.catalogRef = catalog;
    } else {
        searchWordRelation = [searchWordRelationList objectAtIndex:0];
    }
    
    return searchWordRelation;
}

+(NSString*)stringFromSectionSet:(NSSet*)sectionSet {
    NSMutableString *textFromSections = [NSMutableString stringWithCapacity:300];
    for (Section* section in sectionSet) {
        for (SectionText *sectionText in section.sectionTextRef) {
            if(sectionText.text) {
                [textFromSections appendFormat:@" %@",sectionText.text];
            }
        }
    }
    return textFromSections;
}

@end
