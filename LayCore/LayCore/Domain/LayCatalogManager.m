//
//  LayCatalogManager.m
//  LayCore
//
//  Created by Rene Kollmorgen on 22.01.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayCatalogManager.h"
#import "MWLogging.h"

@implementation LayCatalogManager

@synthesize currentSelectedCatalog, currentSelectedQuestion;
@synthesize currentCatalogIsUsedInQuestionSession, currentCatalogShouldBeOpenedDirectly;
@synthesize currentCatalogShouldBeQueriedDirectly, currentCatalogShouldBeLearnedDirectly;
@synthesize pendingCatalogToImport, selectedQuestions, selectedExplanations;

static Class g_classObj = nil;

+(void)initialize {
    g_classObj = [LayCatalogManager class];
}

+(LayCatalogManager*) instance {
    static LayCatalogManager* instance_ = nil;
    @synchronized(self)
    {
        if (instance_ == NULL) {
            instance_= [[self alloc] init];
            [instance_ resetAllProperties];
        }
    }
    return(instance_);
}

+(void)deleteFile:(NSURL*)url {
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    if([fileMngr fileExistsAtPath:[url path]]) {
        NSError *error = nil;
        BOOL removed = [fileMngr removeItemAtPath:[url path] error:&error];
        if(!removed && error) {
            MWLogError(g_classObj, @"Could not remove file at:%@! Details:%@", [url path], [error domain]);
        } else {
            MWLogInfo(g_classObj, @"Removed catalog-package:%@", [url path]);
        }
    } else {
        MWLogError(g_classObj, @"File:%@ does not exists!", [url path]);
    }
}

+(void)cleanupInboxAndTmpDir {
    NSString *nameOfInboxDir = @"Inbox";
    MWLogDebug(g_classObj, @"Some cleanups! Try to remove the the files in directory:%@!", nameOfInboxDir);
    NSFileManager* fileMngr = [NSFileManager defaultManager];
    NSArray *dirList = [fileMngr URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentDirUrl = [dirList objectAtIndex:0];
    // TODO: get the name of the Inbox directory programmatically !
    NSURL *inboxDirUrl = [documentDirUrl URLByAppendingPathComponent:nameOfInboxDir];
    NSString *inboxDirPath = [inboxDirUrl path];
    [LayCatalogManager removeAllFilesInDirectory:inboxDirPath];
    [LayCatalogManager cleanupTmpDir];
   }

+(void)cleanupTmpDir {
    NSString *pathToTmpDir = NSTemporaryDirectory();
    [LayCatalogManager removeAllFilesInDirectory:pathToTmpDir];
}

+(void)removeAllFilesInDirectory:(NSString*)pathToDirectory {
    NSFileManager* fileMngr = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    MWLogDebug(g_classObj, @"Try to remove all items the %@ directory!", pathToDirectory);
    if([fileMngr fileExistsAtPath:pathToDirectory isDirectory:&isDirectory]) {
        if(isDirectory) {
            NSError *error = nil;
            NSArray *tmpDirContents = [fileMngr contentsOfDirectoryAtPath:pathToDirectory error:&error];
            if(!tmpDirContents) {
                MWLogError(g_classObj, @"Could not remove items in:%@! Details:%@,%d", pathToDirectory, [error domain], [error code]);
            } else {
                //remove files or whole directories
                for (NSString *item in tmpDirContents) {
                    NSString *pathToItem = [pathToDirectory stringByAppendingPathComponent:item];
                    BOOL removedItem = [fileMngr removeItemAtPath:pathToItem error:&error];
                    if(!removedItem && error) {
                        MWLogError(g_classObj, @"Could not remove item:%@! Details:%@,%d", pathToItem, [error domain], [error code]);
                    } else {
                        MWLogDebug(g_classObj, @"Removed the %@ item!", pathToItem);
                    }
                }
            }
        }
    }
}

-(void)cleanupInboxAndTmpDir {
    [LayCatalogManager cleanupInboxAndTmpDir];
}

-(void)cleanupTmpDir {
    [LayCatalogManager cleanupTmpDir];
}

-(void)deleteFile:(NSURL *)url {
    [LayCatalogManager deleteFile:url];
}


-(void)resetAllProperties {
    self.currentSelectedCatalog = nil;
    self.currentSelectedQuestion = nil;
    self.selectedQuestions = nil;
    self.currentSelectedQuestion = nil;
    self.currentCatalogShouldBeOpenedDirectly = NO;
    self.currentCatalogIsUsedInQuestionSession = NO;
    self.pendingCatalogToImport = NO;
    self.currentCatalogShouldBeQueriedDirectly = NO;
    self.currentCatalogShouldBeLearnedDirectly = NO;
    self.selectedExplanations = nil;
}

@end
