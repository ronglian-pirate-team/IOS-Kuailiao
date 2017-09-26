//
//  ECBaseContoller.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/19.
//  Copyright © 2017年 huangjue. All rights reserved.
//

#import <UIKit/UIKit.h>

#define EC_DEMO_kNotification_ClickNav_Item @"EC_DEMO_kNotification_ClickNav_Item"//点击导航栏上的左右item

typedef id (^ECBaseItemBlock)();
typedef void (^ECBaseCompletionOneObjectBlock)(id data);
typedef void (^ECBaseCompletionTwoObjectBlock)(id data1,id data2);


@class ECBaseContoller;
@protocol ECBaseContollerDelegate <NSObject>

@optional

- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString **)str;
- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configLeftBtnItemWithStr:(NSString **)str;

@end

@interface ECBaseContoller : UIViewController

@property (nonatomic, weak) id<ECBaseContollerDelegate> baseDelegate;

@property (nonatomic, strong) ECBaseCompletionOneObjectBlock baseOneObjectCompletion;
@property (nonatomic, strong) ECBaseCompletionTwoObjectBlock baseTwoObjectCompletion;
@property (nonatomic, strong) id baseToData;
@property (nonatomic, strong) id basePushData;

@property (nonatomic, strong) NSMutableArray *baseDataArray;

- (void)buildUI;
- (void)ec_addNotify;

- (void)showNothingView:(NSString *)nothingTitle;
- (void)hiddenNothingView;

@end
