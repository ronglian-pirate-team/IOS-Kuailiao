//
//  UIButton+ECUtil.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/17.
//

#import "UIButton+ECUtil.h"

@implementation UIButton (ECUtil)

- (void)sendVerfyStatus {
    self.enabled = NO;
    __block NSInteger seconds = 59;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (seconds<=0) {
            dispatch_source_cancel(timer);
            self.enabled = YES;
            [self setTitle:@"收不到验证码?" forState:UIControlStateNormal];
            [self setTitle:@"收不到验证码?" forState:UIControlStateDisabled];
        } else {
            int _second = seconds % 60;
            [self setTitle:[NSString stringWithFormat:@"接收短信大约需要(%d)秒",_second] forState:UIControlStateDisabled];
            [self setTitle:[NSString stringWithFormat:@"接收短信大约需要(%d)秒",_second] forState:UIControlStateNormal];
            seconds--;
        }
        [self sizeToFit];
    });
    dispatch_resume(timer);
}

@end
