//
//  LayXmlDataFileReaderTests.m
//  LayCore
//
//  Created by Rene Kollmorgen on 06.05.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayXmlCatalogFileReaderTests.h"
#import "LayXmlCatalogFileReader.h"
#import "LayCoreTestConfig.h"
#import "LayMainDataStore.h"
#import "LayImportDataStore.h"
#import "LayCatalogImport.h"
#import "LayCatalogImportReport.h"
#import "LayError.h"
#import "LayConstants.h"
#import "Introduction+Utilities.h"

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"
#import "Answer+Utilities.h"
#import "AnswerItem+Utilities.h"
#import "Explanation+Utilities.h"
#import "Resource+Utilities.h"
#import "Media+Utilities.h"
#import "Topic+Utilities.h"
#import "Section+Utilities.h"
#import "About+Utilities.h"
#import "AnswerMedia.h"
#import "SectionQuestion.h"

#import "MWLogging.h"

@implementation LayXmlCatalogFileReaderTests

static Class _classObj = nil;

static NSString* titleOfTestCatalogCitizenship = @"Einbürgerungstest";

+(void)setUp {
    _classObj = [LayXmlCatalogFileReaderTests class];
    [LayCoreTestConfig configureTestDataStore];
}

-(void)tearDown {
    LayMainDataStore *mainStore = [LayMainDataStore store];
    XCTAssertTrue([mainStore deleteAllCatalogsFromStore]);
}

-(void)testInitWithXmlFile{
    MWLogNameOfTest(_classObj);
    NSURL* catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest];;
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    XCTAssertNotNil(xmlDataFileReader);
}

-(void)testInitWithZippedFile{
    MWLogNameOfTest(_classObj);
    NSURL* catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptestZipped];;
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithZippedFile:catalogFile];
    XCTAssertNotNil(xmlDataFileReader);
}

-(void)testInitWithXmlFileNotExistingFile{
    MWLogNameOfTest(_classObj);
    NSURL* catalogFile = [NSURL URLWithString:@"dir/notExistingFile.xml"];
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    XCTAssertNil(xmlDataFileReader);
}

-(void)testMetaInfo{
    MWLogNameOfTest(_classObj);
    NSURL* catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest];
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    XCTAssertNotNil(xmlDataFileReader);
    LayCatalogFileInfo *catalogInfo = [xmlDataFileReader metaInfo];
    XCTAssertNotNil(catalogInfo);
    NSString *titleOfCatalog = catalogInfo.catalogTitle;
    NSString *expectedTitleOfCatalog = titleOfTestCatalogCitizenship;
    XCTAssertEqualObjects(expectedTitleOfCatalog, titleOfCatalog);
    
    NSString *authorOfCatalog = [catalogInfo detailForKey:@"author"];
    NSString *expectedAuthorOfCatalog = @"Bundesamt für Migration und Flüchtlinge";
    XCTAssertEqualObjects(expectedAuthorOfCatalog, authorOfCatalog);
    
    NSString *publisherOfCatalog = [catalogInfo detailForKey:@"publisher"];
    NSString *expectedPublisherOfCatalog = @"Bundesamt für Migration und Flüchtlinge";
    XCTAssertEqualObjects(expectedPublisherOfCatalog, publisherOfCatalog);
    
    NSString *numberOfQuestions = [catalogInfo detailForKey:@"numberOfQuestions"];
    NSString *expectedNumberOfQuestions = @"2";
    XCTAssertEqualObjects(expectedNumberOfQuestions, numberOfQuestions);
    
    NSString *language = [catalogInfo detailForKey:@"language"];
    NSString *expectedLanguage = @"deutsch";
    XCTAssertEqualObjects(expectedLanguage, language);
    
    NSString *topic = [catalogInfo detailForKey:@"topic"];
    NSString *expectedTopic = @"Allgemeinbildung";
    XCTAssertEqualObjects(expectedTopic, topic);
    
    NSString *version = [catalogInfo detailForKey:@"version"];
    NSString *expectedVersion = @"0.1";
    XCTAssertEqualObjects(version, expectedVersion);
}

-(void)testReadCatalogGallery {
    MWLogNameOfTest(_classObj);
    [self importAddtionalTestData];
    NSURL* catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathCatalogGallery];
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    XCTAssertNotNil(xmlDataFileReader);
    LayCatalogImport *catalogImport = [[LayCatalogImport alloc]initWithDataFileReader:xmlDataFileReader];
    LayCatalogImportReport *importReport = [catalogImport import];
    XCTAssertTrue(importReport.imported);
    BOOL readOk = [self checkReadCatalogGallery:importReport.importedCatalog];
    XCTAssertTrue(readOk);
}

-(void)testReadCitizenshiptest1 {
    MWLogNameOfTest(_classObj);
    [self importAddtionalTestData];
    NSURL* catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest1];
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    XCTAssertNotNil(xmlDataFileReader);
    LayCatalogImport *catalogImport = [[LayCatalogImport alloc]initWithDataFileReader:xmlDataFileReader];
    LayCatalogImportReport *importReport = [catalogImport import];
    XCTAssertTrue(importReport.imported);
    LayCatalogFileInfo *catalogFileInfo = [xmlDataFileReader metaInfo];
    NSString *catalogTitle = [catalogFileInfo catalogTitle];
    NSString *catalogPublisher = [catalogFileInfo detailForKey:@"publisher"];
    LayMainDataStore *mainStore = [LayMainDataStore store];
    Catalog *referenceCatalog = [mainStore findCatalogByTitle:catalogTitle andPublisher:catalogPublisher];
    XCTAssertNotNil(referenceCatalog);
    BOOL readOk = [self checkReadCitizenshiptest1Catalog:referenceCatalog];
    XCTAssertTrue(readOk);
    XCTAssertNotNil(referenceCatalog.description);
    readOk = [self checkTopicsOnCitizenshiptest1Catalog:referenceCatalog];
    XCTAssertTrue(readOk);
    readOk = [self checkExplanationsOnCitizenshiptest1Catalog:referenceCatalog];
    XCTAssertTrue(readOk);
    readOk = [self checkResourcesOnCitizenshiptest1Catalog:referenceCatalog];
    XCTAssertTrue(readOk);
    readOk = [self checkAbouInfosOnCitizenshiptest1Catalog:referenceCatalog];
    XCTAssertTrue(readOk);
}

-(void)importAddtionalTestData {
    NSURL* catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest2];
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    LayCatalogImport *catalogImport = [[LayCatalogImport alloc]initWithDataFileReader:xmlDataFileReader];
    LayCatalogImportReport *importReport = [catalogImport import];
    if(!importReport.imported) {
        MWLogCritical(_classObj, @"Could not import catalog:%@", catalogFile);
    }
    
    catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest3];
    xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    catalogImport = [[LayCatalogImport alloc]initWithDataFileReader:xmlDataFileReader];
    importReport = [catalogImport import];
    if(!importReport.imported) {
        MWLogCritical(_classObj, @"Could not import catalog:%@", catalogFile);
    }
}

-(void)testReadCitizenshiptest{
    MWLogNameOfTest(_classObj);
    NSURL* catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathXmlCatalogCitizenshiptest];
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    XCTAssertNotNil(xmlDataFileReader);
    LayCatalogImport *catalogImport = [[LayCatalogImport alloc]initWithDataFileReader:xmlDataFileReader];
    LayCatalogImportReport *importReport = [catalogImport import];
    XCTAssertTrue(importReport.imported);
    LayCatalogFileInfo *catalogFileInfo = [xmlDataFileReader metaInfo];
    NSString *catalogTitle = [catalogFileInfo catalogTitle];
    NSString *catalogPublisher = [catalogFileInfo detailForKey:@"publisher"];
    LayMainDataStore *mainStore = [LayMainDataStore store];
    Catalog *catalog = [mainStore findCatalogByTitle:catalogTitle andPublisher:catalogPublisher];
    XCTAssertNotNil(catalog);
    BOOL readOk = [self checkReadCatalogCitizenshiptest:catalog];
    XCTAssertTrue(readOk);
}

-(void)testImportInvalidCatalog{
    MWLogNameOfTest(_classObj);
    NSURL* catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathInvalidXmlCatalogCitizenshiptest];;
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    XCTAssertNotNil(xmlDataFileReader);
    LayCatalogImport *catalogImport = [[LayCatalogImport alloc]initWithDataFileReader:xmlDataFileReader];
    LayCatalogImportReport* importReport = [catalogImport import];
    XCTAssertNotNil(importReport);
    XCTAssertFalse(importReport.imported);
    XCTAssertNotNil(importReport.error);
}

-(void)testReadNotWellFormedXmlCatalog{
    MWLogNameOfTest(_classObj);
    NSURL* catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathNotWellFormedXmlCatalogCitizenshiptest];;
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    XCTAssertNotNil(xmlDataFileReader);
    LayImportDataStore *importStore = [LayImportDataStore store];
    Catalog *catalog = [importStore catalogToImportInstance];
    LayError *error = nil;
    BOOL read = [xmlDataFileReader readCatalog:catalog : &error ];
    XCTAssertFalse(read);
    XCTAssertNotNil(error);
    XCTAssertTrue([error hasError:LayImportCatalogParsingError]);
    [importStore clearStore];
}

-(void)testReadCatalogWithMissingResources{
    MWLogNameOfTest(_classObj);
    NSURL* catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathCatalogCitizenshiptestWithMissingResources];;
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    XCTAssertNotNil(xmlDataFileReader);
    LayImportDataStore *importStore = [LayImportDataStore store];
    Catalog *catalog = [importStore catalogToImportInstance];
    LayError *error = nil;
    BOOL read = [xmlDataFileReader readCatalog:catalog : &error ];
    XCTAssertFalse(read);
    XCTAssertNotNil(error);
    XCTAssertTrue([error hasError:LayImportCatalogResourceError]);
    [importStore clearStore];
}

-(void)testReadCatalogWithNoQuestion{
    MWLogNameOfTest(_classObj);
    NSURL* catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathCatalogWithNoQuestion];;
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    XCTAssertNotNil(xmlDataFileReader);
    LayImportDataStore *importStore = [LayImportDataStore store];
    Catalog *catalog = [importStore catalogToImportInstance];
    LayError *error = nil;
    BOOL read = [xmlDataFileReader readCatalog:catalog : &error ];
    XCTAssertFalse(read);
    XCTAssertNotNil(error);
    XCTAssertTrue([error hasError:LayImportCatalogParsingError]);
    [importStore clearStore];
}

-(void)testReadCatalogEinbuerungstest{
    MWLogNameOfTest(_classObj);
    NSURL* catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathCatalogEinbuerungstest];;
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    XCTAssertNotNil(xmlDataFileReader);
    LayImportDataStore *importStore = [LayImportDataStore store];
    Catalog *catalog = [importStore catalogToImportInstance];
    LayError *error = nil;
    BOOL read = [xmlDataFileReader readCatalog:catalog : &error ];
    XCTAssertTrue(read);
    XCTAssertNil(error);
    [importStore clearStore];
}

-(void)testReadCatalogOneQuestion{
    MWLogNameOfTest(_classObj);
    NSURL* catalogFile = [LayCoreTestConfig pathToTestCatalog:TestDataPathCatalogOneQuestionCatalog];;
    LayXmlCatalogFileReader *xmlDataFileReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:catalogFile];
    XCTAssertNotNil(xmlDataFileReader);
    LayImportDataStore *importStore = [LayImportDataStore store];
    Catalog *catalog = [importStore catalogToImportInstance];
    LayError *error = nil;
    BOOL read = [xmlDataFileReader readCatalog:catalog : &error ];
    XCTAssertTrue(read);
    XCTAssertNil(error);

    BOOL hasExplanations = [catalog hasExplanations];
    XCTAssertFalse(hasExplanations);
    
    BOOL hasTopics = [catalog hasTopicsWithQuestions];
    XCTAssertFalse(hasTopics);
    
    [importStore clearStore];
}

-(void)testCatalogWithBase64EncodedImage {
    NSURL *pathToCatalog = [LayCoreTestConfig pathToTestCatalog:TestDataPathCatalogBase64Image];
    LayXmlCatalogFileReader *xmlCatalogReader = [[LayXmlCatalogFileReader alloc]initWithXmlFile:pathToCatalog];
    XCTAssertNotNil(xmlCatalogReader);
    LayImportDataStore *importStore = [LayImportDataStore store];
    Catalog *catalog = [importStore catalogToImportInstance];
    LayError *error = nil;
    BOOL read = [xmlCatalogReader readCatalog:catalog : &error ];
    XCTAssertFalse(read);
}

-(BOOL) checkReadCatalogCitizenshiptest:(Catalog*)catalog {
    BOOL readOk = YES;
    Catalog *citizenChipCatalog = catalog;
    if(citizenChipCatalog) {
        // check Info-Data
        NSString *expectedAuthorOfCatalog = @"Bundesamt für Migration und Flüchtlinge";
        NSString *expectedPublisherOfCatalog = @"Bundesamt für Migration und Flüchtlinge";
        if(![citizenChipCatalog.author isEqualToString:expectedAuthorOfCatalog] ||
           ![citizenChipCatalog.publisher isEqualToString:expectedPublisherOfCatalog]) {
            readOk = NO;
            MWLogError(_classObj, @"Author-, Publisher-check failed!");
        }
    }
    
    const NSUInteger EXPECTED_NUMBER_OF_QUESTIONS = 2;
    if(readOk) {
        // check questions
        NSArray *questionList = [citizenChipCatalog questionListSortedByNumber];
        if([questionList count]!=EXPECTED_NUMBER_OF_QUESTIONS) {
            MWLogError(_classObj, @"Found:%u questions! Expected:%u", [questionList count], EXPECTED_NUMBER_OF_QUESTIONS);
            readOk = NO;
        } else {
            Question *firstQuestion = [questionList objectAtIndex:0];
            NSString* firstQuestionContent = firstQuestion.question;
            if(![firstQuestionContent isEqualToString:@"Welches Wappen gehört zum Bundesland Berlin?"]) {
                readOk = NO;
            }
            
            Question *secondQuestion = [questionList objectAtIndex:1];
            NSString* secondQuestionContent = secondQuestion.question;
            if(![secondQuestionContent isEqualToString:@"Welche Personen sind auf den folgenden Bildern zu sehen?"]) {
                readOk = NO;
            } else {
                Answer *answer = secondQuestion.answerRef;
                NSArray *answerMediaList = [answer mediaList];
                const NSUInteger expectedNumberOfMediaItems = 3;
                if([answerMediaList count]!=expectedNumberOfMediaItems) {
                    MWLogError(_classObj, @"Found:%u media-items! Expected:%u", [answerMediaList count], expectedNumberOfMediaItems);
                    readOk = NO;
                }
                //
                
                BOOL columnStyle = NO;
                if( StyleColumn == [answer styleType]) {
                    columnStyle = YES;
                }
                if(!columnStyle) {
                    MWLogError(_classObj, @"Styles are not set as expected!");
                    readOk = NO;
                }
            }
        }
    }
    return readOk;
}

-(BOOL) checkReadCitizenshiptest1Catalog:(Catalog*)referenceCatalog {
    BOOL readOk = YES;
    if(referenceCatalog) {
        // check Info-Data
        if(!referenceCatalog.author ||
           !referenceCatalog.publisher) {
            readOk = NO;
            MWLogError(_classObj, @"Author-, Publisher-check failed!");
        }
    }
    
    const NSUInteger EXPECTED_NUMBER_OF_QUESTIONS = 13;
    if(readOk) {
        // check questions
        NSArray *questionList = [referenceCatalog questionListSortedByNumber];
        if([questionList count]!=EXPECTED_NUMBER_OF_QUESTIONS) {
            MWLogError(_classObj, @"Found:%u questions! Expected:%u", [questionList count], EXPECTED_NUMBER_OF_QUESTIONS);
            readOk = NO;
        } else {
            
            Question *firstQuestion = [questionList objectAtIndex:0];
            NSString* firstQuestionContent = firstQuestion.question;
            if(![firstQuestionContent isEqualToString:@"Welches Wappen gehört zum Bundesland Berlin?"]) {
                readOk = NO;
            } else {
                Answer *answer = [firstQuestion answerRef];
                // check style attribute
                LayAnswerStyleType styleType = [answer styleType];
                if(styleType != StyleColumn) {
                    MWLogError(_classObj, @"Styles are not set as expected!");
                    readOk = NO;
                }
                
                Explanation *theOnlyExplanationForAnAnswerItem = nil;
                for (AnswerItem* item in [answer answerItemListSessionOrderPreserved]) {
                    if([item hasExplanation]) {
                        theOnlyExplanationForAnAnswerItem = [item explanation];
                    }
                }
                if(!theOnlyExplanationForAnAnswerItem) {
                    MWLogError(_classObj, @"Short explanation expected for answerItem!");
                    readOk = NO;
                } else {
                    if(!theOnlyExplanationForAnAnswerItem.title) {
                        readOk = NO;
                        MWLogError(_classObj, @"Expected an title for explanation!");
                    }
                    
                    if(![theOnlyExplanationForAnAnswerItem.sectionRef count] > 0) {
                        readOk = NO;
                        MWLogError(_classObj, @"Short explanation expected for answerItem!");
                    } else {
                        NSArray *sectionList = [theOnlyExplanationForAnAnswerItem sectionList];
                        Section *section = [sectionList objectAtIndex:0];
                        const NSUInteger expectedNumberOfTextExplanations = 4;
                        if(expectedNumberOfTextExplanations != [section.sectionTextRef count]) {
                            MWLogError(_classObj, @"Number of short explanations does not match!");
                            readOk = NO;
                        } else {
                            NSUInteger counter = 1;
                            NSArray *groupList = [section sectionGroupList];
                            LaySectionTextList *sectionTextList = [groupList objectAtIndex:0];
                            for (SectionText *sectionText in sectionTextList.textList) {
                                NSString *counterAsString = [NSString stringWithFormat:@"%u", counter];
                                NSString *text = sectionText.text;
                                if(text) {
                                    NSRange orderNumber = [text rangeOfString:counterAsString];
                                    if(orderNumber.location!=0) {
                                        MWLogError(_classObj, @"Text is not in expected order!");
                                        readOk = NO;
                                    }
                                    counter++;
                                }
                            }
                        }
                    }
                }
            }
            
            //
            Question *secondQuestion = [questionList objectAtIndex:1];
            NSString* secondQuestionContent = secondQuestion.question;
            if(![secondQuestionContent isEqualToString:@"Welches ist das Wappen der Bundesrepublik Deutschland?"]) {
                readOk = NO;
            } else {
                Answer *answer = secondQuestion.answerRef;
                Explanation* explanation = [answer explanation];
                if(!explanation) {
                    MWLogError(_classObj, @"Explanation expected for answer!");
                    readOk = NO;
                }
                
                const NSInteger numberOfExpectedSections = 1;
                const NSInteger numberOfExpectedTextItems = 1;
                NSArray *sectionList = [explanation sectionList];
                if([sectionList count] == numberOfExpectedSections) {
                    Section *section = [sectionList objectAtIndex:0];
                    if([section.sectionTextRef count] != numberOfExpectedTextItems) {
                        MWLogError(_classObj, @"Number of expected text items in section are:%u not:%u!", numberOfExpectedTextItems, [section.sectionTextRef count]);
                        readOk = NO;
                    }
                    
                    const NSInteger numberOfExpectedMediaItems = 4;
                    if([section.sectionMediaRef count] != numberOfExpectedMediaItems) {
                        MWLogError(_classObj, @"Number of expected media items in section are:%u not:%u!", numberOfExpectedMediaItems, [section.sectionMediaRef count]);
                        readOk = NO;
                    }
                    
                    // check the order of items in the section
                    const NSInteger numberOfExpectedSectionItems = 2;
                    NSArray *sectionItemList = [section sectionGroupList];
                    if([sectionItemList count]==numberOfExpectedSectionItems) {
                        NSObject *sectionItem = [sectionItemList objectAtIndex:0];
                        if(![sectionItem isKindOfClass:[LaySectionTextList class]]) {
                            MWLogError(_classObj, @"An TextItem is expected as first section item!");
                            readOk = NO;
                        } else {
                            sectionItem = [sectionItemList objectAtIndex:1];
                            if(![sectionItem isKindOfClass:[LaySectionMediaList class]]) {
                                MWLogError(_classObj, @"An MediaList is expected as second section item!");
                                readOk = NO;
                            }
                        }
                    } else {
                        MWLogError(_classObj, @"Number of expected items in section are:%u not:%u!", numberOfExpectedSectionItems, [sectionItemList count]);
                        readOk = NO;
                    }
                } else {
                    MWLogError(_classObj, @"One section expected(Question:%@)!", secondQuestion.name);
                    readOk = NO;
                }
                
                Explanation *theOnlyExplanationForAnAnswerItem = nil;
                BOOL hasMedia = NO;
                for (AnswerItem* item in [answer answerItemListSessionOrderPreserved]) {
                    if([item hasExplanation]) {
                        theOnlyExplanationForAnAnswerItem = [item explanation];
                    }
                    
                    if([item hasMedia]) {
                        if(item.mediaRef) {
                            LayMediaData *md = [item mediaData];
                            if(!md) {
                                MWLogError(_classObj, @"Invalid media reference!");
                            } else {
                                hasMedia = YES;
                            }
                        }
                    }

                }
                if(!theOnlyExplanationForAnAnswerItem) {
                    MWLogError(_classObj, @"Short explanation expected for answerItem(Question:%@)!", secondQuestion.name);
                    readOk = NO;
                }
                
                if(!hasMedia) {
                    MWLogError(_classObj, @"Media expected for answerItem!");
                    readOk = NO;
                }
            }
            
            //
            Question *thirdQuestion = [questionList objectAtIndex:2];
            NSString* thirdQuestionContent = thirdQuestion.question;
            if(![thirdQuestionContent isEqualToString:@"Welches ist das Wappen der Bundesrepublik Deutschland die Zweite?"]) {
                readOk = NO;
            } else {
                Answer *answer = thirdQuestion.answerRef;
                Explanation* explanation = [answer explanation];
                if(!explanation) {
                    MWLogError(_classObj, @"Short explanation expected for answer(Question:%@)!", thirdQuestion.name);
                    readOk = NO;
                }
                
                Explanation *theOnlyExplanationForAnAnswerItem = nil;
                BOOL hasMedia = NO;
                for (AnswerItem* item in [answer answerItemListSessionOrderPreserved]) {
                    if([item hasExplanation]) {
                        theOnlyExplanationForAnAnswerItem = [item explanation];
                    }
                    if([item hasMedia]) {
                        if(item.mediaRef) {
                            LayMediaData *md = [item mediaData];
                            if(!md) {
                                MWLogError(_classObj, @"Invalid media reference!");
                            } else {
                                hasMedia = YES;
                            }
                        }
                    }
                }
                if(!theOnlyExplanationForAnAnswerItem) {
                    MWLogError(_classObj, @"Short explanation expected for answerItem(Question:%@)!", thirdQuestion.name);
                    readOk = NO;
                }
                
                if(!hasMedia) {
                    MWLogError(_classObj, @"Media expected for answerItem!");
                    readOk = NO;
                }
            }
        
            //
            //
            Question *fourthQuestion = [questionList objectAtIndex:3];
            NSString* fourthQuestionContent = fourthQuestion.question;
            if(![fourthQuestionContent isEqualToString:@"Welche Personen sind auf den folgenden Bildern zu sehen?"]) {
                readOk = NO;
            } else {
                Answer *answer = fourthQuestion.answerRef;
                NSArray *answerMediaList = [answer answerMediaList];
                const NSUInteger expectedNumberOfMediaItems = 3;
                if([answerMediaList count]!=expectedNumberOfMediaItems) {
                    MWLogError(_classObj, @"Found:%u media-items! Expected:%u", [answerMediaList count], expectedNumberOfMediaItems);
                    readOk = NO;
                }
                
                if([answer hasExplanation]) {
                    Explanation *explanation = [answer explanation];
                    if(explanation) {
                        Section *section = [[explanation sectionList] objectAtIndex:0];
                        NSArray *sectionItemList = [section sectionGroupList];
                        const NSUInteger numberOfExpectedItems = 3;
                        if([sectionItemList count]!=numberOfExpectedItems) {
                            MWLogError(_classObj, @"Number of expected items:%u does not match:%u!", numberOfExpectedItems, [sectionItemList count] );
                            readOk = NO;
                        }
                    } else {
                        MWLogError(_classObj, @"Explanation with mediaList expected for answer!");
                        readOk = NO;
                    }
                } else {
                    MWLogError(_classObj, @"Explanation expected for answer(Question:%@)!", fourthQuestion.name);
                    readOk = NO;
                }
                
                
                BOOL atLeastOneShowLabelAttr = NO;
                for (AnswerMedia* answerMediaRef in answerMediaList) {
                    if(answerMediaRef.mediaRef.label==nil) {
                        readOk = NO;
                    }
                    if(answerMediaRef.mediaRef.showLabel!=nil) {
                        //NSString *value = mediaItemRef.mediaRef.showLabel;
                        atLeastOneShowLabelAttr = YES;
                    }
                }
                if(!atLeastOneShowLabelAttr) readOk = NO;

            }
        }
    }
    
    return readOk;
}


-(BOOL)checkTopicsOnCitizenshiptest1Catalog:(Catalog*)catalog {
    BOOL readOk = YES;
    Catalog *referenceCatalog = catalog;
    NSArray *topicList = [referenceCatalog topicList];
    const NSUInteger expectedNumberOfTopics = 3;
    if([topicList count]!=expectedNumberOfTopics) {
        MWLogError(_classObj, @"Expected number of topics are:%u not:%u!", expectedNumberOfTopics, [topicList count] );
        readOk = NO;
    }
    
    if(readOk) {
        NSString *expectedNameOfTopic1 = (NSString*)NAME_OF_DEFAULT_TOPIC;
        Topic *topic = [topicList objectAtIndex:0];
        if([topic.name isEqualToString:expectedNameOfTopic1]) {
            NSSet *questionSet = [topic questionSet];
            const NSUInteger expectedNumberOfQuestionsTopics1 = 9;
            if([questionSet count]!=expectedNumberOfQuestionsTopics1) {
                MWLogError(_classObj, @"Expected number of question in topic:%@ are:%u not:%u!", topic.name, expectedNumberOfQuestionsTopics1, [questionSet count] );
                readOk = NO;
            } else {
                // search for some questions
                NSUInteger numberOfQuestionsTypeCard = 0;
                for (Question *question in [topic questionSet]) {
                    LayAnswerTypeIdentifier questionType = [question questionType];
                    if(questionType == ANSWER_TYPE_CARD) {
                        numberOfQuestionsTypeCard++;
                    }
                }
                const NSUInteger expectedNumberOfCardQuestions = 2;
                if(expectedNumberOfCardQuestions != numberOfQuestionsTypeCard) {
                    MWLogError(_classObj, @"Expected number of card-question in topic:%@ are:%u not:%u!", topic.name, expectedNumberOfCardQuestions, numberOfQuestionsTypeCard );
                    readOk = NO;
                }
            }
            
            if(![topic.title isEqualToString:(NSString*)TITLE_OF_DEFAULT_TOPIC]) {
                MWLogError(_classObj, @"Expected title of default topic must be %@ not:%@!", (NSString*)TITLE_OF_DEFAULT_TOPIC, topic.title );
                readOk = NO;
            }
            
            NSSet *explanationSet = [topic explanationSet];
            const NSUInteger expectedNumberOfExplanationsTopics1 = 9;
            if([explanationSet count]!=expectedNumberOfExplanationsTopics1) {
                MWLogError(_classObj, @"Expected number of explanations in topic:%@ are:%u not:%u!", topic.name, expectedNumberOfExplanationsTopics1, [explanationSet count] );
                readOk = NO;
            }
            
        } else {
            MWLogError(_classObj, @"Expected first name topic:%@ not:%@!", expectedNameOfTopic1, topic.name  );
            readOk = NO;
        }
        
        // second topic
        NSString *expectedNameOfTopic2 = @"bundeskanzler";
        topic = [topicList objectAtIndex:1];
        if([topic.name isEqualToString:expectedNameOfTopic2]) {
            NSSet *questionSet = [topic questionSet];
            const NSUInteger expectedNumberOfQuestionsTopics1 = 1;
            if([questionSet count]!=expectedNumberOfQuestionsTopics1) {
                MWLogError(_classObj, @"Expected number of question in topic:%@ are:%u not:%u!", topic.name, expectedNumberOfQuestionsTopics1, [questionSet count] );
                readOk = NO;
            }
            
            NSString *expectedTitle = @"Frühere Bundeskanzler";
            if(![topic.title isEqualToString:expectedTitle]) {
                MWLogError(_classObj, @"Expected title of first topic:%@ is:%@ not:%@!", topic.name, expectedTitle, topic.title );
                readOk = NO;
            }
            
            NSSet *explanationSet = [topic explanationSet];
            const NSUInteger expectedNumberOfExplanationsTopics1 = 1;
            if([explanationSet count]!=expectedNumberOfExplanationsTopics1) {
                MWLogError(_classObj, @"Expected number of explanations in topic:%@ are:%u not:%u!", topic.name, expectedNumberOfExplanationsTopics1, [explanationSet count] );
                readOk = NO;
            }
            
        } else {
            MWLogError(_classObj, @"Expected second name topic:%@ not:%@!", expectedNameOfTopic1, topic.name  );
            readOk = NO;
        }
        
        // third topic
        NSString *expectedNameOfTopic3 = @"wappen";
        topic = [topicList objectAtIndex:2];
        if([topic.name isEqualToString:expectedNameOfTopic3]) {
            NSSet *questionSet = [topic questionSet];
            const NSUInteger expectedNumberOfQuestionsTopics2 = 3;
            if([questionSet count]!=expectedNumberOfQuestionsTopics2) {
                MWLogError(_classObj, @"Expected number of question in topic:%@ are:%u not:%u!", topic.name, expectedNumberOfQuestionsTopics2, [questionSet count] );
                readOk = NO;
            }
        } else {
            MWLogError(_classObj, @"Expected third name topic:%@ not:%@!", expectedNameOfTopic2, topic.name  );
            readOk = NO;
        }
    }
    
    
    return readOk;
}

-(BOOL)checkExplanationsOnCitizenshiptest1Catalog:(Catalog*)catalog {
    BOOL readOk = YES;
    Catalog *referenceCatalog = catalog;
    BOOL hasExplanations = [referenceCatalog hasExplanations];
    if(!hasExplanations) {
        MWLogError(_classObj, @"Catalog:%@ should have explanations!", catalog.title);
        readOk = NO;
    }
    if(hasExplanations) {
        NSArray *explanationList = [referenceCatalog explanationListSortedByNumber];
        const NSUInteger expectedNumberOfTopics = 10;
        if([explanationList count]!=expectedNumberOfTopics) {
            MWLogError(_classObj, @"Expected number of explanations in catalog:%@ are:%u not:%u!", catalog.title, expectedNumberOfTopics, [explanationList count] );
            readOk = NO;
        }
    }
    
    return readOk;
}


-(BOOL)checkResourcesOnCitizenshiptest1Catalog:(Catalog*)catalog {
    BOOL readOk = YES;
    
    NSArray *resourceList = [catalog resourceList];
    const NSUInteger expectedNumberOfResource = 3;
    if([resourceList count] != expectedNumberOfResource) {
        readOk = NO;
        MWLogError(_classObj, @"Expected number of resources in catalog:%@ are:%u not:%u!", catalog.title, expectedNumberOfResource, [resourceList count] );
    } else {
        NSString *expectedNameOfFirstResource = @"res1";
        Resource *resource = [resourceList objectAtIndex:0];
        if(![resource.name isEqualToString:expectedNameOfFirstResource]) {
            readOk = NO;
            MWLogError(_classObj, @"Expected name of first resources in catalog:%@ is:%@ not:%@!", catalog.title, expectedNameOfFirstResource, resource.name );
        } else {
            NSString *expectedTitleOfFirstResource = @"Bundeskanzler (Deutschland)";
            if(![resource.title isEqualToString:expectedTitleOfFirstResource]) {
                readOk = NO;
                MWLogError(_classObj, @"Expected title of first resources in catalog:%@ is:%@ not:%@!", catalog.title, expectedTitleOfFirstResource, resource.title );
            }
            NSString *expectedLinkOfFirstResource = @"http://de.wikipedia.org/wiki/Bundeskanzler_(Deutschland)";
            if(![resource.link isEqualToString:expectedLinkOfFirstResource]) {
                readOk = NO;
                MWLogError(_classObj, @"Expected link of first resources in catalog:%@ is:%@ not:%@!", catalog.title, expectedLinkOfFirstResource, resource.link );
            }
        
        NSArray *linkedQuestions = [resource questionList];
        NSUInteger expectedNumberOfLinkedQuestions = 3;
        if([linkedQuestions count] != expectedNumberOfLinkedQuestions) {
            readOk = NO;
            MWLogError(_classObj, @"Expected number of linked questions with resource:%@ are:%u not:%u!", resource.name, expectedNumberOfLinkedQuestions, [linkedQuestions count] );
        }
        
        NSArray *linkedExplanations = [resource explanationList];
        NSUInteger expectedNumberOfLinkedExplanations = 2;
        if([linkedExplanations count] != expectedNumberOfLinkedExplanations) {
            readOk = NO;
            MWLogError(_classObj, @"Expected number of linked explanations with resource:%@ are:%u not:%u!", resource.name, expectedNumberOfLinkedExplanations, [linkedExplanations count] );
        }
        
    }
}
return readOk;
}

-(BOOL)checkAbouInfosOnCitizenshiptest1Catalog:(Catalog*)catalog {
    BOOL readOk = YES;
    if(catalog.aboutRef) {
        NSArray *sectionList = [catalog.aboutRef sectionList];
        const NSInteger expectedNumberOfSections = 2;
        if([sectionList count] == expectedNumberOfSections) {
            Section *firstSection = [sectionList objectAtIndex:0];
            NSArray *sectionGroupList = [firstSection sectionGroupList];
            const NSUInteger expectedNumberOfGroupsInSection1 = 3; // 1.textist, 2.mediaList, 3.textList
            NSUInteger numberOfSectionItems = [sectionGroupList count];
            if( numberOfSectionItems == expectedNumberOfGroupsInSection1) {
                NSObject *sectionItem1 = [sectionGroupList objectAtIndex:0];
                if(![sectionItem1 isKindOfClass:[LaySectionTextList class]]) {
                    readOk = NO;
                    MWLogError(_classObj, @"A Text-Item is expected as first item!");
                } else {
                    NSObject *sectionItem2 = [sectionGroupList objectAtIndex:1];
                    if(![sectionItem2 isKindOfClass:[LaySectionMediaList class]]) {
                        readOk = NO;
                        MWLogError(_classObj, @"A Media-Item is expected as second item!");
                    } else {
                        LaySectionMediaList *mediaList = (LaySectionMediaList*)sectionItem2;
                        const NSUInteger expectedNumberOfMediaInList = 3;
                        NSUInteger numberOfMediaInList = [mediaList.mediaList count];
                        if(expectedNumberOfMediaInList == numberOfMediaInList) {
                            SectionMedia *firstMedia = [mediaList.mediaList objectAtIndex:0];
                            NSString *expectedNameOfMedia = @"Konrad_Adenauer.jpg";
                            if(![expectedNameOfMedia isEqualToString:firstMedia.mediaRef.name]) {
                                readOk = NO;
                                MWLogError(_classObj, @"Expected name of media is:%@ not:%@", expectedNameOfMedia, firstMedia.mediaRef.name );
                            }
                        } else {
                            readOk = NO;
                            MWLogError(_classObj, @"Expected number of media in list:%u not:%u", expectedNumberOfMediaInList, numberOfMediaInList );
                        }
                    }
                    
                    NSObject *sectionItem3 = [sectionGroupList objectAtIndex:2];
                    if(![sectionItem3 isKindOfClass:[LaySectionTextList class]]) {
                        readOk = NO;
                        MWLogError(_classObj, @"A Text-Item is expected as third item!");
                    } else {
                        LaySectionTextList *textList = (LaySectionTextList*)sectionItem3;
                        const NSUInteger expectedNumberOfTextItemsInTextList = 2;
                        NSUInteger numberOfTextItemsInTextList = [textList.textList count];
                        if(expectedNumberOfTextItemsInTextList == numberOfTextItemsInTextList) {
                            SectionText* text = [textList.textList objectAtIndex:0];
                            NSString* firstTextInList = text.text;
                            const NSString* expectedText = @"Autor 2";
                            if(![firstTextInList isEqualToString:(NSString*)expectedText]) {
                                readOk = NO;
                                MWLogError(_classObj, @"Expected text is:%@ not:%@!",expectedText, firstTextInList);
                            }
                        } else {
                            readOk = NO;
                            MWLogError(_classObj, @"%u text-items expected, not:%u!",expectedNumberOfTextItemsInTextList, numberOfTextItemsInTextList);
                        }
                    }
                }
            } else {
                readOk = NO;
                MWLogError(_classObj, @"%u sectionsItems expected in the first section not:%u!",expectedNumberOfGroupsInSection1, numberOfSectionItems);
            }
        } else {
            readOk = NO;
            MWLogError(_classObj, @"%u sections expected in about information, not:%u!",expectedNumberOfSections, [sectionList count]);
        }
    } else {
        readOk = NO;
        MWLogError(_classObj, @"About information expected!");
    }
    return readOk;
}

-(BOOL)checkReadCatalogGallery:(Catalog*)catalog {
    NSString *nameOfQuestionToCheck = @"borderCanada";
    BOOL catalogIsAsExpected = NO;
    NSUInteger numberOfQuestionsWithTypeWordResponse = 0;
    for (Question *question in [catalog questionListSortedByNumber]) {
        if( [question.name isEqualToString:@"question1"] ) {
            Introduction *intro = question.introRef;
            if(intro) {
                const NSUInteger expectedNumberOfSections = 2;
                NSArray *sectionList = [intro orderedSectionList];
                if( [sectionList count] == expectedNumberOfSections ) {
                    const NSUInteger expectedNumberOfItemsInSectionOne = 3;
                    Section *sectionOne = [sectionList objectAtIndex:0];
                    NSArray *sectionGroup = [sectionOne sectionGroupList];
                    if([sectionGroup count] == expectedNumberOfItemsInSectionOne) {
                        catalogIsAsExpected = YES;
                    } else {
                        MWLogError(_classObj, @"Intro number of items does not match:%d, %d!",expectedNumberOfItemsInSectionOne, [sectionGroup count] );
                        catalogIsAsExpected = NO;
                    }
                    
                    const NSUInteger expectedNumberOfItemsInSectionTwo = 1;
                    Section *sectionTwo = [sectionList objectAtIndex:1];
                    sectionGroup = [sectionTwo sectionGroupList];
                    if([sectionGroup count] == expectedNumberOfItemsInSectionTwo) {
                        catalogIsAsExpected = YES;
                    } else {
                        MWLogError(_classObj, @"Intro number of items in section2 does not match:%d, %d!",expectedNumberOfItemsInSectionTwo, [sectionGroup count] );
                        catalogIsAsExpected = NO;
                    }
                } else {
                    MWLogError(_classObj, @"Expected number of sections is:%d not: %d!",expectedNumberOfSections, [sectionList count] );
                }
                
            } else {
                 MWLogError(_classObj, @"Intro expected for question:%@!",question.name);
            }
        }
        
        if ( [question.name isEqualToString:nameOfQuestionToCheck] ) {
            catalogIsAsExpected = [self checkReadCatalogGalleryQuestionWithNameBorderCanada:question];
        } else if( [question.name isEqualToString:@"keyWordItemMatch1"] ) {
            catalogIsAsExpected = [self checkReadCatalogGalleryQuestionWithNameKeyWordItemMatch1:question];
        }
        
        if([question questionType] == ANSWER_TYPE_WORD_RESPONSE) {
            ++numberOfQuestionsWithTypeWordResponse;
        }
    }
    
  
    
    if(catalogIsAsExpected) {
        const NSUInteger expectedNumberOfQuestionsWithTypeWordResponse = 3;
        if(expectedNumberOfQuestionsWithTypeWordResponse == numberOfQuestionsWithTypeWordResponse) {
            catalogIsAsExpected = YES;
        } else {
            MWLogError(_classObj, @"Number:%d of expected:%d questions with type:wordResponse does not match!",expectedNumberOfQuestionsWithTypeWordResponse, numberOfQuestionsWithTypeWordResponse);
        }
    }
    
    return catalogIsAsExpected;
}

-(BOOL)checkReadCatalogGalleryQuestionWithNameBorderCanada:(Question*)question {
    BOOL questionIsAsExpected = NO;
    NSString *nameOfQuestionToCheck = @"borderCanada";
    if([question.name isEqualToString:nameOfQuestionToCheck]) {
        Answer *answer = question.answerRef;
        if( [answer hasExplanation]) {
            Explanation *explanation = answer.explanationRef;
            NSArray *sectionList = [explanation sectionList];
            if([sectionList count] == 2) {
                Section *section = [sectionList objectAtIndex:0];
                NSArray *sectionGroupList = [section sectionGroupList];
                const NSInteger expectedNumberOfGroupsInSection = 3;
                if([sectionGroupList count] == expectedNumberOfGroupsInSection) {
                    NSObject *sectionQuestion = [sectionGroupList objectAtIndex:1];
                    if( [sectionQuestion isKindOfClass:[SectionQuestion class]] ) {
                        Question *q = ((SectionQuestion*)sectionQuestion).questionRef;
                        if([q.name isEqualToString:nameOfQuestionToCheck]) {
                            questionIsAsExpected = YES;
                        } else {
                             MWLogError(_classObj, @"Expected question:%@ as ref not:%@", nameOfQuestionToCheck, q.name);
                        }
                    } else {
                         MWLogError(_classObj, @"SectionQuestion expected in explanation:%@", explanation.name);
                    }
                } else {
                    MWLogError(_classObj, @"%d groups expected in explanation:%@", expectedNumberOfGroupsInSection, explanation.name);
                }
            } else {
                MWLogError(_classObj, @"One section expected for explanation:%@", explanation.name);
            }
        } else {
            MWLogError(_classObj, @"Expect an explanation for question:%@", nameOfQuestionToCheck);
        }
    } else {
        MWLogError(_classObj, @"Expect a question with name:%@ not:%@", nameOfQuestionToCheck, question.name);
    }
    return questionIsAsExpected;
}

-(BOOL)checkReadCatalogGalleryQuestionWithNameKeyWordItemMatch1:(Question*)question {
    BOOL questionIsAsExpected = YES;
    LayAnswerTypeIdentifier questionType = [question questionType];
    if( questionType == ANSWER_TYPE_KEY_WORD_ITEM_MATCH ) {
        Answer *answer = question.answerRef;
        NSArray *answerItemList = [answer answerItemListSessionOrderPreserved];
        for (size_t itemIdx = 0; itemIdx < [answerItemList count]; ++itemIdx ) {
            AnswerItem* item = [answerItemList objectAtIndex:itemIdx];
            if( 0 == itemIdx ) {
                NSArray *keyWordList = [item keyWordListLowerCase];
                if( [keyWordList count] == 1 ) {
                    NSString *keyWord = [keyWordList objectAtIndex:0];
                    if(![keyWord isEqualToString:@"bounty"]) {
                        questionIsAsExpected = NO;
                        MWLogError(_classObj, @"Expected bounty!");
                    }
                }
            } else if( 1 == itemIdx ) {
                NSArray *keyWordList = [item keyWordListLowerCase];
                if( [keyWordList count] == 1 ) {
                    NSString *keyWord = [keyWordList objectAtIndex:0];
                    if(![keyWord isEqualToString:@"blood"]) {
                        questionIsAsExpected = NO;
                        MWLogError(_classObj, @"Expected blood!");
                    }
                }
            } else if( 2 == itemIdx ) {
                NSArray *keyWordList = [item keyWordListLowerCase];
                if( [keyWordList count] == 2 ) {
                    NSString *keyWord = [keyWordList objectAtIndex:0];
                    if(![keyWord isEqualToString:@"gangs"]) {
                        questionIsAsExpected = NO;
                        MWLogError(_classObj, @"Expected gangs!");
                    }
                    
                    keyWord = [keyWordList objectAtIndex:1];
                    if(![keyWord isEqualToString:@"new york"]) {
                        questionIsAsExpected = NO;
                        MWLogError(_classObj, @"Expected new york!");
                    }
                }
            }
        }
    } else {
        questionIsAsExpected = NO;
    }
    
    return questionIsAsExpected;
}

@end
