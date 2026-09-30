// Lists installed apps with one switch each. Switches write the
// enabledApps array that the loader checks at app launch.

#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIKit.h>
#import "LITPreferenceStore.h"

@interface LSApplicationProxy : NSObject
@property (nonatomic, readonly) NSString *applicationIdentifier;
@property (nonatomic, readonly) NSString *applicationType;
@property (nonatomic, readonly) NSString *localizedName;
@property (nonatomic, readonly) NSArray<NSString *> *appTags;
@property (nonatomic, readonly, getter=isLaunchProhibited) BOOL launchProhibited;
@end

@interface LSApplicationWorkspace : NSObject
+ (instancetype)defaultWorkspace;
- (NSArray<LSApplicationProxy *> *)allInstalledApplications;
@end

@interface UIImage (LITPrivate)
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier format:(int)format scale:(CGFloat)scale;
@end

@interface LITAppListController : PSListController
@end

@implementation LITAppListController

- (NSString *)localized:(NSString *)key {
    return NSLocalizedStringFromTableInBundle(key, @"AppList", [NSBundle bundleForClass:[self class]], nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [self localized:@"TITLE"];
}

- (NSArray<LSApplicationProxy *> *)visibleApplicationsOfType:(NSString *)type {
    NSMutableArray<LSApplicationProxy *> *applications = [NSMutableArray array];
    LSApplicationWorkspace *workspace = [(Class)NSClassFromString(@"LSApplicationWorkspace") defaultWorkspace];
    for (LSApplicationProxy *application in [workspace allInstalledApplications]) {
        if (![application.applicationType isEqualToString:type]) {
            continue;
        }
        if ([application.appTags containsObject:@"hidden"] || application.launchProhibited) {
            continue;
        }
        if (application.applicationIdentifier.length == 0 || application.localizedName.length == 0) {
            continue;
        }
        [applications addObject:application];
    }
    [applications sortUsingComparator:^NSComparisonResult(LSApplicationProxy *lhs, LSApplicationProxy *rhs) {
        return [lhs.localizedName localizedStandardCompare:rhs.localizedName];
    }];
    return applications;
}

- (PSSpecifier *)groupNamed:(NSString *)name footer:(NSString *)footer {
    PSSpecifier *group = [PSSpecifier groupSpecifierWithName:name];
    if (footer != nil) {
        [group setProperty:footer forKey:@"footerText"];
    }
    return group;
}

- (PSSpecifier *)switchForApplication:(LSApplicationProxy *)application {
    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:application.localizedName
                                                            target:self
                                                               set:@selector(setAppEnabled:specifier:)
                                                               get:@selector(appEnabled:)
                                                            detail:nil
                                                              cell:PSSwitchCell
                                                              edit:nil];
    [specifier setProperty:application.applicationIdentifier forKey:@"bundleIdentifier"];
    if ([UIImage respondsToSelector:@selector(_applicationIconImageForBundleIdentifier:format:scale:)]) {
        UIImage *icon = [UIImage _applicationIconImageForBundleIdentifier:application.applicationIdentifier
                                                                   format:0
                                                                    scale:UIScreen.mainScreen.scale];
        if (icon != nil) {
            [specifier setProperty:icon forKey:@"iconImage"];
        }
    }
    return specifier;
}

- (NSArray *)specifiers {
    if (_specifiers == nil) {
        NSMutableArray *specifiers = [NSMutableArray array];
        NSArray *sections = @[
            @[@"User", [self localized:@"USER_APPS"]],
            @[@"System", [self localized:@"SYSTEM_APPS"]],
        ];
        BOOL isFirstSection = YES;
        for (NSArray *section in sections) {
            NSArray<LSApplicationProxy *> *applications = [self visibleApplicationsOfType:section[0]];
            if (applications.count == 0) {
                continue;
            }
            NSString *footer = isFirstSection ? [self localized:@"RELAUNCH_FOOTER"] : nil;
            [specifiers addObject:[self groupNamed:section[1] footer:footer]];
            for (LSApplicationProxy *application in applications) {
                [specifiers addObject:[self switchForApplication:application]];
            }
            isFirstSection = NO;
        }
        _specifiers = specifiers;
    }
    return _specifiers;
}

- (NSNumber *)appEnabled:(PSSpecifier *)specifier {
    NSString *bundleIdentifier = [specifier propertyForKey:@"bundleIdentifier"];
    return @([LITEnabledApps(LITReadPreferences()) containsObject:bundleIdentifier]);
}

- (void)setAppEnabled:(NSNumber *)value specifier:(PSSpecifier *)specifier {
    NSString *bundleIdentifier = [specifier propertyForKey:@"bundleIdentifier"];
    NSMutableOrderedSet<NSString *> *enabledApps = [NSMutableOrderedSet orderedSetWithArray:LITEnabledApps(LITReadPreferences())];
    if (value.boolValue) {
        [enabledApps addObject:bundleIdentifier];
    } else {
        [enabledApps removeObject:bundleIdentifier];
    }
    LITWritePreference(LITEnabledAppsKey, enabledApps.array);
}

@end
