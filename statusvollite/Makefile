export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = statusvolLite
statusvolLite_FILES = Tweak.xm
statusvolLite_FRAMEWORKS = UIKit AudioToolbox CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += statusvolliteprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
