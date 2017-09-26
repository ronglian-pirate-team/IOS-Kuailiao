//
//  ECGiftView.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/6/21.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

#define EC_LIVEROOM_GiftViewH 320.0f

#define EC_LiveRoom_SendRacingCarGift  @"EC_LiveRoom_SendRacingCarGift"
#define EC_LiveRoom_SendLoveGift @"EC_LiveRoom_SendLoveGift"
#define EC_LiveRoom_SendqiqiuGift @"EC_LiveRoom_SendqiqiuGift"

#define EC_LiveRoom_SendOtherGift @"EC_LiveRoom_SendOtherGift"


@interface ECGiftView : UIView
+ (instancetype)sharedInstanced;

- (void)setDefaultArray:(NSArray *)array;

- (void)animationWithView:(UIView *)superView;

- (void)switchDefault;
@end
