//
//  UINavigationController+ECUtil.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/7.
//

#import <UIKit/UIKit.h>

#define EC_DEMO_kNotification_Nav_PushData @"EC_DEMO_kNotification_Nav_PushData"

@interface UINavigationController (ECUtil)
- (void)ec_pushViewController:(UIViewController *)viewController animated:(BOOL)animated data:(id)data;
@end
