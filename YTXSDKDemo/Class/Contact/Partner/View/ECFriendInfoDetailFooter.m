//
//  ECFriendInfoDetailFooter.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/23.
//
//

#import "ECFriendInfoDetailFooter.h"
#import "ECChatController.h"
#import "ECCallVoiceView.h"
#import "ECCallVideoView.h"

@interface ECFriendInfoDetailFooter()<UIActionSheetDelegate>

@end

@implementation ECFriendInfoDetailFooter

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self buildUI];
    }
    return self;
}

- (void)sendMessageAction{
    NSString *sessionId = self.friendInfo.useracc;
    ECSession *session = [[ECDBManager sharedInstanced].sessionMgr selectSession:sessionId];
    if(self.friendInfo.remarkName && self.friendInfo.remarkName.length > 0)
        session.sessionName = self.friendInfo.remarkName;
    else if(self.friendInfo.nickName && self.friendInfo.nickName.length > 0)
        session.sessionName = self.friendInfo.nickName;
    else
        session.sessionName = self.friendInfo.useracc;
    session.sessionId = sessionId;
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_ClickSession object:session];
    ECChatController *chatVC = [[ECChatController alloc] init];
    [[AppDelegate sharedInstanced].rootNav pushViewController:chatVC animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        ECCallVideoView *callView = [[ECCallVideoView alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, EC_kScreenH)];
        callView.callNumber = self.friendInfo.useracc;
        [callView show];
    }else if (buttonIndex == 1){
        ECCallVoiceView *callView = [[ECCallVoiceView alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, EC_kScreenH)];
        callView.callNumber = self.friendInfo.useracc;
        [callView show];
    }
}

- (void)chatAction{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"视频聊天", nil), NSLocalizedString(@"语音聊天", nil), nil];
    [actionSheet showInView:[AppDelegate sharedInstanced].currentVC.view];
}

- (void)buildUI{
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setTitle:NSLocalizedString(@"发消息", nil) forState:UIControlStateNormal];
    sendBtn.titleLabel.font = EC_Font_System(17);
    [sendBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendMessageAction) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.ec_radius = 4;
    sendBtn.backgroundColor = EC_Color_App_Main;
    [self addSubview:sendBtn];
    
    UIButton *chatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [chatBtn setTitle:NSLocalizedString(@"视频聊天", nil) forState:UIControlStateNormal];
    chatBtn.titleLabel.font = EC_Font_System(17);
    [chatBtn setTitleColor:EC_Color_Main_Text forState:UIControlStateNormal];
    chatBtn.backgroundColor = EC_Color_White;
    [chatBtn addTarget:self action:@selector(chatAction) forControlEvents:UIControlEventTouchUpInside];
    chatBtn.ec_radius = 4;
    [self addSubview:chatBtn];
    
    EC_WS(self)
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(43);
        make.left.equalTo(weakSelf).offset(21);
        make.right.equalTo(weakSelf).offset(-21);
        make.height.offset(47);
    }];
    [chatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sendBtn.mas_bottom).offset(15);
        make.left.equalTo(weakSelf).offset(21);
        make.right.equalTo(weakSelf).offset(-21);
        make.height.offset(47);
    }];
}

@end
