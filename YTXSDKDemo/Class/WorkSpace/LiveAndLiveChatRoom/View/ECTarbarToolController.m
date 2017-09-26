//
//  ECTarbarToolController.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/17.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ECTarbarToolController.h"
#import "LiveChatRoomBaseModel.h"
#import "ECLiveRoomAniTool.h"

@interface ECTarbarToolController ()<UIAlertViewDelegate>
@property (nonatomic, strong) UIButton *msgBtn;
@property (nonatomic, strong) UIButton *myBtn;
@property (nonatomic, strong) UIButton *heartBtn;
@property (nonatomic, strong) UIButton *giftBtn;
@property (nonatomic, strong) UIButton *exitBtn;
@end

@implementation ECTarbarToolController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建子页面
    [self prepareUI];
}

- (void)prepareUI {
    [self.view addSubview:self.msgBtn];
    [self.view addSubview:self.myBtn];
    [self.view addSubview:self.heartBtn];
    [self.view addSubview:self.giftBtn];
    [self.view addSubview:self.exitBtn];
    
    CGFloat height = 60.0f;
    NSInteger count = 5;
    CGFloat margin = (EC_kScreenW- height*count)/(count+1);
    
    __weak typeof(self)weakSelf = self;
    [self.exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset(margin);
        make.centerY.equalTo(weakSelf.view.mas_centerY);
        make.width.offset(height);
        make.bottom.equalTo(weakSelf.view).offset(-20.0f);
    }];
    
    [self.myBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.exitBtn.mas_right).offset(margin);
        make.centerY.equalTo(weakSelf.view.mas_centerY);
        make.width.offset(height);
        make.bottom.equalTo(weakSelf.view).offset(-20.0f);
    }];
    
    [self.msgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.myBtn.mas_right).offset(margin);
        make.centerY.equalTo(weakSelf.view.mas_centerY);
        make.width.offset(height);
        make.bottom.equalTo(weakSelf.view).offset(-20.0f);
    }];
    
    [self.giftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.msgBtn.mas_right).offset(margin);
        make.centerY.equalTo(weakSelf.view.mas_centerY);
        make.width.offset(height);
        make.bottom.equalTo(weakSelf.view).offset(-20.0f);
    }];
    
    [self.heartBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.view).offset(-margin);
        make.centerY.equalTo(weakSelf.view.mas_centerY);
        make.width.offset(height);
        make.bottom.equalTo(weakSelf.view).offset(-20.0f);
    }];
}

#pragma mark - 按钮点击
- (void)msgBtnClicked:(UIButton *)sender {
    BOOL isSelected = sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(LiveToolBar:ClickedBtn:)]) {
        [self.delegate LiveToolBar:self ClickedBtn:_msgBtn];
    }
    isSelected = !isSelected;
    sender.selected = isSelected;
}

- (void)heartBtnClicked:(UIButton *)sender {
    
    UIImage *img = [UIImage imageNamed:@"heart_0"];
    UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"heart_%d",(int)(arc4random() % 6)]]];
//    CGFloat x = CGRectGetMinX(sender.frame);
//    CGFloat y = CGRectGetMinY(sender.frame);
//    imgV.frame = CGRectMake(x, y, img.size.width*2, img.size.height*2);
//    [self.view addSubview:imgV];
//    CAKeyframeAnimation *ani = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//    ani.values = @[
//                   [NSValue valueWithCGPoint:(CGPoint){x,y}],
//                   [NSValue valueWithCGPoint:(CGPoint){EC_kScreenW-40,y-100}],
//                   [NSValue valueWithCGPoint:(CGPoint){EC_kScreenW-80,y-200}],
//                   [NSValue valueWithCGPoint:(CGPoint){EC_kScreenW-100,y-280}],
//                   [NSValue valueWithCGPoint:(CGPoint){EC_kScreenW-140,y-340}],
//                   [NSValue valueWithCGPoint:(CGPoint){EC_kScreenW+imgV.size.width,-imgV.size.width}]
//                   ];
//    ani.duration = 3;
//    ani.removedOnCompletion = NO;
//    ani.fillMode = kCAFillModeForwards;
//    [imgV.layer addAnimation:ani forKey:@"heartP"];
    
    CAKeyframeAnimation *scalAni = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scalAni.values = @[@(1.0),@(0.7),@(0.5),@(0.3),@(0.5),@(0.7),@(1.0), @(1.2), @(1.4), @(1.2), @(1.0)];
    scalAni.keyTimes = @[@(0.0),@(0.1),@(0.2),@(0.3),@(0.4),@(0.5),@(0.6),@(0.7),@(0.8),@(0.9),@(1.0)];
    scalAni.calculationMode = kCAAnimationLinear;
    scalAni.duration = 0.3;
    [sender.layer addAnimation:scalAni forKey:@"heart"];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(LiveToolBar:ClickedBtn:)]) {
        [self.delegate LiveToolBar:self ClickedBtn:_heartBtn];
    }
}

- (void)giftBtnClicked:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(LiveToolBar:ClickedBtn:)]) {
        [self.delegate LiveToolBar:self ClickedBtn:_giftBtn];
    }
}

- (void)exitClicked:(UIButton *)sender {
    
    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"是否退出聊天室" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
}

- (void)myBtnClicked:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(LiveToolBar:ClickedBtn:)]) {
        [self.delegate LiveToolBar:self ClickedBtn:_myBtn];
    }
}
#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex!=buttonIndex) {
        if ([LiveChatRoomBaseModel sharedInstanced].cancelBlack) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(LiveToolBar:ClickedBtn:)]) {
                [self.delegate LiveToolBar:self ClickedBtn:_exitBtn];
            }
            [LiveChatRoomBaseModel sharedInstanced].cancelBlack = NO;
            return;
        }
        ECExitLiveChatRoomRequest *request = [[ECExitLiveChatRoomRequest alloc] init];
        request.roomId =[LiveChatRoomBaseModel sharedInstanced].roomModel.roomId;
        [[ECDevice sharedInstance].liveChatRoomManager exitLiveChatRoom:request completion:^(ECError *error, NSString *roomId) {
            if (error.errorCode != ECErrorType_NoError) {
                [ECCommonTool toast:[NSString stringWithFormat:@"%ld",(long)error.errorCode]];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(LiveToolBar:ClickedBtn:)]) {
                [self.delegate LiveToolBar:self ClickedBtn:_exitBtn];
            }
        }];
    }
}

#pragma mark - 懒加载
- (UIButton *)msgBtn {
    if (!_msgBtn) {
        _msgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_msgBtn setImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
        [_msgBtn addTarget:self action:@selector(msgBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _msgBtn.tag = EC_MsgBtn_tag;
    }
    return _msgBtn;
}

- (UIButton *)myBtn {
    if (!_myBtn) {
        _myBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_myBtn setImage:[UIImage imageNamed:@"def_usericon1"] forState:UIControlStateNormal];
        [_myBtn addTarget:self action:@selector(myBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _myBtn.tag = EC_MyBtn_tag;
    }
    return _myBtn;
}

- (UIButton *)heartBtn {
    if (!_heartBtn) {
        _heartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_heartBtn setImage:[UIImage imageNamed:@"love"] forState:UIControlStateNormal];
        [_heartBtn addTarget:self action:@selector(heartBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _heartBtn.layer.shadowColor = [UIColor blackColor].CGColor;
        _heartBtn.layer.shadowOffset = CGSizeMake(0, 0);
        _heartBtn.layer.shadowOpacity = 0.5;
        _heartBtn.layer.shadowRadius = 1;
        _heartBtn.adjustsImageWhenHighlighted = NO;
        _heartBtn.tag = EC_HeartBtn_tag;
    }
    
    return _heartBtn;
}

- (UIButton *)giftBtn {
    if (!_giftBtn) {
        _giftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_giftBtn setImage:[UIImage imageNamed:@"gift"] forState:UIControlStateNormal];
        [_giftBtn addTarget:self action:@selector(giftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _giftBtn.tag = EC_GiftBtn_tag;
    }
    return _giftBtn;
}

- (UIButton *)exitBtn {
    if (!_exitBtn) {
        _exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_exitBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_exitBtn addTarget:self action:@selector(exitClicked:) forControlEvents:UIControlEventTouchUpInside];
        _exitBtn.tag = EC_EixtBtn_tag;
    }
    return _exitBtn;
}
@end
