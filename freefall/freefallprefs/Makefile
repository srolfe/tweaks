include theos/makefiles/common.mk

BUNDLE_NAME = FreeFallPrefs
FreeFallPrefs_FILES = FreeFallPrefs.mm
FreeFallPrefs_INSTALL_PATH = /Library/PreferenceBundles
FreeFallPrefs_FRAMEWORKS = UIKit
FreeFallPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/FreeFallPrefs.plist$(ECHO_END)
