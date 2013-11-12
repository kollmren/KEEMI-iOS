//
//  LayAnswerViewManagerImpl.m
//  Lay
//
//  Created by Rene Kollmorgen on 03.02.13.
//  Copyright (c) 2013 Rene. All rights reserved.
//

#import "LayAnswerViewManagerImpl.h"
#import "LayAnswerType.h"
#import "Answer+Utilities.h"

#import "MWLogging.h"

#import <objc/runtime.h>

@interface AnswerViewRegisterObject : NSObject
@property (nonatomic) NSInteger key;
@property (nonatomic) Class class;
@property (nonatomic) NSObject<LayAnswerView>* instance;
@end


@interface LayAnswerViewManagerImpl() {
    NSMutableArray *registeredAnswerViewList;
}
@end


@implementation LayAnswerViewManagerImpl

static const NSInteger g_DEFAULT_NUMBER_OF_REGISTERED_VIEWS = 10;

+(BOOL)registerAnswerView:(Class<LayAnswerView>)answerView forTypeOfAnswer:(LayAnswerTypeIdentifier)type {
    LayAnswerViewManagerImpl* answerViewManager = [LayAnswerViewManagerImpl instance];
    BOOL registered = NO;
    if([answerViewManager viewForTypeExists:type]) {
        MWLogError([LayAnswerViewManagerImpl class], @"An answer-view for type:%d is already resgistered! Ignore registration call!", type);
        return registered;
    }
    
    Protocol* protocol = objc_getProtocol("LayAnswerView");
    if(!protocol) {
        MWLogError([LayAnswerViewManagerImpl class], @"Could not identify protocol!");
        return registered;
    }
        
    /*
     Class superClass = class_getSuperclass(answerView);
    const char* nameOfSuperClass = class_getName(superClass);
    const char* const EXPECTED_NAME_OF_SUPER_CLASS = "UIView";
    BOOL superClassConform = NO;
    if(nameOfSuperClass) {
        int match = strcmp(nameOfSuperClass, EXPECTED_NAME_OF_SUPER_CLASS);
        if(0==match) {
            superClassConform = YES;
        }
    } else {
        MWLogError([LayAnswerViewManagerImpl class], @"Could not get the name of the superclass!");
    }*/
    
    const char* nameOfClassToRegister = class_getName(answerView);
    BOOL protocolConform = class_conformsToProtocol(answerView,protocol);
    BOOL isConform = YES;
    /*if(!superClassConform) {
        isConform = NO;
        MWLogError([LayAnswerViewManagerImpl class], @"Class:%s is not a subclass of:%s!", nameOfClassToRegister, nameOfSuperClass);
    }*/
    
    if(!protocolConform) {
        isConform = NO;
        const char *nameOfProtocoll = protocol_getName(protocol);
        MWLogError([LayAnswerViewManagerImpl class], @"Class:%s is not conform to protocoll:%s!", nameOfClassToRegister, nameOfProtocoll);
    }
    
    if(isConform) {
        AnswerViewRegisterObject *regObj = [AnswerViewRegisterObject new];
        regObj.key = type;
        regObj.class = answerView;
        [answerViewManager->registeredAnswerViewList addObject:regObj];
        registered = YES;
        MWLogDebug([LayAnswerViewManagerImpl class], @"Registered AnswerView-Class with name:%s!",nameOfClassToRegister);
    }
    
    return registered;
}

+(LayAnswerViewManagerImpl*) instance {
    static LayAnswerViewManagerImpl* instance_ = nil;
    @synchronized(self)
    {
        if (instance_ == NULL) {
            instance_= [[self alloc] init];
            instance_->registeredAnswerViewList = [NSMutableArray arrayWithCapacity:g_DEFAULT_NUMBER_OF_REGISTERED_VIEWS];
        }
    }
    
    return(instance_);
}

-(void)freeAllAnswerViewObjects {
    for (AnswerViewRegisterObject *regObj in self->registeredAnswerViewList ) {
        regObj.instance = nil;
    }
}

//
// LayAnswerViewManager
//
-(BOOL) viewForTypeExists:(LayAnswerTypeIdentifier)answerType {
    BOOL viewForTypeExists = NO;
    for (AnswerViewRegisterObject *regObj in self->registeredAnswerViewList ) {
        if(regObj.key == answerType) {
            viewForTypeExists = YES;
        }
    }
    return viewForTypeExists;
}

-(NSObject<LayAnswerView>*) viewForAnswerType:(LayAnswerTypeIdentifier)answerTypeId {
    NSObject<LayAnswerView> *answerView = nil;
    for (AnswerViewRegisterObject *regObj in self->registeredAnswerViewList ) {
        if(regObj.key == answerTypeId) {
            if(regObj.instance) {
                answerView = regObj.instance;
            } else {
                Class answerViewClass = regObj.class;
                answerView = [[answerViewClass alloc] initAnswerView];
                regObj.instance = answerView;
            }
        }
    }
    return answerView;
}

@end

//
// Pair
//
@implementation AnswerViewRegisterObject

@synthesize key,class,instance;

@end
