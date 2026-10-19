// tweak.m — loads LookInside Server into the apps picked in Settings and starts
// it.
//
// No methods are hooked. The filter loads this dylib into every UIKit process;
// the constructor returns at once unless the process is an app the user turned
// on, and only then dlopens the Server.
#import <UIKit/UIKit.h>
#include <dlfcn.h>
#include <os/log.h>
#include <sys/stat.h>
#include "tw_config.h"
#include "tw_jbpath.h"
#include "tw_prefs.h"

// TW_VERSION is emitted as a used, non-stripped constant with a fixed marker so
// it is readable from the shipped binary (version-single-source). Do not write
// a literal version anywhere else.
__attribute__((used, visibility("default")))
const char tw_version_marker[] = "TWEAKVER=" TW_VERSION;

static os_log_t tw_log(void) {
    static os_log_t log;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ log = os_log_create(TW_PACKAGE_ID, "load"); });
    return log;
}

// One marker file in the tweak's own state dir disables loading everywhere: a
// present marker turns the tweak off; missing means run normally. The path is
// documented in the release notes.
static bool tw_kill_switch_present(void) {
    const char *marker = TW_JBROOT("/var/mobile/Library/" TW_PACKAGE_ID "/disabled");
    struct stat st;
    return marker && stat(marker, &st) == 0;
}

static void tw_start_server_once(void (*start)(void)) {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        start();
        os_log(tw_log(), "LookInside Server started");
    });
}

// Start after the app finishes launching, with a one second fallback in case
// that already happened, the same timing as the Server's own injected build.
static void tw_schedule_start(void (*start)(void)) {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(__unused NSNotification *note) {
        tw_start_server_once(start);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        tw_start_server_once(start);
    });
}

__attribute__((constructor)) static void tw_constructor(void) {
    @autoreleasepool {
        // Identity guard: only an app the user turned on goes further.
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        if (bundleIdentifier.length == 0) return;
        if (tw_kill_switch_present()) {
            os_log(tw_log(), "kill switch present; not loading LookInside Server");
            return;
        }
        if (!tw_prefs_app_enabled(bundleIdentifier)) return;

        // The app already ships its own Lookin or LookInside server. Loading a
        // second copy would register the same Objective-C classes twice.
        if (NSClassFromString(@"LKS_ConnectionManager") != nil) {
            os_log(tw_log(), "the app already contains a Lookin server; skipping");
            return;
        }

        const char *server = TW_JBROOT("/Library/Frameworks/LookInsideServer.framework/LookInsideServer");
        void *handle = server ? dlopen(server, RTLD_NOW) : NULL;
        if (handle == NULL) {
            os_log_error(tw_log(), "could not load LookInside Server");
            return;
        }
        void (*start)(void) = (void (*)(void))dlsym(handle, "LookinServerStart");
        if (start == NULL) {
            os_log_error(tw_log(), "LookinServerStart is missing from LookInside Server");
            return;
        }
        tw_schedule_start(start);
    }
}
