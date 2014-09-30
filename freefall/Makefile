export ARCHS = armv7 arm64
export TARGET := iphone:clang

include theos/makefiles/common.mk

TWEAK_NAME = FreeFall
FreeFall_FILES = Tweak.xm
FreeFall_FRAMEWORKS = CoreMotion AudioToolbox

include $(THEOS_MAKE_PATH)/tweak.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/FreeFall$(ECHO_END)
	$(ECHO_NOTHING)cp -r resources/* $(THEOS_STAGING_DIR)/Library/FreeFall/$(ECHO_END)

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += freefallprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
