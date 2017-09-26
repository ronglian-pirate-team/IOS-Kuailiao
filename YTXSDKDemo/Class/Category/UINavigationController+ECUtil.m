//
//  UINavigationController+ECUtil.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/7.
//

#import "UINavigationController+ECUtil.h"

@implementation UINavigationController (ECUtil)

- (void)ec_pushViewController:(UIViewController *)viewController animated:(BOOL)animated data:(id)data {
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_Nav_PushData object:data];
    [self pushViewController:viewController animated:animated];
}

@end
