//
//  UIViewController+ECUtil.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/12.
//

#import "UIViewController+ECUtil.h"

@implementation UIViewController (ECUtil)


- (void)ec_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion data:(id)data {
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_Nav_PushData object:data];
    [self presentViewController:viewControllerToPresent animated:flag completion:completion];
}
@end
