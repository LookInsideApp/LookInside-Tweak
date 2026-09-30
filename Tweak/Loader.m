// Loads LookInsideServer into the apps picked in Settings and starts it.
//
// No methods are hooked. The injector only needs to load this dylib into
// UIKit processes; everything below runs from the constructor.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <os/log.h>
#import "../Shared/LITPreferences.h"

static os_log_t LITLog(void) {
    static os_log_t log;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        log = os_log_create("app.lookinside.tweak", "loader");
    });
    return log;
}

static void LITStartServerOnce(void (*start)(void)) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        start();
        os_log(LITLog(), "LookInside Server started");
    });
}

// Same launch timing as LookinServerInjected: start after the app finishes
// launching, with a one second fallback in case that already happened.
static void LITScheduleStart(void (*start)(void)) {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(__unused NSNotification *note) {
        LITStartServerOnce(start);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LITStartServerOnce(start);
    });
}

__attribute__((constructor)) static void LITLoaderInit(void) {
    @autoreleasepool {
        NSString *bundleIdentifier = NSBundle.mainBundle.bundleIdentifier;
        if (bundleIdentifier.length == 0) {
            return;
        }

        NSDictionary *preferences = LITReadPreferences();
        if (!LITIsEnabled(preferences) || ![LITEnabledApps(preferences) containsObject:bundleIdentifier]) {
            return;
        }

        // The app already ships its own Lookin or LookInside server. Loading a
        // second copy would register the same Objective-C classes twice.
        if (NSClassFromString(@"LKS_ConnectionManager") != nil) {
            os_log(LITLog(), "Skipping %{public}@: it already contains a Lookin server", bundleIdentifier);
            return;
        }

        NSString *serverPath = jbroot(@"/Library/Frameworks/LookInsideServer.framework/LookInsideServer");
        void *handle = dlopen(serverPath.fileSystemRepresentation, RTLD_NOW);
        if (handle == NULL) {
            os_log_error(LITLog(), "Could not load %{public}@: %{public}s", serverPath, dlerror());
            return;
        }

        void (*start)(void) = (void (*)(void))dlsym(handle, "LookinServerStart");
        if (start == NULL) {
            os_log_error(LITLog(), "LookinServerStart is missing from %{public}@", serverPath);
            return;
        }

        os_log(LITLog(), "Loaded LookInside Server into %{public}@", bundleIdentifier);
        LITScheduleStart(start);
    }
}
