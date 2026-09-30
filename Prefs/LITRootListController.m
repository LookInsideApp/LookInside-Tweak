#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIKit.h>
#import "LITPreferenceStore.h"

@interface LITRootListController : PSListController
@end

@implementation LITRootListController

- (NSArray *)specifiers {
    if (_specifiers == nil) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

// Every switch on this page reads and writes the shared plist, not cfprefsd.
- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    id value = LITReadPreferences()[key];
    return value ?: [specifier propertyForKey:@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    LITWritePreference([specifier propertyForKey:@"key"], value);
}

- (NSString *)versionString:(__unused PSSpecifier *)specifier {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"";
}

- (void)openWebsite {
    NSURL *url = [NSURL URLWithString:@"https://lookinside-app.com"];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

@end
