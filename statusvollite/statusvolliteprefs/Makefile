export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

BUNDLE_NAME = StatusVolLiteprefs
StatusVolLiteprefs_FILES = StatusVolLiteprefs.mm statusVolLiteHeader.m themeListController.m animationListController.m legacyListController.m SVLSwitchTableCell.m SVLSliderTableCell.m
StatusVolLiteprefs_INSTALL_PATH = /Library/PreferenceBundles
StatusVolLiteprefs_FRAMEWORKS = UIKit
StatusVolLiteprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/StatusVolLiteprefs.plist$(ECHO_END)
