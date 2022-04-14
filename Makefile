GO_EASY_ON_ME = 1
DEBUG = 0
FINALPACKAGE = 1

ARCHS = arm64
TARGET = iphone:clang:latest:13.0

THEOS_DEVICE_IP = 192.168.0.16

TWEAK_NAME = uYouPlus
uYouPlus_FILES = uYouPlus.xm
uYouPlus_CFLAGS = -fobjc-arc

SUBPROJECTS += Tweaks/iSponsorBlock Tweaks/YTUHD Tweaks/YouPiP Tweaks/Return-YouTube-Dislikes Tweaks/YTSpeed

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
