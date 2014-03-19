export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = bolt
bolt_FILES = Tweak.xm
bolt_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
