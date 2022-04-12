// ForceInPicture https://github.com/PoomSmart/ForceInPicture
#import "Tweaks/PSHeader/Misc.h"
#import <substrate.h>
#import <CoreFoundation/CoreFoundation.h>

extern "C" bool MGGetBoolAnswer(CFStringRef);
%hookf(bool, MGGetBoolAnswer, CFStringRef key) {
    if (CFStringEqual(key, CFSTR("nVh/gwNpy7Jv1NOk00CMrw")))
        return YES;
    return %orig;
}
