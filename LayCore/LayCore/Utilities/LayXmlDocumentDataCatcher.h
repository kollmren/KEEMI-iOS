//
//  XmlDocumentDataCatcher.h
//  
//
//  Created by Rene Kollmorgen on 07.05.13.
//
//

#import <Foundation/Foundation.h>

@class LayError;
@interface LayXmlDocumentDataCatcher : NSObject<NSXMLParserDelegate> {
    @private
    NSURL *pathToXmlFile;
    NSMutableArray *registeredPathList;
}

-(id)initWithPathToXmlFile:(NSURL*)pathToXmlFile;

// pathToElement: e.g. /root/a/b
// callback: must have the signature: func:(LayXmlNode*)node
-(BOOL)registerPath:(id)target action:(SEL)callback forPath:(NSString*)pathToElement;

// If the registered path is processed the parser stops further processing.
-(BOOL)registerPathStopParsing:(id)target action:(SEL)callback forPath:(NSString*)pathToElement;

-(BOOL)unregisterPath:(NSString*)pathToElement;

-(BOOL) startCatching:(LayError**)error;

-(BOOL) abortCatching;

@end
