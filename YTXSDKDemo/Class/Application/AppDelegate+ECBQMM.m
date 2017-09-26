//
//  AppDelegate+ECBQMM.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/18.
//

#import "AppDelegate+ECBQMM.h"
#import <BQMM/BQMM.h>

@implementation AppDelegate (ECBQMM)

/**
 @brief 配置表情
 */
- (void)ec_configBQMM:(NSArray *)array {
    [[MMEmotionCentre defaultCentre] setDefaultEmojiArray:array];
    [MMEmotionCentre defaultCentre].sdkMode = MMSDKModeIM;
    [MMEmotionCentre defaultCentre].sdkLanguage = MMLanguageChinese;
    [MMEmotionCentre defaultCentre].sdkRegion = MMRegionOther;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [[MMEmotionCentre defaultCentre] clearSession];
    }];
}

@end
