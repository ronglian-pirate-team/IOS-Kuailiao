//
//  ECLiveChatRoomBaseController.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/6/8.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ECLiveChatRoomBaseController.h"
#import "ECTarbarToolController.h"
#import "LiveChatRoomController.h"
#import "LiveChatRoomMemberController.h"
#import "EdtingLiveChatRoomMember.h"
#import "LiveChatRoomBaseModel.h"
#import "ECGiftView.h"
#import "YLImageView.h"
#import "YLGIFImage.h"
#import "ECLiveRoomAniTool.h"
#import "ECLiveRoomShow.h"
#import "CustomEmojiView.h"
#import "DMHeartFlyView.h"

@interface ECLiveChatRoomBaseController ()<LiveToolBarDelegate>
@property (nonatomic, strong) LiveChatRoomController *chatRoomVC;
@property (nonatomic, strong) ECTarbarToolController *tabrToolVC;
@property (nonatomic, strong) LiveChatRoomMemberController *memberListVC;
@property (nonatomic, strong) YLImageView *imgV;
@property (nonatomic, strong) ECLiveRoomShow *giftShow;
@end

@implementation ECLiveChatRoomBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickTable:) name:EC_kNotificationCenter_ClickMessageSender object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startGiftAnimation:) name:EC_KNOTIFICATION_onLiveChatRoomMesssageChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startGiftAnimation:) name:EC_KNOTIFICATION_SendLiveChatRoomMessageCompletion object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self prepareUI];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)prepareUI {
    LiveChatRoomMemberController *memberListVC = [[LiveChatRoomMemberController alloc] init];
    _memberListVC = memberListVC;
    memberListVC.view.frame = CGRectMake(0, 20, self.view.frame.size.width, 80.0f);
    memberListVC.roomId = self.roomId;
    memberListVC.block = ^(ECLiveChatRoomMember *member) {
        EdtingLiveChatRoomMember* view = [EdtingLiveChatRoomMember animation:self.view];
        view.member = member;
    };
    memberListVC.vcBlock = ^(LiveChatRoomInfoController *vc) {
        for (UIViewController *subvc in self.childViewControllers) {
            if ([subvc isKindOfClass:[LiveChatRoomInfoController class]]) {
                [subvc removeFromParentViewController];
                [subvc.view removeFromSuperview];
            }
        }
        [self addChildViewController:vc];
        [self.view addSubview:vc.view];
        
        CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"position"];
        ani.fromValue = [NSValue valueWithCGRect:CGRectMake(self.view.frame.size.width/2.0f, self.view.frame.size.height,280 , EC_LiveRoom_InfoH)];
        ani.toValue = [NSValue valueWithCGPoint:self.view.center];
        ani.duration = 0.25f;
        ani.removedOnCompletion = NO;
        [vc.view.layer addAnimation:ani forKey:@"positionToCenter"];
    };
    [self addChildViewController:memberListVC];
    [self.view addSubview:memberListVC.view];
    
    LiveChatRoomController *chatRoomVC = [[LiveChatRoomController alloc] init];
    _chatRoomVC = chatRoomVC;
    _chatRoomVC.chatRoomId = self.roomId;
    chatRoomVC.view.frame = CGRectMake(0, self.view.frame.size.height-EC_ViewH-ECMsgH-30.0f, self.view.frame.size.width*0.8, ECMsgH);
    [self addChildViewController:chatRoomVC];
    [self.view addSubview:chatRoomVC.view];
    
    ECTarbarToolController *tabrToolVC = [[ECTarbarToolController alloc] init];
    _tabrToolVC = tabrToolVC;
    tabrToolVC.view.frame = CGRectMake(0, self.view.frame.size.height-EC_ViewH, self.view.frame.size.width, EC_ViewH);
    tabrToolVC.delegate = self;
    [self addChildViewController:tabrToolVC];
    [self.view addSubview:tabrToolVC.view];
    
}

- (void)clickTable:(NSNotification *)noti {
    [self hiddenKeyBoard];
    if (!noti.object)
        return;
    ECMessage *msg = (ECMessage *)noti.object;
    [self popToMemerInfo:msg.from];
}

- (void)popToMemerInfo:(NSString *)userId {
    [[ECDevice sharedInstance].liveChatRoomManager queryLiveChatRoomMember:self.roomId userId:userId completion:^(ECError *error, ECLiveChatRoomMember *member) {
        
        if (error.errorCode == ECErrorType_NoError && member) {
            EdtingLiveChatRoomMember* view = [EdtingLiveChatRoomMember animation:self.view];
            view.member = member;
            [LiveChatRoomBaseModel sharedInstanced].nickName = member.nickName;
        }
    }];
}
#pragma mark - LiveToolBarDelegate
- (void)LiveToolBar:(ECTarbarToolController *)toolBar ClickedBtn:(UIButton *)sender {
    
    if (sender.tag == EC_MsgBtn_tag) {
        
        LiveChatRoomTool *chatToolView = [LiveChatRoomTool sharedInstanced];
        [chatToolView becomeFirstResponder];
        chatToolView.frame = CGRectMake(0, self.view.frame.size.height-ECToolViewH, self.view.frame.size.width, ECToolViewH);
        self.tabrToolVC.view.hidden = YES;
        chatToolView.delegate = self.chatRoomVC;
        _memberListVC.view.hidden = YES;
        [self.view addSubview:chatToolView];
        
    } else if (sender.tag == EC_EixtBtn_tag) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KECNOTIFICATION_LIVECHATROOM_EIXT object:nil];
    } else if (sender.tag == EC_GiftBtn_tag) {
        [[ECGiftView sharedInstanced] animationWithView:self.view];
    } else if (sender.tag == EC_MyBtn_tag) {
        [self popToMemerInfo:[ECAppInfo sharedInstanced].userName];
    } else if (sender.tag == EC_HeartBtn_tag) {
        CGFloat heartSize = 36;
        DMHeartFlyView* heart = [[DMHeartFlyView alloc] initWithFrame:CGRectMake(0, 0, heartSize, heartSize)];
        [self.view addSubview:heart];
        CGRect frame = [sender.superview convertRect:sender.frame toView:self.view];
        CGFloat x = CGRectGetMinX(frame);
        CGFloat y = CGRectGetMinY(frame);
        heart.center = CGPointMake(x + heartSize/2.0, y);
        [heart animateInView:self.view];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self hiddenKeyBoard];
}

- (void)hiddenKeyBoard {
    [self.view endEditing:YES];
    [[LiveChatRoomTool sharedInstanced] removeFromSuperview];
    [[ECGiftView sharedInstanced] switchDefault];
    self.tabrToolVC.view.hidden = NO;
    _memberListVC.view.hidden = NO;
}

- (void)startGiftAnimation:(NSNotification *)noti {
    ECMessage *msg = nil;
    if ([noti.userInfo isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = noti.userInfo;
        ECError *error = dict[EC_KErrorKey];
        msg = dict[EC_KMessageKey];
        if (error.errorCode != ECErrorType_NoError) {
            return;
        }
    }
    if (noti.object) {
        msg = (ECMessage *)noti.object;
    }
    if (![msg.to isEqualToString:self.roomId]) {
        return;
    }
    if (msg.userData) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[msg.userData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        for (NSString *key in dict.allKeys) {
            
            NSString *value = [NSString stringWithFormat:@"%@.gif",dict[key]];
            if ([key isEqualToString:EC_LiveRoom_SendRacingCarGift]) {
                
                _imgV = [[YLImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 100.0f, 275.0f, 235.0f)];
                _imgV.image = [YLGIFImage imageNamed:value];
                [self.view addSubview:_imgV];
                [[ECLiveRoomAniTool sharedInstanced] racingCarAnimationWithView:_imgV block:^{
                    [_imgV removeFromSuperview];
                }];
            } else if ([key isEqualToString:EC_LiveRoom_SendLoveGift]) {
                [[ECLiveRoomAniTool sharedInstanced] baseAnimationWithSupView:self.view gifName:value];
            } else if([key isEqualToString:EC_LiveRoom_SendOtherGift]) {
                if (!_giftShow) {
                    _giftShow = [ECLiveRoomShow showView:self.view];
                } else {
                    [_giftShow doubleClicked];
                }
            }
        }
    }
}


@end
