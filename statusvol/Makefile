export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = statusvol statusvolKit
statusvol_FILES = statusvol.xm
statusvolKit_FILES = statusvolKit.xm
statusvol_FRAMEWORKS = UIKit
statusvolKit_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
