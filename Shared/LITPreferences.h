// Preference store shared by the loader and the Settings pane.
//
// The settings live in a plain plist under the jailbreak root instead of
// going through cfprefsd: sandboxed apps can read files under the jailbreak
// root on both rootless and roothide, but cfprefsd refuses cross-domain reads
// from a sandbox on some jailbreaks.

#import <Foundation/Foundation.h>
#import <roothide.h>

static NSString *const LITEnabledKey = @"enabled";
static NSString *const LITEnabledAppsKey = @"enabledApps";
static const char *const LITChangedNotification = "app.lookinside.tweak/changed";

static inline NSString *LITPreferencesPath(void) {
    return jbroot(@"/var/mobile/Library/Preferences/app.lookinside.tweak.plist");
}

static inline NSDictionary *LITReadPreferences(void) {
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:LITPreferencesPath()];
    return [preferences isKindOfClass:[NSDictionary class]] ? preferences : @{};
}

// Loading is on unless the user turns the master switch off.
static inline BOOL LITIsEnabled(NSDictionary *preferences) {
    id value = preferences[LITEnabledKey];
    return [value respondsToSelector:@selector(boolValue)] ? [value boolValue] : YES;
}

static inline NSArray<NSString *> *LITEnabledApps(NSDictionary *preferences) {
    id value = preferences[LITEnabledAppsKey];
    return [value isKindOfClass:[NSArray class]] ? value : @[];
}
