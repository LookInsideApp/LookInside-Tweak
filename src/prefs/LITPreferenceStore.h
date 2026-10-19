#import <Foundation/Foundation.h>
#include "tw_settings.h"

// Writes one key into the settings file. Apps read it when they launch.
static inline void LITWritePreference(NSString *key, id value) {
    NSMutableDictionary *settings = [tw_settings_read() mutableCopy];
    if (value != nil) {
        settings[key] = value;
    } else {
        [settings removeObjectForKey:key];
    }

    NSString *path = tw_settings_path();
    [[NSFileManager defaultManager] createDirectoryAtPath:path.stringByDeletingLastPathComponent
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
    [settings writeToFile:path atomically:YES];
}
