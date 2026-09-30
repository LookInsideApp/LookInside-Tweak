TARGET := iphone:clang:16.5:15.0
ARCHS := arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LookInsideTweakPrefs
LookInsideTweakPrefs_FILES = LITRootListController.m LITAppListController.m
LookInsideTweakPrefs_FRAMEWORKS = UIKit
LookInsideTweakPrefs_PRIVATE_FRAMEWORKS = Preferences
LookInsideTweakPrefs_INSTALL_PATH = /Library/PreferenceBundles
LookInsideTweakPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
