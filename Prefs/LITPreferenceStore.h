#import <Foundation/Foundation.h>
#import <notify.h>
#import "../Shared/LITPreferences.h"

// Writes one key into the preference plist and tells listeners it changed.
static inline void LITWritePreference(NSString *key, id value) {
    NSMutableDictionary *preferences = [LITReadPreferences() mutableCopy];
    if (value != nil) {
        preferences[key] = value;
    } else {
        [preferences removeObjectForKey:key];
    }

    NSString *path = LITPreferencesPath();
    [[NSFileManager defaultManager] createDirectoryAtPath:path.stringByDeletingLastPathComponent
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
    [preferences writeToFile:path atomically:YES];
    notify_post(LITChangedNotification);
}
