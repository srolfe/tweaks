export ARCHS = armv7 armv7s arm64
export ADDITIONAL_OBJCFLAGS = -fobjc-arc

include theos/makefiles/common.mk

TWEAK_NAME = messageColors
messageColors_FILES = Tweak.xm
messageColors_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += messagecolorsprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
