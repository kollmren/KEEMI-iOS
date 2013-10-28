
// We need all the log functions visible so we set this to DEBUG
#ifdef MW_COMPILE_TIME_LOG_LEVEL
#undef MW_COMPILE_TIME_LOG_LEVEL
#define MW_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_DEBUG
#endif

#define MW_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_DEBUG

#import <objc/runtime.h>
#import "MWLogging.h"

static void addStderrOnce()
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		asl_add_log_file(NULL, STDERR_FILENO);
	});
}

static int fd = -1;
bool logToFileWithPath(const char* filePath)
{
    bool addedToLog = false;
    if(fd != -1) {
        asl_remove_log_file(NULL, fd);
        close(fd);
    }
    fd = open(filePath, O_RDWR|O_CREAT|O_TRUNC, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH|S_IWOTH);
    if(fd >= 0) {
        if(asl_add_log_file(NULL, fd) == 0) {
            addedToLog = true;
        }
    }
    return addedToLog;
}

#define __MW_MAKE_LOG_FUNCTION(LEVEL, NAME) \
void NAME (Class c, NSString *format, ...) \
{ \
	addStderrOnce(); \
	va_list args; \
	va_start(args, format); \
	NSString *message = [[NSString alloc] initWithFormat:format arguments:args]; \
    const char *className = class_getName(c); \
	asl_log(NULL, NULL, (LEVEL), "LayLog - [%s] %s", className, [message UTF8String]); \
	va_end(args); \
}

__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_CRIT, MWLogCritical)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_ERR, MWLogError)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_WARNING, MWLogWarning)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_INFO, MWLogInfo)
__MW_MAKE_LOG_FUNCTION(ASL_LEVEL_DEBUG, MWLogDebug)

#undef __MW_MAKE_LOG_FUNCTION
