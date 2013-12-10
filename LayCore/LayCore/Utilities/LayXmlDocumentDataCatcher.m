//
//  XmlDocumentDataCatcher.m
//  
//
//  Created by Rene Kollmorgen on 07.05.13.
//
//

#import "LayXmlDocumentDataCatcher.h"

#import "LayXmlPath.h"
#import "LayXmlNode.h"
#import "LayError.h"

#define MW_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_INFO

#import "MWLogging.h"

//
// LayRegisteredPath
//
@interface LayRegisteredPath : NSObject
@property (nonatomic) LayXmlPath* xmlPath;
@property (nonatomic) id target;
@property (nonatomic) SEL callback;
@property (nonatomic) LayXmlNode* registeredNode;
@property (nonatomic) BOOL stopParsing;

+(LayRegisteredPath*) withPath:(NSString*)path object:(id)target andAction:(SEL)callback;

@end

//
// LayXmlDocumentDataCatcher
//
@interface LayXmlDocumentDataCatcher() {
    LayXmlPath* currentXmlPath;
    BOOL withinRegisteredPath;
    LayXmlNode *currentXmlNode;
    NSXMLParser *parser;
    BOOL abortedParsing;
}
@end

@implementation LayXmlDocumentDataCatcher

static Class _classObj = nil;

+(void) initialize {
    _classObj = [LayXmlDocumentDataCatcher class];
}

-(id)initWithPathToXmlFile:(NSURL*)pathToXmlFile_ {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:[pathToXmlFile_ path]]) {
        MWLogError(_classObj, @"File:%@ does not exist!", [pathToXmlFile_ path]);
        return nil;
    }
    self = [super init];
    if(self) {
        self->abortedParsing = NO;
        self->pathToXmlFile = pathToXmlFile_;
        self->currentXmlPath = [[LayXmlPath alloc]init];
        self->withinRegisteredPath = NO;
        self->registeredPathList = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

// pathToElement: e.g. /root/a/b
// callback: must have the signature: func:(LayXmlNode*)node
-(BOOL)registerPath:(id)target action:(SEL)callback forPath:(NSString*)pathToElement {
    BOOL registered = NO;
    LayRegisteredPath *regPath = [self registerPath:target :callback :pathToElement];
    if(regPath) {
        registered = YES;
    }
    return registered;
}

-(BOOL)registerPathStopParsing:(id)target action:(SEL)callback forPath:(NSString*)pathToElement {
    BOOL registered = NO;
    LayRegisteredPath *regPath = [self registerPath:target :callback :pathToElement];
    if(regPath) {
        regPath.stopParsing = YES;
        registered = YES;
    }
    return registered;
}

-(BOOL)unregisterPath:(NSString*)pathToElement {
    BOOL unregistered = NO;
    LayRegisteredPath* registeredPath = nil;
    NSUInteger idxRegPath = 0;
    for (LayRegisteredPath *regPath in self->registeredPathList) {
        LayXmlPath *pathOfRegPath = regPath.xmlPath;
        if([[pathOfRegPath path] isEqualToString:pathToElement]) {
            registeredPath = regPath;
            break;
        }
        ++idxRegPath;
    }
    if(registeredPath) {
        [self->registeredPathList removeObjectAtIndex:idxRegPath];
        unregistered = YES;
    }
    return unregistered;
}

-(BOOL) startCatching:(LayError**)layError {
    BOOL parsed = NO;
    self->parser = [[NSXMLParser alloc]initWithContentsOfURL:self->pathToXmlFile];
    if(self->parser) {
        [self->parser setDelegate:self];
        parsed = [parser parse];
        NSError *error = [parser parserError];
        if(error) {
            *layError = [[LayError alloc]initWithIdentifier:LayImportCatalogParsingError andMessage:[error localizedDescription]];
            MWLogError(_classObj, @"Error from parser:code:%d, message:%@!", [error code], [error localizedDescription]);
        } else if(self->abortedParsing) {
            self->abortedParsing = NO;
            parsed = NO;
        }
    } else {
        MWLogError(_classObj, @"Could not create parser!");
    }
    return parsed;
}

-(BOOL) abortCatching {
    if(self->parser) {
        [self->parser abortParsing];
        self->currentXmlNode = nil;
        [self->currentXmlPath clear];
        self->abortedParsing = YES;
        MWLogInfo(_classObj, @"Aborted parsing!");
    }
    return abortedParsing;
}

//
// Private
//
-(LayRegisteredPath*)registeredPath:(LayXmlPath*)xmlPath {
    LayRegisteredPath* registeredPath = nil;
    for (LayRegisteredPath *regPath in self->registeredPathList) {
        LayXmlPath *pathOfRegPath = regPath.xmlPath;
        if([pathOfRegPath isEqual:xmlPath]) {
            registeredPath = regPath;
        }
    }
    if(registeredPath) {
        MWLogDebug(_classObj, @"Found registerd path:%@", [registeredPath.xmlPath path]);
    }
    return registeredPath;
}

-(LayRegisteredPath*)registerPath:(id)target :(SEL)callback :(NSString*)pathToElement {
    LayRegisteredPath* regPath = nil;
    if([target respondsToSelector:callback]) {
        BOOL unregistered = [self unregisterPath:pathToElement];
        if(unregistered) {
            MWLogDebug(_classObj, @"Unregistered path:%@!", pathToElement);
        }
        MWLogDebug(_classObj, @"Register path:%@", pathToElement);
        regPath = [LayRegisteredPath withPath:pathToElement object:target andAction:callback];
        [self->registeredPathList addObject:regPath];
    } else {
        MWLogError(_classObj, @"Target does not implement selector!");
    }
    
    return regPath;
}

//
// NSXMLParserDelegate
//
- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    [self->currentXmlPath pushElementWithName:elementName];
    
    if(self->withinRegisteredPath) {
        LayXmlNode *node = [[LayXmlNode alloc]initWithName:elementName];
        [self addAttributes:attributeDict toNode:node];
        if(!self->currentXmlNode) {
            MWLogError(_classObj, @"Internal error!");
        }
        [self->currentXmlNode addChildNode:node];
        self->currentXmlNode = node;
    } else {
        LayRegisteredPath *registeredPath = [self registeredPath:self->currentXmlPath];
        if(registeredPath) {
            LayXmlNode *node = [[LayXmlNode alloc]initWithName:elementName];
            node.contextPath = [self->currentXmlPath path];
            [self addAttributes:attributeDict toNode:node];
            registeredPath.registeredNode = node; // dont free the memory for the root-node
            self->currentXmlNode = node;
            self->withinRegisteredPath = YES;
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)str
{
    if(self->withinRegisteredPath) {
        NSString *contentTrimmed = [str stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        if([contentTrimmed length] > 0) {
            [self->currentXmlNode appendContent:contentTrimmed];
        }
    }
}

- (void)parser:(NSXMLParser *)parser_
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if(self->withinRegisteredPath) {
        LayRegisteredPath *registeredPath = [self registeredPath:self->currentXmlPath];
        if(registeredPath) {
            if(self->currentXmlNode.hasContent) {
                MWLogDebug(_classObj, @"Trim whitespace and newline characters!", [self->currentXmlPath path]);
                NSString *contentTrimmed = [self->currentXmlNode.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                self->currentXmlNode.content = contentTrimmed;
            }
            MWLogDebug(_classObj, @"Perform selector for path:%@!", [self->currentXmlPath path]);
            [registeredPath.target performSelector:registeredPath.callback withObject:self->currentXmlNode];
            self->withinRegisteredPath = NO;
            self->currentXmlNode = nil;
            registeredPath.registeredNode = nil; // free node-tree
            if(registeredPath.stopParsing) {
                MWLogDebug(_classObj, @"Stop parsing!");
                [parser_ abortParsing];
                [self->currentXmlPath clear];
                self->abortedParsing = YES;
            }
        } else {
            self->currentXmlNode = self->currentXmlNode.parentNode;
        }
    }
    
    if(!self->abortedParsing) [self->currentXmlPath popElement];
}

-(void)addAttributes:(NSDictionary*)attributes toNode:(LayXmlNode*)node {
    for (NSString* attrName in [attributes allKeys]) {
        NSString *attrValue = [attributes valueForKey:attrName];
        [node addAttribute:attrName value:attrValue];
    }
}

@end

//
// LayRegisteredPath
//
@implementation LayRegisteredPath

@synthesize xmlPath, target, callback, registeredNode, stopParsing;

+(LayRegisteredPath*) withPath:(NSString*)path object:(id)target andAction:(SEL)callback {
    LayXmlPath *xmlPath = [[LayXmlPath alloc]initWithXmlPath:path];
    LayRegisteredPath *regsiteredPath = [LayRegisteredPath new];
    regsiteredPath.xmlPath = xmlPath;
    regsiteredPath.target = target;
    regsiteredPath.callback = callback;
    regsiteredPath.stopParsing = NO;
    return regsiteredPath;
}

@end
