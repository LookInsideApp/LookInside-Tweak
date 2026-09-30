TARGET := iphone:clang:16.5:15.0
ARCHS := arm64 arm64e
INSTALL_TARGET_PROCESSES = Preferences

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LookInsideTweak
LookInsideTweak_FILES = Tweak/Loader.m
LookInsideTweak_CFLAGS = -fobjc-arc
LookInsideTweak_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk

SERVER_FRAMEWORK = layout/Library/Frameworks/LookInsideServer.framework

before-package::
	@test -f $(SERVER_FRAMEWORK)/LookInsideServer || { echo "Missing $(SERVER_FRAMEWORK). Run make server first."; exit 1; }

.PHONY: server
server:
	Scripts/fetch-server.sh
