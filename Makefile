INSTALL_TARGET_PROCESSES = Spotify

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Duplify

Duplify_FILES = Tweak.x
Duplify_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
