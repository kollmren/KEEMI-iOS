//
//  LayZipDataFileReader.m
//
//
//  Created by Rene Kollmorgen on 05.05.13.
//
//mediaNodeData

#import "LayXmlCatalogFileReader.h"
#import "LayXmlDocumentDataCatcher.h"
#import "LayXmlNode.h"
#import "LayAnswerType.h"
#import "LayResourceType.h"
#import "LayCatalogValidator.h"
#import "LayMediaTypes.h"
#import "LayError.h"
#import "LayConstants.h"
#import "LayDataStoreUtilities.h"

#import "Catalog+Utilities.h"
#import "Question+Utilities.h"
#import "Answer+Utilities.h"
#import "AnswerItem+Utilities.h"
#import "Media+Utilities.h"
#import "AnswerMedia+Utilities.h"
#import "Explanation+Utilities.h"
#import "Topic+Utilities.h"
#import "Resource+Utilities.h"
#import "Section+Utilities.h"
#import "About+Utilities.h"
#import "SectionQuestion.h"
#import "Introduction.h"

#import "MWLogging.h"

#import "ZipArchive.h"

const NSString* const LAY_CATALOG_PACKAGE_EXTENSTION_KEEMI=@".keemi";
const NSString* const LAY_CATALOG_PACKAGE_EXTENSTION_ZIP=@".zip";
// name if element and attributes
const NSString* const LAY_XML_TAG_QUESTION=@"question";
const NSString* const LAY_XML_TAG_MEDIALIST=@"mediaList";
const NSString* const LAY_XML_TAG_MEDIA=@"media";
const NSString* const LAY_XML_TAG_SECTION=@"section";
const NSString* const LAY_XML_TAG_TITLE=@"title";
const NSString* const LAY_XML_TAG_TEXT=@"text";
const NSString* const LAY_XML_TAG_CATALOG_ABOUT=@"about";
const NSString* const LAY_XML_TAG_LINK = @"link";
const NSString* const LAY_XML_TAG_WEBSITE = @"website";
const NSString* const LAY_XML_TAG_EMAIL = @"email";
const NSString* const LAY_XML_TAG_SOURCE = @"download";
const NSString* const LAY_XML_TAG_INTRODUCTION = @"introduction";
const NSString* const LAY_XML_TAG_KEY_WORD_LIST = @"keyWordList";

const NSString* const LAY_XML_ATTRIBUTE_NAME = @"name";
const NSString* const LAY_XML_ATTRIBUTE_SHUFFLE_ANSWERS = @"shuffleAnswers";
const NSString* const LAY_XML_ATTRIBUTE_GROUP_QUESTIONS = @"groupName";
const NSString* const LAY_XML_ATTRIBUTE_EQUAL_GROUP_NAME = @"equalGroupName";

static const NSInteger NUMBER_OF_DEFAULT_TOPIC = 1;

//
// LayXmlMediaNodeData
//
@interface LayXmlMediaNodeData : NSObject
@property (nonatomic) LayMediaType mediaType;
@property (nonatomic) LayMediaFormat mediaFormat;
@property (nonatomic) NSString *label; // optional
@property (nonatomic) NSString *showLabel; // optional
@property (nonatomic) NSData *mediaFileContent;
@property (nonatomic) NSString *fileRef;
@end

//
// LayXmlCatalogFileReader
//
@interface LayXmlCatalogFileReader() {
    NSURL* catalogFile;
    LayXmlDocumentDataCatcher *xmlDataCatcher;
    LayCatalogFileInfo *catalogInfo;
    id<LayImportProgressDelegate> importProgressStateDelegate;
    NSUInteger importStepCounter;
    //
    Catalog *importCatalog;
    NSUInteger questionCounter;
    NSUInteger explanationCounter;
    NSUInteger resourceCounter;
    NSUInteger topicCounter;
    //
    LayError *readError;
}
@end

//
// LayXmlCatalogFileReader
//
@interface LayXmlCatalogFileReader() {
    NSMutableDictionary *explanationRefMap;
    NSMutableDictionary *resourceRefMap;
}

@end

@implementation LayXmlCatalogFileReader

static Class _classObj = nil;

+(void) initialize {
    _classObj = [LayXmlCatalogFileReader class];
}

+(NSURL*)unzipCatalog:(NSURL*)catalogFileZipped {
    return [LayXmlCatalogFileReader unzipCatalog:catalogFileZipped andStateDelegate:nil];
}

+(NSURL*)unzipCatalog:(NSURL*)catalogFileZipped andStateDelegate:(id<LayImportProgressDelegate>)stateDelegate {
    NSURL* catalogDirectoryUnzipped = nil;
    BOOL unzipped = NO;
    // !The Inbox directory is readable only
    NSString *targetUnzipDirectory = NSTemporaryDirectory();//[[catalogFileZipped path] stringByDeletingLastPathComponent];
    ZipArchive *za = [[ZipArchive alloc] init];
    if ([za UnzipOpenFile: [catalogFileZipped path]]) {
        NSUInteger numberOfZippedEntries = [za numberOfZippedEntries];
        if(stateDelegate) {
            [stateDelegate setMaxSteps:numberOfZippedEntries];
        }
        unzipped = [za UnzipFileTo: targetUnzipDirectory overWrite:YES andStateDelegate:stateDelegate];
        if(!unzipped){
            MWLogError(_classObj, @"Could not unizp file:%@ to:", [catalogFileZipped path], targetUnzipDirectory);
        } else {
            MWLogDebug(_classObj, @"Successfully unzipped file:%@ to:%@", [catalogFileZipped path], targetUnzipDirectory);
        }
        [za UnzipCloseFile];
    }
    if(unzipped) {
        catalogDirectoryUnzipped = [NSURL fileURLWithPath:targetUnzipDirectory isDirectory:YES];
        //TODO:
        NSString* nameOfPackage = [LayXmlCatalogFileReader getNameOfZippedDirectory:catalogFileZipped]; //[self nameOfPackage:catalogFileZipped];
        catalogDirectoryUnzipped = [catalogDirectoryUnzipped URLByAppendingPathComponent:nameOfPackage];
    }
    
    return catalogDirectoryUnzipped;
}

+(NSString*)getNameOfCatalogFile:(NSURL*)catalogDirectoryUnzipped {
    NSString *xmlFileInUnzippedcatalog = nil;
    NSError *error_ = nil;
    NSFileManager* fileMngr = [NSFileManager defaultManager];
    NSArray *catalogDirContents = [fileMngr contentsOfDirectoryAtPath:[catalogDirectoryUnzipped path] error:&error_];
    if(!catalogDirContents) {
        MWLogError(_classObj, @"No files found in directory:%@! Details:%@,%d", [catalogDirectoryUnzipped path], [error_ domain], [error_ code]);
    } else {
        //remove files or whole directories
        for (NSString *item in catalogDirContents) {
            NSRange xmlExtension = [item rangeOfString:@".xml"];
            if(xmlExtension.location!=NSNotFound) {
                xmlFileInUnzippedcatalog = item;
                MWLogInfo(_classObj, @"Found xml file:%@ in:%@!", item, [catalogDirectoryUnzipped path]);
                break;
            }
        }
    }
    return xmlFileInUnzippedcatalog;
}

-(id)initWithXmlFile:(NSURL*)catalogFile_ {
    self = [self initWithXmlFileNotReadinCatalogInfo:catalogFile_];
    if(self) {
        [self readMetaInfo];
    }
    return self;
}

-(id)initWithXmlFileNotReadinCatalogInfo:(NSURL*)catalogFile_ {
    self->xmlDataCatcher = [[LayXmlDocumentDataCatcher alloc]initWithPathToXmlFile:catalogFile_];
    if(nil==xmlDataCatcher) return nil;
    self = [super init];
    if(self) {
        self->explanationRefMap = [NSMutableDictionary dictionaryWithCapacity:20];
        self->resourceRefMap = [NSMutableDictionary dictionaryWithCapacity:20];
        self->catalogFile = catalogFile_;
        self->catalogInfo = nil;
        self->questionCounter = 0;
        self->explanationCounter = 0;
        self->resourceCounter = 0;
        self->topicCounter = 2;
    }
    return self;
}

-(id)initWithZippedFile:(NSURL*)catalogFileZipped {
    id this = nil;
    NSURL* urlToCatalogFile = nil;
    // TODO: For testing purposes it is simple to deactivate the constraints applied to a KEEMI-catalog-package.
    // The validation must be activated later.
    BOOL validCatalogPackage = YES;//[self isValidCatalogPackage:catalogFileZipped];
    if(validCatalogPackage) {
        NSURL *catalogDirectoryUnzipped = [LayXmlCatalogFileReader unzipCatalog:catalogFileZipped];
        NSString* nameOfPackage = [LayXmlCatalogFileReader getNameOfCatalogFile:catalogDirectoryUnzipped]; //[self nameOfPackage:catalogFileZipped];
        MWLogDebug(_classObj, @"Name of catalog file is:%@", nameOfPackage );
        NSString* xmlCatalogFileName = nameOfPackage;//[NSString stringWithFormat:@"%@%@", nameOfPackage, @".xml"];
        urlToCatalogFile = [catalogDirectoryUnzipped URLByAppendingPathComponent:xmlCatalogFileName];
    }
    
    if(urlToCatalogFile) {
        this = [self initWithXmlFile:urlToCatalogFile];
    }
    
    return this;
}

-(BOOL)readMetaInfo {
    return [self readMetaInfoWithStateDelegate:nil];
}

//
// Private
//
+(NSString*)getNameOfZippedDirectory:(NSURL*)catalogFileZipped {
    NSString *nameOfZippedDirectory = nil;
    // get the name of the package
    NSString* nameOfPackage = [LayXmlCatalogFileReader nameOfPackage:catalogFileZipped];
    // check if the package exists
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    if(![fileMngr fileExistsAtPath:[catalogFileZipped path]]) {
        MWLogError(_classObj, @"Package does not exist:%@", [catalogFileZipped path]);
    } else {
        NSString* pathDelimiter = @"/";
        ZipArchive *za = [[ZipArchive alloc] init];
        if ([za UnzipOpenFile: [catalogFileZipped path]]) {
            NSArray* listOfZippedItems = [za getZipFileContents];
            for (NSString* entry in listOfZippedItems) {
                MWLogDebug(_classObj, @"Found entry:%@ in package:%@", entry, nameOfPackage);
                NSRange firstPathDelim = [entry rangeOfString:pathDelimiter];
                if(firstPathDelim.location==NSNotFound) {
                    NSString *message = [NSString stringWithFormat:@"A valid package contains only one folder! Found file:%@", entry];
                    MWLogError(_classObj, message);
                    break;
                } else {
                    nameOfZippedDirectory = [entry substringToIndex:firstPathDelim.location];
                    break;
                }
            } // for
        } else {
            MWLogError(_classObj, @"Could not unzip package:%@!", [catalogFileZipped path]);
        }
    }
    return nameOfZippedDirectory;
}

+(NSString*)nameOfPackage:(NSURL*)catalogFileZipped {
    NSMutableString* nameOfPackage = nil;
    NSString *packageWithExtension = [catalogFileZipped lastPathComponent];
    // cast to (NSString*) to prevent the warning: .. discard qualifiers
    NSRange extensionRange = [packageWithExtension rangeOfString:(NSString*)LAY_CATALOG_PACKAGE_EXTENSTION_KEEMI options:NSBackwardsSearch];
    if(extensionRange.location==NSNotFound) {
        extensionRange = [packageWithExtension rangeOfString:(NSString*)LAY_CATALOG_PACKAGE_EXTENSTION_ZIP options:NSBackwardsSearch];
    }
    
    if(extensionRange.location!=NSNotFound) {
        nameOfPackage = [NSMutableString stringWithCapacity:[packageWithExtension length]];
        [nameOfPackage appendString:packageWithExtension];
        [nameOfPackage deleteCharactersInRange:extensionRange];
    } else {
        MWLogError(_classObj, @"Unknown type of package extension for catalog:%@!", packageWithExtension);
    }
   
    return nameOfPackage;
}

// A valid catalog-package is a zipped folder which contains one XML-file with the
// same name of the package.
// e.g. nameOfPackage.keemi unzipped: nameOfPackage/nameOfPackage.xml
-(BOOL)isValidCatalogPackage:(NSURL*)catalogFileZipped {
    BOOL validCatalogPackage = YES;
    // get the name of the package
    NSString* nameOfPackage = [LayXmlCatalogFileReader nameOfPackage:catalogFileZipped];
    if(!nameOfPackage) {
        validCatalogPackage = NO;
    }
    
    // check if the package exists
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    if(![fileMngr fileExistsAtPath:[catalogFileZipped path]]) {
        MWLogError(_classObj, @"Package does not exist:%@", [catalogFileZipped path]);
        validCatalogPackage = NO;
    }
    
    // check if only one folder with the name of the package exists in the package
    if(validCatalogPackage) {
        NSString* pathDelimiter = @"/";
        //NSString* pathXmlCatalogFile = [NSString stringWithFormat:@"%@/%@.xml", nameOfPackage, nameOfPackage];
        //BOOL xmlCatalogFileFound = NO;
        BOOL packageFolderFound = NO;
        ZipArchive *za = [[ZipArchive alloc] init];
        if ([za UnzipOpenFile: [catalogFileZipped path]]) {
            NSArray* listOfZippedItems = [za getZipFileContents];
            for (NSString* entry in listOfZippedItems) {
                MWLogDebug(_classObj, @"Found entry:%@ in package:%@", entry, nameOfPackage);
                NSRange firstPathDelim = [entry rangeOfString:pathDelimiter];
                if(firstPathDelim.location==NSNotFound) {
                    NSString *message = [NSString stringWithFormat:@"A valid package contains only one folder! Found file:%@", entry];
                    MWLogError(_classObj, message);
                    validCatalogPackage = NO;
                    break;
                } else {
                    NSString *folderEntry = [entry substringToIndex:firstPathDelim.location];
                    if([folderEntry isEqualToString:nameOfPackage]) {
                        MWLogDebug(_classObj, @"Found package folder:%@", folderEntry);
                        packageFolderFound = YES;
                        break;
                    }
                }
                //TODO: check for xml-file here too.
            } // for
        } else {
            MWLogError(_classObj, @"Could not unzip file:%@!", [catalogFileZipped path]);
        }
        
        if(validCatalogPackage && !packageFolderFound) {
            validCatalogPackage = NO;
            MWLogError(_classObj, @"No folder found in unzipped file:%@!", nameOfPackage);
        }
        
        /*if(validCatalogPackage && !xmlCatalogFileFound) {
         validCatalogPackage = NO;
         MWLogError(_classObj, @"No catalog file:%@ found!", pathXmlCatalogFile);
         }*/
    }
    
    return validCatalogPackage;
}

-(NSURL*) pathToCatalogFile:(NSURL*)catalogDirectory {
    return self->catalogFile;
}

-(void) setupXmlDataCatcherForInfo {
    if(!self->xmlDataCatcher) return;
    NSString *pathToCatchInfoData = @"/catalog/info";
    [self->xmlDataCatcher registerPath:self action:@selector(catchInfoData:) forPath:pathToCatchInfoData];
    NSString *pathToCatchQuestionData = @"/catalog/questionList/question";
    [self->xmlDataCatcher registerPath:self action:@selector(countQuestionNodes:) forPath:pathToCatchQuestionData];
    NSString *pathToCatchExplanationData = @"/catalog/explanationList/explanation";
    [self->xmlDataCatcher registerPath:self action:@selector(countExplanationNodes:) forPath:pathToCatchExplanationData];
}

-(void) setupXmlDataCatcherForQuestions {
    if(!self->xmlDataCatcher) return;
    NSString *pathToCatchQuestionData = @"/catalog/questionList/question";
    [self->xmlDataCatcher registerPath:self action:@selector(catchQuestionData:) forPath:pathToCatchQuestionData];
    NSString *pathToCatchExplanationData = @"/catalog/explanationList/explanation";
    [self->xmlDataCatcher registerPath:self action:@selector(catchExplanationData:) forPath:pathToCatchExplanationData];
    NSString *pathToCatchMediaList = @"/catalog/mediaList/media";
    [self->xmlDataCatcher registerPath:self action:@selector(catchMediaList:) forPath:pathToCatchMediaList];
    NSString *pathToCatchTopicList = @"/catalog/topicList/topic";
    [self->xmlDataCatcher registerPath:self action:@selector(catchTopicList:) forPath:pathToCatchTopicList];
    NSString *pathToCatchResourceList = @"/catalog/resourceList/resource";
    [self->xmlDataCatcher registerPath:self action:@selector(catchResourceList:) forPath:pathToCatchResourceList];
}

-(BOOL) startReadingCatalog {
    BOOL readCatalog = NO;
    [self->xmlDataCatcher unregisterPath:@"/catalog/info"]; // info-data already catched
    [self setupXmlDataCatcherForQuestions];
    LayError *parserError = nil;
    readCatalog = [self->xmlDataCatcher startCatching:&parserError];
    if(parserError && self->readError) {
        [self mergeErrors:parserError and:self->readError];
    }
    
    if(parserError && !self->readError) {
        self->readError = [LayError withIdentifier:LayImportCatalogParsingError andMessage:@"XML parse error!"];
    }
    
    if(readCatalog) {
        // the xml syntax can be fine but not the validation of the catalog
        if(self->readError) {
            readCatalog= NO;
        }
    }
    
    if(readCatalog) {
        readCatalog = [LayCatalogValidator isValidCatalog:self->importCatalog];
        if(!readCatalog) {
            NSString* message = [NSString stringWithFormat:@"Invalid catalog!"];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
    }
    
    
    return readCatalog;
}

-(void)mergeErrors:(LayError*)parserError and:(LayError*)readerError {
    if(readerError && parserError) {
        [readerError addError:parserError];
    }
}

-(void)rememberExplanation:(Explanation*)explanation {
    if(!explanation.name) {
        MWLogError(_classObj, @"Found a reference to an explanation which has no name!");
        return;
    }
    MWLogDebug(_classObj, @"Remember reference to explanation named:%@.", explanation.name);
    Explanation *explanationRefStored = [self->explanationRefMap valueForKey:explanation.name];
    if(![explanationRefStored isEqual:explanation]) {
        [self->explanationRefMap setValue:explanation forKey:explanation.name];
    } else {
        MWLogDebug(_classObj, @"Found addional reference to explanation named:%@", explanation.name);
    }
}

-(void)rememberResource:(Resource*)resource {
    if(!resource.name) {
        MWLogError(_classObj, @"Resource reference with no name!");
        return;
    }
    MWLogDebug(_classObj, @"Remember reference to resource named:%@.", resource.name);
    Resource *resourceRefStored = [self->resourceRefMap valueForKey:resource.name];
    if(![resourceRefStored isEqual:resource]) {
        [self->resourceRefMap setValue:resource forKey:resource.name];
    } else {
        MWLogDebug(_classObj, @"Found addional reference to resource named:%@", resource.name);
    }
}

-(void)deletePendingDomainObjects {
    // deletes objects which was referenced with: explanation or topic but was not further specified
    for (Explanation *explanation in [self->explanationRefMap allValues]) {
        if(!explanation.title) {
            MWLogDebug(_classObj, @"Delete not further specified explanation:%@", explanation.name);
            [self->importCatalog deleteExplanation:explanation];;
        }
    }
    
    for (Topic *topic in [self->importCatalog topicList]) {
        if(![topic.name isEqualToString:(NSString*)NAME_OF_DEFAULT_TOPIC] && !topic.title) {
            Topic *defaultTopic = [self->importCatalog topicInstanceByName:(NSString*)NAME_OF_DEFAULT_TOPIC];
            if(!defaultTopic) {
                defaultTopic = [self->importCatalog topicInstance];
                defaultTopic.name = (NSString*)NAME_OF_DEFAULT_TOPIC;
                defaultTopic.title = (NSString*)TITLE_OF_DEFAULT_TOPIC;
                [defaultTopic setTopicNumber:NUMBER_OF_DEFAULT_TOPIC];
                [defaultTopic setTopicAsSelected];
            }
            if([topic hasQuestions]) {
                NSSet *questionSet = [topic questionSet];
                for (Question *question in questionSet) {
                    MWLogDebug(_classObj, @"Assign question:%@ with not further specified topic:%@ to default-topic.", question.name, topic.name);
                    [question setTopic:defaultTopic];
                }
            }
            
            if([topic hasExplanations]) {
                NSSet *explanationSet = [topic explanationSet];
                for (Explanation *explanation in explanationSet) {
                    MWLogDebug(_classObj, @"Assign explanation:%@ with not further specified topic:%@ to default-topic.", explanation.name, topic.name);
                    [explanation setTopic:defaultTopic];
                }
            }
            
            MWLogDebug(_classObj, @"Delete not further specified topic:%@", topic.name);
            [self->importCatalog deleteTopic:topic];
        }
    }
}

//
// Public / LayCatalogDataFileReader protocol
//
-(LayCatalogFileInfo*)metaInfo {
    LayCatalogFileInfo* fileInfo = nil;
    if(self->catalogInfo) {
        if(!self->readError) {
            NSString *numberOfQuestions = [NSString stringWithFormat:@"%u", self->questionCounter];
            [self->catalogInfo setDetail:numberOfQuestions forKey:@"numberOfQuestions"];
            NSString *numberOfExplanations = [NSString stringWithFormat:@"%u", self->explanationCounter];
            [self->catalogInfo setDetail:numberOfExplanations forKey:@"numberOfExplanations"];
            fileInfo = self->catalogInfo;
        }
    } else {
        MWLogError(_classObj, @"Invalid catalog format!");
    }
    
    return fileInfo;
}

-(BOOL) readCatalog:(Catalog *)catalog :(LayError**) error_ {
    return [self readCatalog:catalog :error_ andImportStateDelegate:nil];
}

-(BOOL) readCatalog:(Catalog *)catalog :(LayError**) error_ andImportStateDelegate:(id<LayImportProgressDelegate>)stateDelegate_ {
    BOOL readCatalog = NO;
    self->importProgressStateDelegate = stateDelegate_;
    if(!self->readError) {
        if(self->importProgressStateDelegate) {
            const NSUInteger numberOfQuestionsAndExplanations = self->questionCounter + self->explanationCounter;
            [self->importProgressStateDelegate setMaxSteps:numberOfQuestionsAndExplanations];
        }
        self->questionCounter = 0;
        self->explanationCounter = 0;
        self->topicCounter = 2; // the first is the default-topic
        self->resourceCounter = 0;
        self->importStepCounter = 0;
        self->importCatalog = catalog;
        
        MWLogDebug(_classObj, @"Add info-data to catalog!");
        catalog.title = self->catalogInfo.catalogTitle;
        [catalog setAuthorInfo:[self->catalogInfo detailForKey:@"author"] andEmail:[self->catalogInfo detailForKey:@"emailAuthor"]];
        [catalog setPublisher:[self->catalogInfo detailForKey:@"publisher"]];
        [catalog setPublisherWebsite:[self->catalogInfo detailForKey:@"websitePublisher"]];
        [catalog setPublisherEmail:[self->catalogInfo detailForKey:@"emailPublisher"]];
        [catalog setCoverImage:self->catalogInfo.cover withType:self->catalogInfo.coverMediaType];
        catalog.language = [self->catalogInfo detailForKey:@"language"];
        catalog.topic = [self->catalogInfo detailForKey:@"topic"];
        catalog.version = [self->catalogInfo detailForKey:@"version"];
        catalog.source = [self->catalogInfo detailForKey:@"source"];
        if(self->catalogInfo.description) {
            catalog.catalogDescription = self->catalogInfo.catalogDescription;
        }
        if(self->catalogInfo.aboutNode) {
            [self catchAboutData:self->catalogInfo.aboutNode];
        }
        
        MWLogInfo(_classObj, @"Start reading catalog!");
        readCatalog = [self startReadingCatalog];
    }
    
    if(self->readError) {
        *error_ = self->readError;
        readCatalog = NO;
    } else {
        [self deletePendingDomainObjects];
    }
    
    return readCatalog;
}

-(LayError*)readError {
    return self->readError;
}

-(BOOL)readMetaInfoWithStateDelegate:(id<LayImportProgressDelegate>)stateDelegate_ {
    MWLogDebug(_classObj, @"Start reading metaInfo:%@", [self->catalogFile path]);
    if(stateDelegate_) {
        // TODO: read a summary(number of questions and explanations) from the xml
        [stateDelegate_ setMaxSteps:300];
        self->importProgressStateDelegate = stateDelegate_;
        self->importStepCounter = 0;
    }
    BOOL readCatalog = NO;
    [self setupXmlDataCatcherForInfo];
    LayError *parserError = nil;
    BOOL readXml = [self->xmlDataCatcher startCatching:&parserError];
    if(parserError && self->readError) {
        [self mergeErrors:parserError and:self->readError];
    }
    readCatalog = readXml;
    if(readCatalog) {
        // the xml syntax can be fine but not the validation of the catalog
        if(self->readError) {
            readCatalog= NO;
        }
    }
    
    return readCatalog;
}

//
//

-(void)adjustErrorWith:(LayErrorIdentifier)identifier andMessage:(NSString*)message {
    if(!self->readError) {
        self->readError = [LayError withIdentifier:identifier andMessage:message];
    } else {
        [self->readError addErrorWithIdentifier:identifier andMessage:message];
    }
    MWLogError(_classObj, message);
}

//
// callbacks to catch xml-data
//

// Info-Data
-(void)catchInfoData:(LayXmlNode*)infoNode {
    if(!infoNode) {
        [self adjustErrorWith:LayInternalError andMessage:@"Can not catch info-data! Node is nil!"];
        return;
    }
    NSString* nameInfoNode = @"info";
    NSString* nameTitleNode = (NSString*)LAY_XML_TAG_TITLE;
    NSString* nameNameNode = (NSString*)LAY_XML_ATTRIBUTE_NAME;
    NSString* nameAuthorNode = @"author";
    NSString* namePublisherNode = @"publisher";
    NSString* nameCoverNode = @"cover";
    NSString *nameMediaNode = (NSString*)LAY_XML_TAG_MEDIA;
    // Optional nodes
    NSString *nameTopicNode = @"topic";
    NSString *nameLanguageNode = @"language";
    NSString *nameInstrcutionNode = @"instruction";
    NSString *nameDescriptionNode = @"description";
    NSString *nameVersionNode = @"version";
    // attr
    NSString *nameInfoFormatAttr = @"format";
    
    if([infoNode.name isEqualToString:nameInfoNode]) {
        self->catalogInfo = [LayCatalogFileInfo new];
        // handle attributes
        NSString *valueFormatAttr = [infoNode valueOfAttribute:nameInfoFormatAttr];
        if(valueFormatAttr) {
            self->catalogInfo.format = valueFormatAttr;
        } else {
            NSString* message = [NSString stringWithFormat:@"Attribute:%@ is required for:%@!", nameInfoFormatAttr, infoNode];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
        
        // Nodes
        LayXmlNode* titleNode = [infoNode nodeByName:nameTitleNode];
        if(titleNode) {
            self->catalogInfo.catalogTitle = [titleNode content];
        } else {
            NSString* message = [NSString stringWithFormat:@"Element:%@/%@ is required!", infoNode, nameTitleNode];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
        
        LayXmlNode* authorNode = [infoNode nodeByName:nameAuthorNode];
        if(authorNode) {
            LayXmlNode* nameNode = [authorNode nodeByName:nameNameNode];
            [self->catalogInfo setDetail:[nameNode content] forKey:@"author"];
            LayXmlNode* authorEmailNode = [authorNode nodeByName:(NSString*)LAY_XML_TAG_EMAIL];
            if(authorEmailNode) {
                [self->catalogInfo setDetail:[authorEmailNode content] forKey:@"emailAuthor"];
            }
        } else {
            NSString* message = [NSString stringWithFormat:@"Element:%@/%@ is required!", infoNode, nameAuthorNode];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
        
        LayXmlNode* publisherNode = [infoNode nodeByName:namePublisherNode];
        if(publisherNode) {
            LayXmlNode* nameNode = [publisherNode nodeByName:nameNameNode];
            [self->catalogInfo setDetail:[nameNode content] forKey:@"publisher"];
            LayXmlNode* publisherLinkNode = [publisherNode nodeByName:(NSString*)LAY_XML_TAG_WEBSITE];
            if(publisherLinkNode) {
                [self->catalogInfo setDetail:[publisherLinkNode content] forKey:@"websitePublisher"];
            }
            LayXmlNode* publisherEmailNode = [publisherNode nodeByName:(NSString*)LAY_XML_TAG_EMAIL];
            if(publisherEmailNode) {
                [self->catalogInfo setDetail:[publisherEmailNode content] forKey:@"emailPublisher"];
            }
        } else {
            NSString* message = [NSString stringWithFormat:@"Element:%@/%@ is required!", infoNode, namePublisherNode];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
        
        LayXmlNode* coverNode = [infoNode nodeByName:nameCoverNode];
        if(coverNode) {
            LayXmlNode* mediaNode = [coverNode nodeByName:nameMediaNode];
            if(mediaNode) {
                LayXmlMediaNodeData *mediaNodeData = [self mediaNodeData:mediaNode];
                if(mediaNodeData) {
                    self->catalogInfo.coverMediaType = mediaNodeData.mediaType;
                    self->catalogInfo.coverMediaFormat = mediaNodeData.mediaFormat;
                    self->catalogInfo.cover = mediaNodeData.mediaFileContent;
                } else {
                    NSString* message = [NSString stringWithFormat:@"Could not read data for element media(cover)!"];
                    [self adjustErrorWith:LayImportCatalogResourceError andMessage:message];
                }
            } else {
                NSString* message = [NSString stringWithFormat:@"Element:%@ is required!", nameMediaNode];
                [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
            }
        } else {
            NSString* message = [NSString stringWithFormat:@"Element:%@/%@ is required!", nameInfoNode, nameCoverNode];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
        
        // Optional nodes
        LayXmlNode* descriptionNode = [infoNode nodeByName:nameDescriptionNode];
        if(descriptionNode) {
            self->catalogInfo.catalogDescription = [descriptionNode content];
        }
        
        LayXmlNode* instructionNode = [infoNode nodeByName:nameInstrcutionNode];
        if(instructionNode) {
            self->catalogInfo.catalogInstrcution = [instructionNode content];
        }
        
        LayXmlNode* languageNode = [infoNode nodeByName:nameLanguageNode];
        if(languageNode) {
            [self->catalogInfo setDetail:[languageNode content] forKey:@"language"];
        }
        
        LayXmlNode* topicNode = [infoNode nodeByName:nameTopicNode];
        if(topicNode) {
            [self->catalogInfo setDetail:[topicNode content] forKey:@"topic"];
        }
        
        LayXmlNode* versionNode = [infoNode nodeByName:nameVersionNode];
        if(versionNode) {
            [self->catalogInfo setDetail:[versionNode content] forKey:@"version"];
        }
        
        LayXmlNode* aboutNode = [infoNode nodeByName:(NSString*)LAY_XML_TAG_CATALOG_ABOUT];
        if(aboutNode) {
            self->catalogInfo.aboutNode = aboutNode;
        }
        
        LayXmlNode* catalogSourceNode = [infoNode nodeByName:(NSString*)LAY_XML_TAG_SOURCE];
        if(catalogSourceNode) {
            [self->catalogInfo setDetail:[catalogSourceNode content] forKey:@"source"];
        }
        
    } else {
        NSString* message = [NSString stringWithFormat:@"Registered path and expected sub-trees differ! Root element:%@", infoNode.name];
        [self adjustErrorWith:LayInternalError andMessage:message];
    }
}

-(void)catchAboutData:(LayXmlNode*)aboutNode {
    if([aboutNode.name isEqualToString:(NSString*)LAY_XML_TAG_CATALOG_ABOUT]) {
        BOOL sectionNodesFound = NO;
        About *about = [self->importCatalog aboutInstance];
        for (LayXmlNode *sectionNode in [aboutNode childNodeListByName:(NSString*)LAY_XML_TAG_SECTION]) {
            Section *section = [self sectionFromNode:sectionNode];
            if(section) {
                sectionNodesFound = YES;
                section.number = [about numberForSection];
                [about addSectionRefObject:section];
            }
        }
        if(!sectionNodesFound) {
            NSManagedObjectContext *managedContext = self->importCatalog.managedObjectContext;
            [managedContext deleteObject:about];
            
            NSString *message = [NSString stringWithFormat:@"Element:%@ is required for element:%@!", (NSString*)LAY_XML_TAG_SECTION, aboutNode];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
    } else {
        NSString *message = [NSString stringWithFormat:@"Element:%@ is not an about element!", aboutNode.name];
        [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
    }
}

// Question-Data
#pragma mark - Catch question
-(void)catchQuestionData:(LayXmlNode*)questionNode {
    if(!questionNode) {
        [self adjustErrorWith:LayInternalError andMessage:@"Can not catch question-data! Element is nil!"];
        return;
    }
    
    if(!self->importCatalog) {
        [self adjustErrorWith:LayInternalError andMessage:@"Internal! Catalog object is nil!"];
        return;
    }
    
    NSString* nameQuestionNode = (NSString*)LAY_XML_TAG_QUESTION;
    NSString* nameTitleNode = (NSString*)LAY_XML_TAG_TITLE;
    NSString* questionNodeAttrType = @"type";
    NSString* questionNodeAttrName = @"name";
    NSString* nameTextNode = (NSString*)LAY_XML_TAG_TEXT;
    NSString* nameAnswerNode = @"answer";
    
    // check for required attributes
    LayAnswerTypeIdentifier questionTypeIdentifier = ANSWER_TYPE_UNKNOWN;
    NSString *typeOfQuestion = [questionNode valueOfAttribute:questionNodeAttrType];
    if(typeOfQuestion) {
        questionTypeIdentifier = [LayAnswerType answerTypeByString:typeOfQuestion];
    } else {
        NSString* message = [NSString stringWithFormat:@"Element:%@ must have an attribute named:%@!", nameQuestionNode, questionNodeAttrType];
        [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
    }
    
    NSString *nameOfQuestion = [questionNode valueOfAttribute:questionNodeAttrName];
    if(!nameOfQuestion) {
        NSString* message = [NSString stringWithFormat:@"Element:%@ must have an attribute named:%@!", nameQuestionNode, questionNodeAttrName];
        [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
    } else {
        if([self->importCatalog containsQuestionWithName:nameOfQuestion]){
            NSString* message = [NSString stringWithFormat:@"A name of a question must be unique! Found name:%@ more than once!", nameOfQuestion];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
        
        if(questionTypeIdentifier == ANSWER_TYPE_UNKNOWN) {
            NSString* message = [NSString stringWithFormat:@"Question:%@ has an unknown type:%@!", nameOfQuestion, typeOfQuestion];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
    }
    
    // process elements
    if([questionNode.name isEqualToString:nameQuestionNode]) {
        LayXmlNode *textNode = [questionNode nodeByName:nameTextNode];
        if(!textNode) {
            NSString* message = [NSString stringWithFormat:@"A child-element named:%@ is required for element:%@", nameTextNode, questionNode];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        } else {
            MWLogDebug(_classObj, @"Process question with name:%@.", nameOfQuestion);
            [self setImportStep];
            ++questionCounter;
            Question *question = [self->importCatalog questionInstance];
            [question setQuestionType:questionTypeIdentifier];
            question.name = nameOfQuestion;
            [question setQuestionNumber:questionCounter];
            question.question = [textNode content];
            LayXmlNode *answerNode = [questionNode nodeByName:nameAnswerNode];
            if(answerNode) {
                [self addAnswerNodeData:answerNode toQuestion:question];
            } else {
                NSString* message = [NSString stringWithFormat:@"A child-element named:%@ is required for element:%@", nameAnswerNode, questionNode];
                [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
            }
            
            LayXmlNode *titleNode = [questionNode nodeByName:nameTitleNode];
            if(titleNode) {
                NSString *title = [titleNode content];
                question.title = title;
                MWLogDebug(_classObj, @"Question:%@ has a title:%@", question.question, title );
            }
            
            //TODO:
            //BOOL validQuestiion = [LayQuestionValidator isValidQuestion:question];
            
            // optional attributes
            [self catchTopicReferenceFromNode:questionNode to:question];
            
            NSString *groupName = [questionNode valueOfAttribute:(NSString*)LAY_XML_ATTRIBUTE_GROUP_QUESTIONS];
            if( groupName ) {
                question.groupName = groupName;
            }
            
            //optional elements
            [self addLinkedResourceListFrom:questionNode to:question];
            
            [self addIntroToQuestion:questionNode to:question];
            
            [self->importCatalog addQuestion:question];
        }
    } else {
        NSString *message = [NSString stringWithFormat:@"Registered path and expected sub-trees differ! Wrong root-element is:%@", questionNode.name];
        [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
    }
}

//
// Helper
//
// Answer-Data
-(void)addAnswerNodeData:(LayXmlNode*)answerNode toQuestion:(Question*)question {
    NSString* nameAnswerNode = @"answer";
    NSString* attrShowMaxItem = @"numberOfVisibleCorrectItems";
    NSString* nameMediaListNode = (NSString*)LAY_XML_TAG_MEDIALIST;
    Answer *answer = nil;
    if([answerNode.name isEqualToString:nameAnswerNode]) {
        answer = [question answerInstance];
        [self setDefaultShuffleAnswerOptionByTypeOfQuestion:question toAnswer:answer];
        [self addAnswerNodeData:answerNode toAnswer:answer];
        [question setAnswer:answer];
        // mediaList
        if(answer) {
            LayXmlNode *mediaListNode = [answerNode nodeByName:nameMediaListNode];
            if(mediaListNode) {
                [self addMediaInList:mediaListNode to:answer];
            }
        }
        // explanation - otional element
        [self addExplanationFrom:answerNode to:answer];
        
        // optional attributes
        NSString *numberOfVisibleItemsString = [answerNode valueOfAttribute:attrShowMaxItem];
        if(numberOfVisibleItemsString) {
            NSInteger numberOfVisibleItems = [numberOfVisibleItemsString integerValue];
            if(numberOfVisibleItems > 0) {
                answer.numberOfVisibleChoices = [NSNumber numberWithInteger:numberOfVisibleItems];
            } else {
                MWLogWarning(_classObj, @"Ignore setting for:%@! Can not convert value:%@ to integer!", attrShowMaxItem, numberOfVisibleItemsString );
            }
        }
        
    } else {
        NSString* message = [NSString stringWithFormat:@"A child-element:%@ is required for a question!", nameAnswerNode];
        [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
    }
}

-(void)setDefaultShuffleAnswerOptionByTypeOfQuestion:(Question*)question toAnswer:(Answer*)answer {
    switch ([question questionType]) {
        case ANSWER_TYPE_CARD:
            answer.shuffleAnswers = [NSNumber numberWithBool:NO];
            break;
        case ANSWER_TYPE_WORD_RESPONSE:
            answer.shuffleAnswers = [NSNumber numberWithBool:NO];
            break;
        case ANSWER_TYPE_ORDER:
            answer.shuffleAnswers = [NSNumber numberWithBool:YES];
            break;
        case ANSWER_TYPE_KEY_WORD_ITEM_MATCH:
            answer.shuffleAnswers = [NSNumber numberWithBool:NO];
            break;
        default:
            answer.shuffleAnswers = [NSNumber numberWithBool:YES];
            break;
    }
}

-(NSInteger)addMediaInList:(LayXmlNode*)mediaListNode to:(NSManagedObject*)managedObject {
    NSInteger numberOfMediaAdded = 0;
    if(mediaListNode) {
        NSNumber *numberOfSectionMediaList = nil;
        NSArray* childNodeList = [mediaListNode childNodeList];
        if([childNodeList count] > 0) {
            for (LayXmlNode* mediaNode in childNodeList) {
                LayXmlMediaNodeData* mediaNodeData = [self mediaNodeData:mediaNode];
                if(mediaNodeData) {
                    Media *media = [self->importCatalog mediaByName:mediaNodeData.fileRef];
                    if(!media) {
                        media = [self->importCatalog mediaInstance];
                        [self fillMediaFromNodeData:mediaNodeData into:media];
                    }
                    if(media && media.data) {
                        if([managedObject isKindOfClass:[Answer class]]) {
                            Answer *answer = (Answer*)managedObject;
                            [answer addMedia:media];
                        } else if([managedObject isKindOfClass:[Section class]]) {
                            Section* section = (Section*)managedObject;
                            if(!numberOfSectionMediaList) {
                                numberOfSectionMediaList = [section newGroupNumber];
                            }
                            SectionMedia *sectionMedia = [section sectionMediaInstance];
                            sectionMedia.mediaRef = media;
                            sectionMedia.groupNumber = numberOfSectionMediaList;
                        }
                        numberOfMediaAdded++;
                    }
                }
            }
        } else {
            NSString *message = [NSString stringWithFormat:@"Element:%@ is required for element:%@!", LAY_XML_TAG_MEDIA, mediaListNode];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
    }
    return numberOfMediaAdded;
}

// Explanation
-(void) addExplanationFrom:(LayXmlNode*)xmlNode to:(NSManagedObject*)managedObject {
    NSString* explanationReferencAttrName = @"explanation";
    NSString *explanationRef = [xmlNode valueOfAttribute:explanationReferencAttrName];
    if(explanationRef) {
        Explanation *explanation = [self->importCatalog explanationByName:explanationRef];
        if(!explanation) {
            explanation = [self->importCatalog explanationInstance];
        }
        if(explanation) {
            explanation.name = explanationRef;
            [self rememberExplanation:explanation];
            if([managedObject isKindOfClass:[Answer class]]) {
                Answer *answer = (Answer*)managedObject;
                [answer setExplanation:explanation];
            } else if([managedObject isKindOfClass:[AnswerItem class]]) {
                AnswerItem *answerItem = (AnswerItem*)managedObject;
                [answerItem setExplanation:explanation];
            } else {
                MWLogError(_classObj, @"Managed-Object:%@ does not support an explanation!", managedObject);
            }
        }
    }
}

// AnswerItem-Data
-(void)addAnswerNodeData:(LayXmlNode*)answerNode toAnswer:(Answer*)answer {
    NSString* nameAnswerNode = @"answer";
    NSString *nameAnswerItemNode = @"answerItem";
    NSString *nameTextNode = @"text";
    NSString *answerItemAttrCorrect = @"correct";
    NSString *answerAttrStyle = @"style";
    NSString *nameMediaNode = (NSString*)LAY_XML_TAG_MEDIA;
    
    // style
    NSString* style = [answerNode valueOfAttribute:answerAttrStyle];
    if(style) {
        answer.style = style;
    }
    
    // shuffleAnswers
    NSString* shuffle = [answerNode valueOfAttribute:(NSString*)LAY_XML_ATTRIBUTE_SHUFFLE_ANSWERS];
    if(shuffle) {
        answer.shuffleAnswers = [NSNumber numberWithBool:[shuffle boolValue]];
    }
    
    NSArray *answerItemList = [answerNode childNodeList];
    if([answerItemList count]>0) {
        for (LayXmlNode* answerItemNode in answerItemList) {
            if([answerItemNode.name isEqualToString:nameAnswerItemNode]) {
                NSString* correct = [answerItemNode valueOfAttribute:answerItemAttrCorrect];
                if(correct) {
                    LayXmlNode *textNode = [answerItemNode nodeByName:nameTextNode];
                    NSString *content = [textNode content];
                    AnswerItem *answerItem = [answer answerItemInstance];
                    answerItem.text = content;
                    answerItem.correct = [NSNumber numberWithBool:[correct boolValue]];
                    // check for Media
                    LayXmlNode *mediaNode = [answerItemNode nodeByName:nameMediaNode];
                    if(mediaNode) {
                        // media is optional
                        LayXmlMediaNodeData* mediaNodeData = [self mediaNodeData:mediaNode];
                        if(mediaNodeData && mediaNodeData.mediaFileContent) {
                            Media* media = [self->importCatalog mediaByName:mediaNodeData.fileRef];
                            if(!media) {
                                media= [self->importCatalog mediaInstance];
                                [self fillMediaFromNodeData:mediaNodeData into:media];
                            }
                            [answerItem setMediaItem:media];
                        } else {
                            NSString *message = [NSString stringWithFormat:@"The referenced resource:%@ does not exist!", mediaNodeData.fileRef];
                            [self adjustErrorWith:LayImportCatalogResourceError andMessage:message];
                        }
                    }
                    // explanation - otional attribute
                    [self addExplanationFrom:answerItemNode to:answerItem];
                    
                    // groupName  - optional attribute
                    NSString *groupName = [answerItemNode valueOfAttribute:(NSString*)LAY_XML_ATTRIBUTE_EQUAL_GROUP_NAME];
                    if( groupName ) {
                        answerItem.equalGroupName = groupName;
                    }
                    
                    
                    // keyWordList
                    LayXmlNode *keyWordListNode = [answerItemNode nodeByName:(NSString*)LAY_XML_TAG_KEY_WORD_LIST];
                    answerItem.longTermWordList = [keyWordListNode content];
                    
                    // Link to answer
                    [answer addAnswerItem:answerItem];
                } else {
                    NSString *message = [NSString stringWithFormat:@"Element:%@ must have an attribute:%@!", answerItemNode, answerItemAttrCorrect];
                    [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
                }
            } // if
        }//for answerItem-node
    } else {
        NSString *message = [NSString stringWithFormat:@"Element:%@ must have at least one element named:%@!", nameAnswerNode, nameAnswerItemNode];
        [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
    }
}

// Media for answerItem
-(LayXmlMediaNodeData*)mediaNodeData:(LayXmlNode*)mediaNode {
    LayXmlMediaNodeData* nodeData = nil;
    NSString *nameMediaNode = (NSString*)LAY_XML_TAG_MEDIA;
    NSString *mediaAttrType = @"type";
    NSString *mediaAttrRef = @"ref";
    NSString *mediaAttrLabel = @"label";
    NSString *mediaAttrShowLabel = @"showLabelBeforeEvaluated";
    if([mediaNode.name isEqualToString:nameMediaNode]) {
        NSString *mediaType = [mediaNode valueOfAttribute:mediaAttrType];
        NSString *mediaRef = [mediaNode valueOfAttribute:mediaAttrRef];
        NSString *mediaLabel = [mediaNode valueOfAttribute:mediaAttrLabel];
        NSString *mediaShowLabel = [mediaNode valueOfAttribute:mediaAttrShowLabel];
        if(mediaType) {
            if(mediaRef && [mediaRef length] > 0) {
                nodeData = [self mediaNodeDataBy:mediaRef andType:mediaType];
                nodeData.label = mediaLabel;
                nodeData.showLabel = mediaShowLabel;
            } else {
                NSString *message = [NSString stringWithFormat:@"Value for mediaRef is empty!"];
                [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
            }
        } else {
            NSString *message = [NSString stringWithFormat:@"Attribute:%@ of element:%@ is required!", mediaAttrType, nameMediaNode];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
    } else {
        NSString *message = [NSString stringWithFormat:@"Element:%@ is not a media-element!", mediaNode.name];
        [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
    }
    return nodeData;
}

// Media for answerItem
-(LayXmlMediaNodeData*)mediaNodeDataBy:(NSString*)reference andType:(NSString*)type {
    LayXmlMediaNodeData* nodeData = nil;
    NSString *catalogDirectory = [[self->catalogFile path] stringByDeletingLastPathComponent];
    NSString *pathToMediaFile = [catalogDirectory stringByAppendingPathComponent:reference];
    LayMediaType mediaType = [LayMediaTypeClass typeByString:type];
    NSString* fileExtension = [LayMediaTypeClass extensionFromFileName:reference];
    LayMediaFormat mediaFormat = [LayMediaTypeClass formatByExtension:fileExtension];
    if(mediaType!=LAY_MEDIA_UNDEFINED && mediaFormat!=LAY_FORMAT_UNDEFINED) {
        nodeData = [LayXmlMediaNodeData new];
        nodeData.mediaType = mediaType;
        nodeData.mediaFormat = mediaFormat;
        nodeData.fileRef = reference;
    } else {
        NSString *message = [NSString stringWithFormat:@"Not supported media-type:%@!", fileExtension];
        [self adjustErrorWith:LayImportCatalogResourceError andMessage:message];
    }
    MWLogDebug(_classObj, @"Combined path to media-file is:%@", pathToMediaFile);
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    if([fileMngr fileExistsAtPath:pathToMediaFile] && nodeData) {
        NSData *contentOfFile = [fileMngr contentsAtPath:pathToMediaFile];
        if(contentOfFile) {
            nodeData.mediaFileContent = contentOfFile;
            MWLogDebug(_classObj, @"Valid media for reference:%@!", reference );
        } else {
            NSString *message = [NSString stringWithFormat:@"Could not read content of file:%@!", pathToMediaFile];
            [self adjustErrorWith:LayImportCatalogResourceError andMessage:message];
        }
    } else {
        NSString *message = [NSString stringWithFormat:@"Path:%@ to media-file does not exist!", pathToMediaFile];
        [self adjustErrorWith:LayImportCatalogResourceError andMessage:message];
    }
    return nodeData;
}

-(void)fillMediaFromNodeData:(LayXmlMediaNodeData*)mediaNode into:(Media*)media {
    media.name = mediaNode.fileRef;
    [media setMediaData:mediaNode.mediaFileContent type:mediaNode.mediaType format:mediaNode.mediaFormat];
}

-(void)fillFurtherInfoFrom:(LayXmlMediaNodeData*)mediaNode into:(Media*)media {
    media.label = mediaNode.label;
    media.showLabel = mediaNode.showLabel;
}

-(void)catchTopicReferenceFromNode:(LayXmlNode*)nodeWithTopic to:(NSManagedObject*)managedObject {
    NSString *topicReferencAttrName = @"topic";
    NSString* attrValue = [nodeWithTopic valueOfAttribute:topicReferencAttrName];
    if(attrValue) {
        Topic *topic = [self->importCatalog topicInstanceByName:attrValue];
        if(!topic) {
            topic = [self->importCatalog topicInstance];
            topic.name = attrValue;
        }
        if([managedObject isKindOfClass:[Question class]]) {
            Question *question = (Question*)managedObject;
            question.topicRef = topic;
        } else if([managedObject isKindOfClass:[Explanation class]]) {
            Explanation *explanation = (Explanation*)managedObject;
            [explanation setTopic:topic];
        }
    } else {
        // add Question or Explanation to default topic
        Topic *topic = [self->importCatalog topicInstanceByName:(NSString*)NAME_OF_DEFAULT_TOPIC];
        if(!topic) {
            topic = [self->importCatalog topicInstance];
            [topic setTopicAsSelected];
            topic.name = (NSString*)NAME_OF_DEFAULT_TOPIC;
            topic.title = (NSString*)TITLE_OF_DEFAULT_TOPIC;
            [topic setTopicNumber:NUMBER_OF_DEFAULT_TOPIC];
        }
        if([managedObject isKindOfClass:[Question class]]) {
            Question *question = (Question*)managedObject;
            [question setTopic:topic];
        } else if([managedObject isKindOfClass:[Explanation class]]) {
            Explanation *explanation = (Explanation*)managedObject;
            [explanation setTopic:topic];
        }
    }
}


//
// catch explanations
//

-(void)catchExplanationData:(LayXmlNode*)explanationNode {
    NSString* nameExplanationNode = @"explanation";
    NSString *explanationReferencAttrName = @"name";
    if([explanationNode.name isEqualToString:nameExplanationNode]) {
        NSString *valueForName = [explanationNode valueOfAttribute:explanationReferencAttrName];
        if(valueForName) {
            [self catchExplanationWithName:valueForName andExplanationNode:explanationNode];
        } else {
            NSString* message = [NSString stringWithFormat:@"Attribute:%@ is required for element:%@!", explanationReferencAttrName, explanationNode];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
    } else {
        NSString *message = [NSString stringWithFormat:@"Element:%@ is not an explanation element!", explanationNode.name];
        [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
    }
}

-(void)catchExplanationWithName:(NSString*)nameOfExplanation andExplanationNode:(LayXmlNode*)explanationNode {
    NSString* nameExplanationTitleNode = (NSString*)LAY_XML_TAG_TITLE;
    LayXmlNode *titleNode = [explanationNode nodeByName:nameExplanationTitleNode];
    if(titleNode) {
        [self setImportStep];
        Explanation *explanation = [self referencedExplanationByName:nameOfExplanation];
        if(!explanation) {
            // Create a new explanation which is never referenced by an answer or answerItem.
            explanation = [self->importCatalog explanationInstance];
            explanation.name = nameOfExplanation;
        }
        explanation.number = [NSNumber numberWithUnsignedInteger:++self->explanationCounter];
        explanation.title = [titleNode content];
        BOOL sectionNodesFound = NO;
        for (LayXmlNode *sectionNode in [explanationNode childNodeListByName:(NSString*)LAY_XML_TAG_SECTION]) {
            Section *section = [self sectionFromNode:sectionNode];
            if(sectionNode) {
                sectionNodesFound = YES;
                section.number = [explanation numberForSection];
                [explanation addSectionRefObject:section];
            }
        }
        if(!sectionNodesFound) {
            NSString *message = [NSString stringWithFormat:@"Element:%@ is required for element:%@ with name:%@!", (NSString*)LAY_XML_TAG_SECTION, explanationNode, explanation.name];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
        
        // optional attributes
        [self catchTopicReferenceFromNode:explanationNode to:explanation];
        
        // optional elements
        [self addLinkedResourceListFrom:explanationNode to:explanation];
        
    } else {
        NSString *message = [NSString stringWithFormat:@"Element:%@ is required for element:%@!", nameExplanationTitleNode, explanationNode];
        [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
    }
}

-(Section*)sectionFromNode:(LayXmlNode*)sectionNode {
    Section *section = nil;
    NSString* nameOfSectionNode = (NSString*)LAY_XML_TAG_SECTION;
    NSString* nameOfSectionTitleNode = (NSString*)LAY_XML_TAG_TITLE;
    NSString* nameOfSectionTextNode = (NSString*)LAY_XML_TAG_TEXT;
    NSString* nameOfQuestionNode = (NSString*)LAY_XML_TAG_QUESTION;
    NSString* nameAttName = (NSString*)LAY_XML_ATTRIBUTE_NAME;
    if([sectionNode.name isEqualToString:nameOfSectionNode]) {
        section = [self->importCatalog sectionInstance];
        BOOL textOrMediaNodesAdded = NO;
        NSArray *childeNodeList = [sectionNode childNodeList];
        BOOL sectionGroupToggle = YES;
        NSNumber *currentGroupNumber = nil;
        if([childeNodeList count] > 0) {
            for (LayXmlNode *sectionChildNode in childeNodeList) {
                if([sectionChildNode.name isEqualToString:nameOfSectionTextNode]) {
                    SectionText *sectionText = [section sectionTextInstance];
                    if(sectionGroupToggle) {
                        sectionGroupToggle = NO;
                        currentGroupNumber = [section newGroupNumber];
                    }
                    sectionText.groupNumber = currentGroupNumber;
                    sectionText.text = [sectionChildNode content];
                    textOrMediaNodesAdded = YES;
                } else if([sectionChildNode.name isEqualToString:(NSString*)LAY_XML_TAG_MEDIALIST]) {
                    NSInteger numberOfAddedMedia = [self addMediaInList:sectionChildNode to:section];
                    if(numberOfAddedMedia > 0) {
                        textOrMediaNodesAdded = YES;
                    }
                    sectionGroupToggle = YES;
                } else if( [sectionChildNode.name isEqualToString:nameOfQuestionNode] ) {
                    NSString *nameOfQuestion = [sectionChildNode valueOfAttribute:nameAttName];
                    if(nameOfQuestion) {
                        if(![self->importCatalog containsQuestionWithName:nameOfQuestion]){
                            NSString* message = [NSString stringWithFormat:@"Question with name:%@ is not defined! Ignore question in section!", nameOfQuestion];
                            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
                        } else if(!section.sectionQuestionRef) {
                            currentGroupNumber = [section newGroupNumber];
                            SectionQuestion *sq = [section sectionQuestionInstance];
                            sq.groupNumber = currentGroupNumber;
                            Question *question = [self->importCatalog questionByName:nameOfQuestion];
                            sq.questionRef = question;
                            sectionGroupToggle = YES;
                        } else {
                            MWLogWarning(_classObj, @"A section can contain only one question reference! Ignore question:%@!", nameOfQuestion);
                        }
                    } else {
                        NSString* message = [NSString stringWithFormat:@"Attribute:%@ required for element:%@!", nameAttName, nameOfQuestionNode];
                        [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
                    }
                }
            }
        }
        
        if(textOrMediaNodesAdded){
           // optional title
            LayXmlNode *sectionTitleNode = [sectionNode nodeByName:nameOfSectionTitleNode];
            if(sectionTitleNode) {
                section.title = [sectionTitleNode content];
            }
        } else {
            [self->importCatalog.managedObjectContext deleteObject:section];
            section = nil;
            NSString *message = [NSString stringWithFormat:@"A section must have at least one text oder mediaList child element!"];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }

    } else {
        NSString *message = [NSString stringWithFormat:@"Section expected not:%@!", sectionNode.name];
        [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
    }
    return section;
}

-(Explanation*)referencedExplanationByName:(NSString*)name {
    Explanation *explanation = [self->explanationRefMap valueForKey:name];
    if(!explanation) {
        NSString *message = [NSString stringWithFormat:@"The explanation with name:%@ is never referenced!", name];
        MWLogWarning(_classObj, message);
    }
    return explanation;
}

-(Resource*)referencedResourceByName:(NSString*)name {
    Resource *resource = [self->resourceRefMap valueForKey:name];
    if(!resource) {
        NSString *message = [NSString stringWithFormat:@"The resource with name:%@ is never referenced!", name];
        MWLogWarning(_classObj, message);
    }
    return resource;
}

//
// catch further information about used/references media-items like labels etc.
//
-(void)catchMediaList:(LayXmlNode*)mediaNode {
    LayXmlMediaNodeData* mediaNodeData = [self mediaNodeData:mediaNode];
    if(mediaNodeData) {
        Media *media = [self->importCatalog mediaByName:mediaNodeData.fileRef];
        if(media) {
            [self fillFurtherInfoFrom:mediaNodeData into:media];
        } else {
            NSString *message = [NSString stringWithFormat:@"Media-Item:%@ is never referenced in the catalog!", mediaNodeData.fileRef];
            MWLogWarning(_classObj, message);
        }
    }
}

//
// catch further information about topics.
//
-(void)catchTopicList:(LayXmlNode*)topicNode {
    NSString *nameTitleNode = @"title";
    NSString *nameTextNode = (NSString*)LAY_XML_TAG_TEXT;
    NSString *topicAttrName = @"name";
    NSString *nameMediaNode = (NSString*)LAY_XML_TAG_MEDIA;
    NSString *nameOfTopic = [topicNode valueOfAttribute:topicAttrName];
    if(nameOfTopic) {
        LayXmlNode *titleNode = [topicNode nodeByName:nameTitleNode];
        if(titleNode) {
            Topic* topic = [self->importCatalog topicInstanceByName:nameOfTopic];
            if(topic) {
                [topic setTopicAsSelected];
                [topic setTopicNumber:self->topicCounter++];
                topic.title = [titleNode content];
                LayXmlNode *textNode = [topicNode nodeByName:nameTextNode];
                if(textNode) {
                    topic.text = [textNode content];
                }
                LayXmlNode *mediaNode = [topicNode nodeByName:nameMediaNode];
                if(mediaNode) {
                    LayXmlMediaNodeData* mediaNodeData = [self mediaNodeData:mediaNode];
                    if(mediaNodeData && mediaNodeData.mediaFileContent) {
                        Media* media = [self->importCatalog mediaByName:mediaNodeData.fileRef];
                        if(!media) {
                            media= [self->importCatalog mediaInstance];
                            [self fillMediaFromNodeData:mediaNodeData into:media];
                        }
                        [topic setMedia:media];
                    } else {
                        NSString *message = [NSString stringWithFormat:@"The referenced resource:%@ does not exist!", mediaNodeData.fileRef];
                        [self adjustErrorWith:LayImportCatalogResourceError andMessage:message];
                    }
                }
            } else {
                MWLogWarning(_classObj, @"Ignore topic with name:%@  because its not referenced!");
            }
            
        } else {
            NSString *message = [NSString stringWithFormat:@"A Sub-Node:%@ is required for a topic!", nameTitleNode];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
        
    } else {
        NSString *message = [NSString stringWithFormat:@"Attribute:%@ is required for a topic!", topicAttrName];
        [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
    }
}

//
// catch further information about resources
//
-(void)catchResourceList:(LayXmlNode*)resouceNode {
    NSString *nameResourceNode = @"resource";
    NSString *resourceAttrName = @"name";
    if([resouceNode.name isEqualToString:nameResourceNode]) {
        NSString *valueForName = [resouceNode valueOfAttribute:resourceAttrName];
        if(valueForName) {
            [self catchResourceWithName:valueForName andResourceNode:resouceNode];
        } else {
            NSString* message = [NSString stringWithFormat:@"Attribute:%@ is required for element:%@!", resourceAttrName, resouceNode];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
    } else {
        NSString *message = [NSString stringWithFormat:@"Element:%@ is not an resource element!", resouceNode.name];
        [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
    }
}

-(void)catchResourceWithName:(NSString*)nameOfResource andResourceNode:(LayXmlNode*)resourceNode {
    NSString *resourceAttrType = @"type";
    NSString *nameTitleNode = @"title";
    NSString *nameLinkNode = (NSString*)LAY_XML_TAG_LINK;
    Resource *resource = [self referencedResourceByName:nameOfResource];
    if(!resource) {
        // Create a new resource which is not referenced by a question or explanation.
        resource = [self->importCatalog resourceInstance];
        resource.name = nameOfResource;
    }
    LayXmlNode *titleNode = [resourceNode nodeByName:nameTitleNode];
    if(titleNode) {
        resource.title = [titleNode content];
        if([resource.title length]==0) {
            NSString *message = [NSString stringWithFormat:@"No value set for element:%@!", titleNode];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
    } else {
        NSString *message = [NSString stringWithFormat:@"Element:%@ is required for element:%@!", nameTitleNode, resourceNode];
        [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
    }
    
    LayXmlNode *linkNode = [resourceNode nodeByName:nameLinkNode];
    if(linkNode) {
        resource.link = [linkNode content];
        if([resource.title length]==0) {
            NSString *message = [NSString stringWithFormat:@"No value set for element:%@!", linkNode];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        } else {
            NSURL *url = [NSURL URLWithString:resource.link];
            if(!url) {
                NSString *message = [NSString stringWithFormat:@"No valid link:%@!", resource.link];
                [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
            }
        }
    } else {
        NSString *message = [NSString stringWithFormat:@"Element:%@ is required for element:%@!", nameLinkNode, resourceNode];
        [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
    }
    
    LayXmlNode *textNode = [resourceNode nodeByName:(NSString*)LAY_XML_TAG_TEXT];
    if(textNode) {
        resource.text = [textNode content];
    }
    
    NSString *valueForType = [resourceNode valueOfAttribute:resourceAttrType];
    if(valueForType) {
         LayResourceTypeIdentifier resourceTypeId = [LayResourceType resourceTypeByString:valueForType];
        if(resourceTypeId == RESOURCE_TYPE_UNKNOWN) {
            NSString* message = [NSString stringWithFormat:@"Invalid type of resource:%@!", valueForType];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        } else {
            [resource setResourceType:resourceTypeId];
        }
    } else {
        NSString* message = [NSString stringWithFormat:@"Element:%@ must have an attribute named:%@!", resourceNode, resourceAttrType];
        [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
    }
    
    resource.number = [NSNumber numberWithUnsignedInteger:++self->resourceCounter];
}

// add introduction
-(void) addIntroToQuestion:(LayXmlNode*)questionNode to:(Question*)question {
    LayXmlNode *introNode = [questionNode nodeByName:(NSString*)LAY_XML_TAG_INTRODUCTION];
    if(introNode) {
        MWLogDebug(_classObj, @"Process introduction for question:%@", question.name);
        NSArray *sectionNodeList = [introNode childNodeListByName:(NSString*)LAY_XML_TAG_SECTION];
        if([sectionNodeList count] > 0) {
            NSUInteger currentSectionNumber = 0;
            Introduction *intro = nil;
            for (LayXmlNode* sectionNode in sectionNodeList) {
                Section *section = [self sectionFromNode:sectionNode];
                if(section) {
                    section.number = [NSNumber numberWithUnsignedInteger:++currentSectionNumber];
                    if(!intro) intro = [question introductionInstance];
                    [intro addSectionRefObject:section];
                } else {
                    MWLogError(_classObj, @"Processing introduction for question:%@ failed!", question.name);
                }
            }
        } else {
            NSString* message = [NSString stringWithFormat:@"Element:%@ must contain at least one child named:%@", LAY_XML_TAG_INTRODUCTION, LAY_XML_TAG_SECTION];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
    }
}


// add linked resource
-(void) addLinkedResourceListFrom:(LayXmlNode*)xmlNode to:(NSManagedObject*)managedObject {
    NSString *nameResourceNode = @"resource";
    NSString *nameResourceListNode = @"resourceList";
    LayXmlNode *resourceListNode = [xmlNode nodeByName:nameResourceListNode];
    if(resourceListNode) {
        NSArray *resourceNodeList = [resourceListNode childNodeList];
        if([resourceNodeList count]>0) {
            for (LayXmlNode *node in resourceNodeList) {
                [self addResourceFrom:node to:managedObject];
            }
        } else {
            NSString* message = [NSString stringWithFormat:@"Element:%@ must have at least one child named:%@!", nameResourceListNode, nameResourceNode];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
    }
}

-(void) addResourceFrom:(LayXmlNode*)resourceNode to:(NSManagedObject*)managedObject {
    NSString *nameResourceNode = @"resource";
    NSString *resourceAttrName = @"name";
    if([resourceNode.name isEqualToString:nameResourceNode]) {
         NSString *nameOfResource = [resourceNode valueOfAttribute:resourceAttrName];
        if(nameOfResource) {
            Resource *resource = [self->importCatalog resourceByName:nameOfResource];
            if(!resource) {
                resource = [self->importCatalog resourceInstance];
            }
            if(resource) {
                resource.name = nameOfResource;
                [self rememberResource:resource];
                if([managedObject isKindOfClass:[Question class]]) {
                    Question *question = (Question*)managedObject;
                    [question addResourceRefObject:resource];
                } else if([managedObject isKindOfClass:[Explanation class]]) {
                    Explanation *explanation = (Explanation*)managedObject;
                    [explanation addResourceRefObject:resource];
                } else {
                    MWLogError(_classObj, @"Managed-Object:%@ can not be linked with a resource!", managedObject);
                }
            }
        } else {
            NSString* message = [NSString stringWithFormat:@"Element:%@ must have an attribute named:%@!", resourceNode, resourceAttrName];
            [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
        }
    } else {
        NSString* message = [NSString stringWithFormat:@"Element:%@ accepts child notes named:%@ only!", resourceNode.parentNode.name, nameResourceNode];
        [self adjustErrorWith:LayImportCatalogParsingError andMessage:message];
    }
}


//
-(void)countExplanationNodes:(LayXmlNode *)explanationNode {
    self->explanationCounter++;
    [self setImportStep];
}

-(void)countQuestionNodes:(LayXmlNode *)questionNode {
    self->questionCounter++;
    [self setImportStep];
}

-(void)setImportStep {
    if(self->importProgressStateDelegate) {
        self->importStepCounter++;
        [self->importProgressStateDelegate setStep:self->importStepCounter];
    }
}

@end

//
// LayXmlMediaNodeData
//
@implementation LayXmlMediaNodeData

@synthesize mediaType, mediaFormat, mediaFileContent, label, fileRef, showLabel;

@end
