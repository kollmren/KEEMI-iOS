/*
 MWLogging. Simple wrapper macros/functions around ASL (Apple System
 Log)

 We support a compile-time log level through
 MW_COMPILE_TIME_LOG_LEVEL. This will turn the associated log calls
 into NOPs.

 The log levels are the constants defined in asl.h:

 #define ASL_LEVEL_EMERG   0
 #define ASL_LEVEL_ALERT   1
 #define ASL_LEVEL_CRIT    2
 #define ASL_LEVEL_ERR     3
 #define ASL_LEVEL_WARNING 4
 #define ASL_LEVEL_NOTICE  5
 #define ASL_LEVEL_INFO    6
 #define ASL_LEVEL_DEBUG   7

 For a description of when to use each level, see here:

 http://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/LoggingErrorsAndWarnings.html#//apple_ref/doc/uid/10000172i-SW8-SW1

 Emergency (level 0) - The highest priority, usually reserved for
                       catastrophic failures and reboot notices.

 Alert (level 1)     - A serious failure in a key system.

 Critical (level 2)  - A failure in a key system.

 Error (level 3)     - Something has failed.

 Warning (level 4)   - Something is amiss and might fail if not
                       corrected.

 Notice (level 5)    - Things of moderate interest to the user or
                       administrator.

 Info (level 6)      - The lowest priority that you would normally log, and
                       purely informational in nature.

 Debug (level 7)     - The lowest priority, and normally not logged except
                       for messages from the kernel.


 Note that by default the iOS syslog/console will only record items up
 to level ASL_LEVEL_NOTICE.

 */

/** @todo

 We want better multithread support. Default NULL client uses
 locking. Perhaps we can check for [NSThread mainThread] and associate
 an asl client object to that thread. Then we can specify
 ASL_OPT_STDERR and not need an extra call to add stderr.

 */

#import <Foundation/Foundation.h>

#ifndef MW_COMPILE_TIME_LOG_LEVEL
	#ifndef DEBUG
		#define MW_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_INFO
	#else
		#define MW_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_DEBUG
	#endif
#endif

#include <asl.h>

#ifdef __cplusplus
extern "C" {
#endif

#if MW_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_CRIT
void MWLogCritical(Class c, NSString *format, ...);
#else
#define MWLogCritical(...)
#endif

#if MW_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_ERR
void MWLogError(Class c, NSString *format, ...);
#else
#define MWLogError(...)
#endif

#if MW_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_WARNING
void MWLogWarning(Class c, NSString *format, ...);
#else
#define MWLogWarning(...)
#endif

#if MW_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_INFO
void MWLogInfo(Class c, NSString *format, ...);
#else
#define MWLogInfo(...)
#endif

#if MW_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_DEBUG
void MWLogDebug(Class c, NSString *format, ...);
#else
#define MWLogDebug(...)
#endif

#define MWLogNameOfTest(ClassObject) MWLogInfo(ClassObject, @"------------ name of test: %@ ------------", NSStringFromSelector(_cmd) )

bool logToFileWithPath(const char* filePath);
    
#ifdef __cplusplus
}
#endif
