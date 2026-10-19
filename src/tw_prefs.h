// tw_prefs.h — the single settings reader for the injected code. The settings
// file is read once, when the app launches. There is no refresh on a
// notification: LookInside Server cannot be unloaded from a running app, so a
// change only means something at the app's next launch, which the Settings
// pane tells the user.
#pragma once
#import <Foundation/Foundation.h>

// Whether this app is one the user turned on, with the master switch on.
BOOL tw_prefs_app_enabled(NSString *bundleIdentifier);
