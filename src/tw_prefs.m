// tw_prefs.m — see tw_prefs.h. The file and its keys come from tw_settings.h.
#import "tw_prefs.h"
#include "tw_settings.h"

BOOL tw_prefs_app_enabled(NSString *bundleIdentifier) {
    NSDictionary *settings = tw_settings_read();
    return tw_settings_enabled(settings) && [tw_settings_enabled_apps(settings) containsObject:bundleIdentifier];
}
