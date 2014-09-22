include theos/makefiles/common.mk

BUNDLE_NAME = FreeFallSettings
FreeFallSettings_FILES = FreeFallSettings.mm
FreeFallSettings_INSTALL_PATH = /Library/PreferenceBundles
FreeFallSettings_FRAMEWORKS = UIKit
FreeFallSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/FreeFallSettings.plist$(ECHO_END)
