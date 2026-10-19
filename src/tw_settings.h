// tw_settings.h — where the settings live and what they are called, shared by
// the injected reader (tw_prefs.m) and the Settings pane (src/prefs/).
//
// The settings are a plain plist in the tweak's state directory under the
// bootstrap, not a cfprefsd domain: a sandboxed app can read files under the
// bootstrap on both layouts, while cfprefsd refuses another domain's reads
// from a sandbox on some jailbreaks. postrm deletes the directory on purge.
#pragma once
#import <Foundation/Foundation.h>
#include "tw_config.h"
#include "tw_jbpath.h"

// Loading is on unless the user turns the master switch off.
static NSString *const TWEnabledKey = @"enabled";
// Bundle identifiers of the apps that load LookInside Server.
static NSString *const TWEnabledAppsKey = @"enabledApps";

static inline NSString *tw_settings_path(void) {
    return @(TW_JBROOT("/var/mobile/Library/" TW_PACKAGE_ID "/settings.plist"));
}

static inline NSDictionary *tw_settings_read(void) {
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:tw_settings_path()];
    return [settings isKindOfClass:[NSDictionary class]] ? settings : @{};
}

static inline BOOL tw_settings_enabled(NSDictionary *settings) {
    id value = settings[TWEnabledKey];
    return [value isKindOfClass:[NSNumber class]] ? [value boolValue] : YES;
}

static inline NSArray<NSString *> *tw_settings_enabled_apps(NSDictionary *settings) {
    id value = settings[TWEnabledAppsKey];
    return [value isKindOfClass:[NSArray class]] ? value : @[];
}
