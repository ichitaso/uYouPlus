GO_EASY_ON_ME = 1
DEBUG = 0
FINALPACKAGE = 1
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

ARCHS = arm64
TARGET = iphone:clang:latest:13.0

THEOS_DEVICE_IP = 192.168.0.16

TWEAK_NAME = uYouPlus
uYouPlus_FILES = uYouPlus.x
uYouPlus_CFLAGS = -fobjc-arc

SUBPROJECTS += Tweaks/iSponsorBlock Tweaks/YTSpeed Tweaks/YTUHD Tweaks/YouPiP Tweaks/Return-YouTube-Dislikes

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "sbreload"
