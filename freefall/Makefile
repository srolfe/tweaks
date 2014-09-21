export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = FreeFall
FreeFall_FILES = Tweak.xm
FreeFall_FRAMEWORKS = CoreMotion AudioToolbox

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = FreeFallBundle
FreeFallBundle_INSTALL_PATH = /Library/Application Support

include $(THEOS)/makefiles/bundle.mk

after-install::
	install.exec "killall -9 SpringBoard"
