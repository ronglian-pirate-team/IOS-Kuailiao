//
//  ECAlertController.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/25.
//

#import <UIKit/UIKit.h>

@interface ECAlertController : UIAlertController

+ (instancetype)alertControllerWithTitle:(NSString *)title
                                 message:(NSString *)message
                             cancelTitle:(NSString *)cancelTitle
                        DestructiveTitle:(NSArray *)DestructiveTitleArray
                        DefautTitleArray:(NSArray *)DefautTitleArray
                              showInView:(UIViewController *)viewController
                                 handler:(void (^)(UIAlertAction *action))handler;

+ (instancetype)sheetControllerWithTitle:(NSString *)title
                                 message:(NSString *)message
                             cancelTitle:(NSString *)cancelTitle
                        DestructiveTitle:(NSArray *)DestructiveTitleArray
                        DefautTitleArray:(NSArray *)DefautTitleArray
                              showInView:(UIViewController *)viewController
                                 handler:(void (^)(UIAlertAction *action))handler;

@end
