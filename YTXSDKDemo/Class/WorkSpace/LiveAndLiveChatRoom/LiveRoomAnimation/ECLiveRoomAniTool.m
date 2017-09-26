//
//  ECLiveRoomAniTool.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/6/23.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ECLiveRoomAniTool.h"
#import "YLImageView.h"
#import "YLGIFImage.h"
#import <objc/runtime.h>

static const char ec_objc_racing;

@interface ECLiveRoomAniTool ()<CAAnimationDelegate>

@end

@implementation ECLiveRoomAniTool
+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static ECLiveRoomAniTool *cls = nil;
    dispatch_once(&onceToken, ^{
        cls = [[[self class] alloc] init];
    });
    return cls;
}

- (void)racingCarAnimationWithView:(UIView *)view block:(Completion)block {
    CAKeyframeAnimation *ani = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    ani.values = @[
                   [NSValue valueWithCGPoint:(CGPoint){320,100}],
                   [NSValue valueWithCGPoint:(CGPoint){260,200}],
                   [NSValue valueWithCGPoint:(CGPoint){200,280}],
                   [NSValue valueWithCGPoint:(CGPoint){140,340}],
                   [NSValue valueWithCGPoint:(CGPoint){100,380}],
                   [NSValue valueWithCGPoint:(CGPoint){80,420}],
                   [NSValue valueWithCGPoint:(CGPoint){40,480}]
                   ];
    ani.duration = 3;
    ani.delegate = self;
    [view.layer addAnimation:ani forKey:@"racingCar"];
    if (block)
        objc_setAssociatedObject(self, &ec_objc_racing, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    Completion block = objc_getAssociatedObject(self, &ec_objc_racing);
    if (flag && block) {
        block();
    }
}

- (void)baseAnimationWithSupView:(UIView *)supView gifName:(NSString *)gifN {
    YLGIFImage *img = (YLGIFImage *)[YLGIFImage imageNamed:gifN];
    CGSize size = img.images[0].size;
    if (size.width>EC_kScreenW) {
        size.width = EC_kScreenW-40;
    }
    YLImageView *imgV = [[YLImageView alloc] initWithFrame:CGRectMake((EC_kScreenW-size.width)/2.0f, 120.0f, size.width, size.height)];
    imgV.image = img;
    [supView addSubview:imgV];
    NSLog(@"%@",NSStringFromCGSize(img.images[0].size));
    [NSTimer scheduledTimerWithTimeInterval:img.duration<2?2:img.duration target:self selector:@selector(baseTimer:) userInfo:imgV repeats:YES];
}

- (void)baseTimer:(NSTimer *)timer {
    if (!timer.userInfo)
        return;
    [(YLImageView *)timer.userInfo removeFromSuperview];
}
@end
