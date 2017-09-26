//
//  ECTarbarToolController.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/17.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

#define EC_ViewH 80.0f
#define EC_MsgBtn_tag  10001
#define EC_HeartBtn_tag  10002
#define EC_GiftBtn_tag  10003
#define EC_EixtBtn_tag  10004
#define EC_MyBtn_tag  10005



@class ECTarbarToolController;

@protocol LiveToolBarDelegate <NSObject>
- (void)LiveToolBar:(ECTarbarToolController *)toolBar ClickedBtn:(UIButton *)sender;
@end

@interface ECTarbarToolController : UIViewController
@property (nonatomic, weak) id<LiveToolBarDelegate> delegate;
@end
