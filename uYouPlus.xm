#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Workaround for https://github.com/MiRO92/uYou-for-YouTube/issues/12

%hook YTAdsInnerTubeContextDecorator
- (void)decorateContext:(id)arg1 {
    %orig(nil);
}
%end


// YouRememberCaption: https://poomsmart.github.io/repo/depictions/youremembercaption.html

%hook YTColdConfig
- (BOOL)respectDeviceCaptionSetting {
    return NO;
}
%end


// YTClassicVideoQuality: https://github.com/PoomSmart/YTClassicVideoQuality

@interface YTVideoQualitySwitchOriginalController : NSObject
- (instancetype)initWithParentResponder:(id)responder;
@end

%hook YTVideoQualitySwitchControllerFactory

- (id)videoQualitySwitchControllerWithParentResponder:(id)responder {
    Class originalClass = %c(YTVideoQualitySwitchOriginalController);
    return originalClass ? [[originalClass alloc] initWithParentResponder:responder] : %orig;
}
%end


// YTNoCheckLocalNetwork: https://poomsmart.github.io/repo/depictions/ytnochecklocalnetwork.html

%hook YTHotConfig

- (BOOL)isPromptForLocalNetworkPermissionsEnabled {
    return NO;
}
%end

// YTNoHoverCards: https://github.com/level3tjg/YTNoHoverCards

@interface YTCollectionViewCell : UICollectionViewCell
@end

@interface YTSettingsCell : YTCollectionViewCell
@end

@interface YTSettingsSectionItem : NSObject
@property BOOL hasSwitch;
@property BOOL switchVisible;
@property BOOL on;
@property BOOL (^switchBlock)(YTSettingsCell *, BOOL);
@property int settingItemId;
+ (instancetype)switchItemWithTitle:(NSString *)title titleDescription:(NSString *)titleDescription accessibilityIdentifier:(NSString *)accessibilityIdentifier switchOn:(BOOL)switchOn switchBlock:(BOOL (^)(YTSettingsCell *, BOOL))switchBlock settingItemId:(int)settingItemId;
- (instancetype)initWithTitle:(NSString *)title titleDescription:(NSString *)titleDescription;
@end

%hook YTSettingsViewController
- (void)setSectionItems:(NSMutableArray <YTSettingsSectionItem *>*)sectionItems forCategory:(NSInteger)category title:(NSString *)title titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden {
	if (category == 1) {
        NSUInteger defaultPiPIndex = [sectionItems indexOfObjectPassingTest:^BOOL (YTSettingsSectionItem *item, NSUInteger idx, BOOL *stop) {
            return item.settingItemId == 294;
        }];
        if (defaultPiPIndex == NSNotFound) {
            defaultPiPIndex = [sectionItems indexOfObjectPassingTest:^BOOL (YTSettingsSectionItem *item, NSUInteger idx, BOOL *stop) {
                return [[item valueForKey:@"_accessibilityIdentifier"] isEqualToString:@"id.settings.restricted_mode.switch"];
            }];
        }
        if (defaultPiPIndex != NSNotFound) {
            YTSettingsSectionItem *hoverCardItem = [%c(YTSettingsSectionItem) switchItemWithTitle:@"Show End screens hover cards" titleDescription:@"Allows creator End screens (thumbnails) to appear at the end of videos"
            accessibilityIdentifier:nil
            switchOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"hover_cards_enabled"]
            switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hover_cards_enabled"];
                return YES;
            }
            settingItemId:0];
			[sectionItems insertObject:hoverCardItem atIndex:defaultPiPIndex + 1];
		}
	}
    %orig(sectionItems, category, title, titleDescription, headerHidden);
}
%end

%hook YTCreatorEndscreenView
- (void)setHidden:(BOOL)hidden {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hover_cards_enabled"])
		hidden = YES;
	%orig;
}
%end


// YTSystemAppearance: https://poomsmart.github.io/repo/depictions/ytsystemappearance.html

%hook YTColdConfig
- (BOOL)shouldUseAppThemeSetting {
    return YES;
}
%end

// YTSpeed: https://github.com/Lyvendia/YTSpeed
#define DEFAULT_RATE 2.0f

@interface YTVarispeedSwitchControllerOption : NSObject
- (id)initWithTitle:(id)title rate:(float)rate;
@end

@interface YTPlayerViewController : NSObject
@property id activeVideo;
@property float playbackRate;
- (void)singleVideo:(id)video playbackRateDidChange:(float)rate;
@end

@interface MLHAMQueuePlayer : NSObject
@property id playerEventCenter;
@property id delegate;
- (void)setRate:(float)rate;
- (void)internalSetRate;
@end

@interface MLPlayerStickySettings : NSObject
- (void)setRate:(float)rate;
@end

@interface MLPlayerEventCenter : NSObject
- (void)broadcastRateChange:(float)rate;
@end

@interface YTSingleVideoController : NSObject
- (void)playerRateDidChange:(float)rate;
@end

@interface HAMPlayerInternal : NSObject
- (void)setRate:(float)rate;
@end

%hook YTVarispeedSwitchController

- (id)init {
    id result = %orig;

    const int size = 14;
    float speeds[] = {0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 2.75, 3.0, 3.5, 4.0};
    id varispeedSwitchControllerOptions[size];

    for (int i = 0; i < size; ++i) {
        id title = [NSString stringWithFormat:@"%.2fx", speeds[i]];
        varispeedSwitchControllerOptions[i] = [[%c(YTVarispeedSwitchControllerOption) alloc] initWithTitle:title rate:speeds[i]];
    }

    NSUInteger count = sizeof(varispeedSwitchControllerOptions) / sizeof(id);
    NSArray *varispeedArray = [NSArray arrayWithObjects:varispeedSwitchControllerOptions count:count];
    MSHookIvar<NSArray *>(self, "_options") = varispeedArray;

    return result;
}

%end

%hook YTPlayerViewController
%property float playbackRate;

- (id)initWithServiceRegistryScope:(id)serviceRegistryScope parentResponder:(id)parentResponder overlayFactory:(id)overlayFactory {
    float savedRate = [[NSUserDefaults standardUserDefaults] floatForKey:@"YoutubeSpeed_PlaybackRate"];
    self.playbackRate = savedRate == 0 ? DEFAULT_RATE : savedRate;
    return %orig;
}

- (void)singleVideo:(id)video playbackRateDidChange:(float)rate {
    %orig;
}

- (float)currentPlaybackRateForVarispeedSwitchController:(id)varispeedSwitchController {
    return self.playbackRate;
}

- (void)varispeedSwitchController:(id)varispeedSwitchController didSelectRate:(float)rate {
    self.playbackRate = rate;
    [[NSUserDefaults standardUserDefaults] setFloat: rate forKey:@"YoutubeSpeed_PlaybackRate"];
    if (rate > 2.0f) {
        [self singleVideo:self.activeVideo playbackRateDidChange: rate];
    }
    %orig;
}

%end


%hook MLHAMQueuePlayer

- (id)initWithStickySettings:(id)stickySettings playerViewProvider:(id)playerViewProvider {
    id result = %orig;
    float savedRate = [[NSUserDefaults standardUserDefaults] floatForKey:@"YoutubeSpeed_PlaybackRate"];
    [self setRate: savedRate == 0 ? DEFAULT_RATE : savedRate];
    return result;
}

- (void)setRate:(float)rate {
    MSHookIvar<float>(self, "_rate") = rate;
    MSHookIvar<float>(self, "_preferredRate") = rate;

    id player = MSHookIvar<HAMPlayerInternal *>(self, "_player");
    [player setRate: rate];

    id stickySettings = MSHookIvar<MLPlayerStickySettings *>(self, "_stickySettings");
    [stickySettings setRate: rate];

    [self.playerEventCenter broadcastRateChange: rate];

    YTSingleVideoController *singleVideoController = self.delegate;
    [singleVideoController playerRateDidChange: rate];
}

%end
