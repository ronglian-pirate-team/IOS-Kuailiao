//
//  ECAlertController.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/25.
//

#import "ECAlertController.h"

@interface ECAlertController ()

@end

@implementation ECAlertController

+ (instancetype)alertControllerWithTitle:(NSString *)title
                                 message:(NSString *)message
                             cancelTitle:(NSString *)cancelTitle
                        DestructiveTitle:(NSArray *)DestructiveTitleArray
                        DefautTitleArray:(NSArray *)DefautTitleArray
                              showInView:(UIViewController *)viewController
                                 handler:(void (^)(UIAlertAction *action))handler {
    
    ECAlertController *aletrVC = [ECAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [aletrVC addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (handler)
            handler(action);
    }]];
    [DestructiveTitleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [aletrVC addAction:[UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (handler)
                handler(action);
        }]];
    }];
    [DefautTitleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [aletrVC addAction:[UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (handler)
                handler(action);
        }]];
    }];
    [viewController presentViewController:aletrVC animated:YES completion:nil];
    return aletrVC;
}


+ (instancetype)sheetControllerWithTitle:(NSString *)title
                                 message:(NSString *)message
                             cancelTitle:(NSString *)cancelTitle
                        DestructiveTitle:(NSArray *)DestructiveTitleArray
                        DefautTitleArray:(NSArray *)DefautTitleArray
                              showInView:(UIViewController *)viewController
                                 handler:(void (^)(UIAlertAction *action))handler {
    
    ECAlertController *aletrVC = [ECAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    [aletrVC addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (handler)
            handler(action);
    }]];
    [DestructiveTitleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [aletrVC addAction:[UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (handler)
                handler(action);
        }]];
    }];
    [DefautTitleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [aletrVC addAction:[UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (handler)
                handler(action);
        }]];
    }];
    [viewController presentViewController:aletrVC animated:YES completion:nil];
    return aletrVC;
}
@end
