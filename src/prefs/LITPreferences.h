// The parts of the private Preferences framework this bundle uses. The SDK
// ships no Preferences headers, so these declarations stand in; the symbols
// resolve from the framework at runtime. Keep this to exactly what is used.
#pragma once
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PSCellType) {
    PSSwitchCell = 6,
};

@interface PSSpecifier : NSObject
+ (instancetype)groupSpecifierWithName:(NSString *)name;
+ (instancetype)preferenceSpecifierNamed:(NSString *)name
                                  target:(id)target
                                     set:(SEL)set
                                     get:(SEL)get
                                  detail:(Class)detail
                                    cell:(PSCellType)cell
                                    edit:(Class)edit;
- (id)propertyForKey:(NSString *)key;
- (void)setProperty:(id)property forKey:(NSString *)key;
@end

@interface PSListController : UIViewController {
    NSArray *_specifiers;
}
- (NSArray *)specifiers;
- (NSMutableArray *)loadSpecifiersFromPlistName:(NSString *)plistName target:(id)target;
@end
