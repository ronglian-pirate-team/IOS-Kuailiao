//
//  ECLiveRoomAniTool.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/6/23.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^Completion)();

@interface ECLiveRoomAniTool : NSObject

+ (instancetype)sharedInstanced;

- (void)baseAnimationWithSupView:(UIView *)supView gifName:(NSString *)gifN;

- (void)racingCarAnimationWithView:(UIView *)view block:(Completion)block;
@end
