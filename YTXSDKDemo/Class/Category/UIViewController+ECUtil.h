//
//  UIViewController+ECUtil.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/12.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ECUtil)
- (void)ec_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion data:(id)data;
@end
