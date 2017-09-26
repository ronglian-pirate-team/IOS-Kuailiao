//
//  MBProgressHUD+ECUnitl.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/8.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (ECUnitl)

+ (void)ec_ShowHUD:(UIView *)view withMessage:(NSString *)message;

+ (void)ec_ShowHUD_AutoHidden:(UIView *)view withMessage:(NSString *)message;

@end
