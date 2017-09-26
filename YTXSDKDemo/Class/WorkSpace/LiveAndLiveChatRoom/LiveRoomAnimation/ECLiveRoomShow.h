//
//  ECLiveRoomShow.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/6/26.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveGiftShowCustom.h"

@interface ECLiveRoomShow : NSObject

@property (nonatomic, strong) LiveGiftShowCustom *giftShow;

+ (instancetype)showView:(UIView *)superView;
- (void)doubleClicked;
@end
