include theos/makefiles/common.mk

BUNDLE_NAME = statusvolprefs
statusvolprefs_FILES = statusvolprefs.mm
statusvolprefs_INSTALL_PATH = /Library/PreferenceBundles
statusvolprefs_FRAMEWORKS = UIKit
statusvolprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/statusvolprefs.plist$(ECHO_END)
