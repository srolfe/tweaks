include theos/makefiles/common.mk

BUNDLE_NAME = messageColorsprefs
messageColorsprefs_FILES = messageColorsprefs.mm messageColorsHeader.m imColorController.m smsColorController.m rcvColorController.m NKOColorPickerView.m
messageColorsprefs_INSTALL_PATH = /Library/PreferenceBundles
messageColorsprefs_FRAMEWORKS = UIKit CoreGraphics
messageColorsprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/messageColorsprefs.plist$(ECHO_END)
