//
//  LayAppConfiguration.m
//  Lay
//
//  Created by Rene Kollmorgen on 03.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayAppConfiguration.h"
// Answer-View cfg
#import "LayAnswerViewManagerImpl.h"
#import "LayAnswerViewChoice.h"
#import "LayAnswerViewSingleChoice.h"
#import "LayAnswerViewAggravatedChoice.h"
#import "LayAnswerViewCard.h"
#import "LayAnswerViewWordResponse.h"
#import "LayAnswerViewOrder.h"
#import "LayAnswerViewKeywordItemMatch.h"
// Datastore cfg
#import "LayDataStoreConfiguration.h"
#import "LayUserDataStoreConfiguration.h"
#import "LayMainDataStore.h"
//
#import "LayError.h"
#import "MWLogging.h"

//const NSString* const NAME_OF_LOG_FILE = @"KeemiLog.log";
//const NSString* const NAME_OF_LOG_FILE_BACKUP = @"KeemiLogBackuped.log";

@implementation LayAppConfiguration

+(BOOL) configureApp {
    BOOL configured = YES;
    
    //
    // Logging
    //
    [LayAppConfiguration backupLogFile];
    if(![LayAppConfiguration configureLogging]) {
        configured = NO;
    }
    
    //
    // Datastore
    //
    if(![LayAppConfiguration configureDatastore]) {
        configured = NO;
    }
    
    //
    // Answer-Views
    //
    if(![LayAppConfiguration registerAnswerViews]) {
        configured = NO;
    }
    
    //
    // Menu
    //
    [LayAppConfiguration setupMenu];
    
    return configured;
}

+(void)logSystemInformation {
    UIDevice *currentDevice = [UIDevice currentDevice];
    MWLogInfo([LayAppConfiguration class], @"System:%@, name:%@, version:%@", currentDevice.name, currentDevice.systemName, currentDevice.systemVersion);
    NSString* appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    MWLogInfo([LayAppConfiguration class], @"App-version:%@", appVersion);
}

+(void)setupMenu {
    NSString *menuOpenQuestionTitle = NSLocalizedString(@"ResourceOpenQuestionsTitle", nil);
    UIMenuItem *openQuestionMenuItem = [[UIMenuItem alloc] initWithTitle:menuOpenQuestionTitle action:@selector(openRelatedQuestions:)];
    NSString *menuExplanationTitle = NSLocalizedString(@"ResourceOpenExplanationsTitle", nil);
    UIMenuItem *openExplanationMenuItem = [[UIMenuItem alloc] initWithTitle:menuExplanationTitle action:@selector(openRelatedExplanations:)];
    NSString *menuEditTitle = NSLocalizedString(@"ResourceEditTitle", nil);
    UIMenuItem *openEditMenuItem = [[UIMenuItem alloc] initWithTitle:menuEditTitle action:@selector(edit:)];
    [[UIMenuController sharedMenuController] setMenuItems: @[openEditMenuItem, openQuestionMenuItem, openExplanationMenuItem]];
    [[UIMenuController sharedMenuController] update];
}

+(BOOL)registerAnswerViews {
    BOOL registrationComplete = YES;
    MWLogInfo([LayAppConfiguration class], @"Register Answer-Views ...");
    BOOL registered = NO;
    registered = [LayAnswerViewManagerImpl registerAnswerView:
                  [LayAnswerViewChoice class] forTypeOfAnswer:ANSWER_TYPE_MULTIPLE_CHOICE];
    if(!registered) {
        registrationComplete = NO;
    }
    
    registered = [LayAnswerViewManagerImpl registerAnswerView:
                  [LayAnswerViewSingleChoice class] forTypeOfAnswer:ANSWER_TYPE_SINGLE_CHOICE];
    if(!registered) {
        registrationComplete = NO;
    }
    
    registered = [LayAnswerViewManagerImpl registerAnswerView:
                  [LayAnswerViewAggravatedChoice class] forTypeOfAnswer:ANSWER_TYPE_AGGRAVATED_MULTIPLE_CHOICE];
    if(!registered) {
        registrationComplete = NO;
    }
    
    registered = [LayAnswerViewManagerImpl registerAnswerView:
                  [LayAnswerViewAggravatedChoice class] forTypeOfAnswer:ANSWER_TYPE_AGGRAVATED_SINGLE_CHOICE];
    if(!registered) {
        registrationComplete = NO;
    }
    
    registered = [LayAnswerViewManagerImpl registerAnswerView:
                  [LayAnswerViewCard class] forTypeOfAnswer:ANSWER_TYPE_CARD];
    if(!registered) {
        registrationComplete = NO;
    }
    
    registered = [LayAnswerViewManagerImpl registerAnswerView:
                  [LayAnswerViewWordResponse class] forTypeOfAnswer:ANSWER_TYPE_WORD_RESPONSE];
    if(!registered) {
        registrationComplete = NO;
    }
    
    registered = [LayAnswerViewManagerImpl registerAnswerView:
                  [LayAnswerViewOrder class] forTypeOfAnswer:ANSWER_TYPE_ORDER];
    if(!registered) {
        registrationComplete = NO;
    }
    
    registered = [LayAnswerViewManagerImpl registerAnswerView:
                  [LayAnswerViewKeywordItemMatch class] forTypeOfAnswer:ANSWER_TYPE_KEY_WORD_ITEM_MATCH];
    if(!registered) {
        registrationComplete = NO;
    }
    
    registered = [LayAnswerViewManagerImpl registerAnswerView:
                  [LayAnswerViewKeywordItemMatch class] forTypeOfAnswer:ANSWER_TYPE_KEY_WORD_ITEM_MATCH_ORDERED];
    if(!registered) {
        registrationComplete = NO;
    }


    
    return registrationComplete;
}

+ (BOOL)configureDatastore
{
    BOOL databaseSetup = NO;
    MWLogDebug([LayAppConfiguration class], @"Configure Datastore ...");
    NSString* STORE_FILE_NAME = @"KeemiMainStore.sqlite";
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    NSArray *dirList = [fileMngr URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cachesDirUrl = [dirList objectAtIndex:0];
    NSURL *urlToStoreFileInCachesDir = [cachesDirUrl URLByAppendingPathComponent:STORE_FILE_NAME];
    
    /*databaseSetup = [self copyDataStoreFileToCachesDir:STORE_FILE_NAME];
     if(databaseSetup) databaseSetup = [self configureDataStoreAtURL:urlToStoreFileInCachesDir];*/
    databaseSetup = [self configureDataStoreAtURL:urlToStoreFileInCachesDir];
    
    if(databaseSetup) {
        NSArray *dirList = [fileMngr URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *documentDirUrl = [dirList objectAtIndex:0];
        MWLogDebug([LayAppConfiguration class], @"Configure User-Datastore ...");
        NSString* USER_STORE_FILE_NAME = @"KeemiUserStore.sqlite";
        NSURL *urlToStoreFileInDocumentDir = [documentDirUrl URLByAppendingPathComponent:USER_STORE_FILE_NAME];
        databaseSetup = [self configureUserDataStoreAtURL:urlToStoreFileInDocumentDir];
    }
    
    return databaseSetup;
}


+ (BOOL) copyDataStoreFileToCachesDir:(NSString*)storeFileName {
    // Copy datastore from bundle to directory Library/Caches
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    [fileMngr setDelegate:self]; // Override if datastore already exists in directory Caches.
    NSArray *dirList = [fileMngr URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cachesDirUrl = [dirList objectAtIndex:0];
    NSURL *urlToStoreFileInCachesDir = [cachesDirUrl URLByAppendingPathComponent:storeFileName];
    NSError *error = nil;
    BOOL storeFileExistsAtTheRightPlace = NO;
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *urlToStoreFileInBundle = [bundle URLForResource:storeFileName withExtension:nil];
    if ([fileMngr fileExistsAtPath:[urlToStoreFileInCachesDir path]]) {
        MWLogWarning([LayAppConfiguration class], @"Remove file:%@!.", urlToStoreFileInCachesDir);
        storeFileExistsAtTheRightPlace = [fileMngr removeItemAtURL:urlToStoreFileInCachesDir error:&error];
    }
    
    if(nil==error){
        MWLogDebug([LayAppConfiguration class], @"Copy file from:%@ to %@.", urlToStoreFileInBundle, urlToStoreFileInCachesDir );
        storeFileExistsAtTheRightPlace = [fileMngr copyItemAtURL:urlToStoreFileInBundle toURL:urlToStoreFileInCachesDir error:&error];
    }
    
    if(!storeFileExistsAtTheRightPlace) {
        MWLogError([LayAppConfiguration class], @"%@", [error description]);
    } else {
        MWLogDebug([LayAppConfiguration class], @"Copied file successfully.");
    }
    
    return storeFileExistsAtTheRightPlace;
}

+ (BOOL)configureDataStoreAtURL:(NSURL*)urlToStoreFileInCachesDir {
    NSString* MODEL_FILE_NAME = @"LayDataModel";
    NSString *pathToModelFile = [[NSBundle mainBundle] pathForResource:MODEL_FILE_NAME ofType:@"momd"];
    NSString *pathToModelFileEscaped = [pathToModelFile stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *urlModelFile = [NSURL URLWithString:pathToModelFileEscaped];
    LayError *layError = nil;
    BOOL configured = [LayDataStoreConfiguration configure:urlToStoreFileInCachesDir andUrlToModel:urlModelFile : &layError];
    if(!configured) {
        MWLogError([LayAppConfiguration class], @"Could not setup datastore! Error:%@", [layError description]);
    }
    return configured;
}

+ (BOOL)configureUserDataStoreAtURL:(NSURL*)urlToStoreFileInCachesDir {
    NSString* MODEL_FILE_NAME = @"LayUserDataModel";
    NSString *pathToModelFile = [[NSBundle mainBundle] pathForResource:MODEL_FILE_NAME ofType:@"momd"];
    NSString *pathToModelFileEscaped = [pathToModelFile stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *urlModelFile = [NSURL URLWithString:pathToModelFileEscaped];
    LayError *layError = nil;
    BOOL configured = [LayUserDataStoreConfiguration configure:urlToStoreFileInCachesDir andUrlToModel:urlModelFile : &layError];
    if(!configured) {
         MWLogError([LayAppConfiguration class], @"Could not setup user-datastore! Error:%@", [layError description]);
    }
    return configured;
}

+(BOOL)configureLogging {
    BOOL configured = NO;
     NSURL* urlToLogFile = [LayAppConfiguration urlToLogFile];
    if(urlToLogFile) {
        NSFileManager *fileMngr = [NSFileManager defaultManager];
        char const *path = [fileMngr fileSystemRepresentationWithPath:urlToLogFile.path];
        configured = logToFileWithPath(path)==true?YES:FALSE;
    }
    
    if(configured) {
        [LayAppConfiguration logSystemInformation];
    }
    
    return configured;
}

+(void)backupLogFile {
    NSURL* urlToLogFile = [LayAppConfiguration urlToLogFile];
    if(urlToLogFile) {
        NSURL* urlToBackupedLogFile = [LayAppConfiguration urlToBackedupLogFile];
        NSError *error = nil;
        NSFileManager *fileMngr = [NSFileManager defaultManager];
        if([fileMngr fileExistsAtPath:[urlToBackupedLogFile path]]) {
            BOOL removed= [fileMngr removeItemAtURL:urlToBackupedLogFile error:&error];
            if(!removed || error) {
                MWLogError([LayAppConfiguration class], @"Could not remove log-backup:%@", [error description]);
            }
        }
        if([fileMngr fileExistsAtPath:[urlToLogFile path]]) {
            BOOL copied = [fileMngr copyItemAtURL:urlToLogFile toURL:urlToBackupedLogFile error:&error];
            if(!copied || error) {
                MWLogError([LayAppConfiguration class], @"Could not backup log-file:%@", [error description]);
            }
        }
    }
}

+(NSURL*)urlToLogFile {
    NSString *nameOfLogFile = @"KeemiLog.log";
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    NSArray *dirList = [fileMngr URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cachesDirUrl = [dirList objectAtIndex:0];
    NSURL* urlToLogFile = nil;
    if(cachesDirUrl) {
        urlToLogFile = [cachesDirUrl URLByAppendingPathComponent:nameOfLogFile];
    }
    return urlToLogFile;
}

+(NSURL*)urlToBackedupLogFile {
    NSString *nameOfLogFile = @"KeemiLogBackuped.log";
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    NSArray *dirList = [fileMngr URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cachesDirUrl = [dirList objectAtIndex:0];
    NSURL* urlToLogFile = nil;
    if(cachesDirUrl) {
        urlToLogFile = [cachesDirUrl URLByAppendingPathComponent:nameOfLogFile];
    }
    return urlToLogFile;
}

+(NSData*) contentOfLogFile {
    NSData* contentOfLogFile = nil;
    NSString *nameOfLogFile = @"KeemiLog.log";
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    NSArray *dirList = [fileMngr URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cachesDirUrl = [dirList objectAtIndex:0];
    if(cachesDirUrl) {
        NSURL* urlToLogFile = [cachesDirUrl URLByAppendingPathComponent:nameOfLogFile];
        if([fileMngr fileExistsAtPath:[urlToLogFile path]]) {
            contentOfLogFile = [fileMngr contentsAtPath:[urlToLogFile path]];
        }
    }
    return contentOfLogFile;
}

+(NSData*) contentBackupedOfLogFile {
    NSData* contentOfLogFile = nil;
    NSFileManager *fileMngr = [NSFileManager defaultManager];
    NSURL* urlToBackupedLogFile = [LayAppConfiguration urlToBackedupLogFile];
    if(urlToBackupedLogFile) {
        if([fileMngr fileExistsAtPath:[urlToBackupedLogFile path]]) {
            contentOfLogFile = [fileMngr contentsAtPath:[urlToBackupedLogFile path]];
        } else {
            MWLogInfo([LayAppConfiguration class], @"Backup log-file does not exists!");
        }
    }
  
    return contentOfLogFile;
}

@end
