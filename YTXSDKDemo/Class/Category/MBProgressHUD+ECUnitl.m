//
//  MBProgressHUD+ECUnitl.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/8.
//

#import "MBProgressHUD+ECUnitl.h"

#define EC_HUD_AutoHidden_Duration 2.0f

@implementation MBProgressHUD (ECUnitl)

+ (void)ec_ShowHUD:(UIView *)view withMessage:(NSString *)message {
    [self ec_Base_ShowHUD:view withMessage:message duration:0];
}

+ (void)ec_ShowHUD_AutoHidden:(UIView *)view withMessage:(NSString *)message {
    [self ec_Base_ShowHUD:view withMessage:message duration:EC_HUD_AutoHidden_Duration];
}

+ (void)ec_Base_ShowHUD:(UIView *)view withMessage:(NSString *)message duration:(CGFloat)duration {
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.margin = 10.0f;
    hud.label.text = message;
    hud.removeFromSuperViewOnHide = YES;
    if (duration>0)
        [hud hideAnimated:YES afterDelay:duration];
}
@end
