export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = statusvol statusvolKit
statusvol_FILES = statusvol.xm
statusvolKit_FILES = statusvolKit.xm
statusvol_FRAMEWORKS = UIKit QuartzCore CoreGraphics
statusvolKit_FRAMEWORKS = UIKit
statusvol_LIBRARIES = rocketbootstrap
statusvolKit_LIBRARIES = rocketbootstrap

include $(THEOS_MAKE_PATH)/tweak.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/StatusVol$(ECHO_END)
	$(ECHO_NOTHING)cp -r skins/* $(THEOS_STAGING_DIR)/Library/StatusVol/$(ECHO_END)

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += statusvolprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
