//
//  EdtingLiveChatRoomMember.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/22.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "EdtingLiveChatRoomMember.h"
#import "LiveChatRoomBaseModel.h"
#import "UIImageView+WebCache.h"

#define viewW 280
#define viewH 340

@interface EdtingLiveChatRoomMember ()<UIAlertViewDelegate>
@property (strong, nonatomic) UITextField *nickF;
@property (strong, nonatomic) UILabel *timeL;
@property (strong, nonatomic) UIImageView *iconImgV;
@property (strong, nonatomic) UILabel *accountL;

@property (nonatomic, strong) UIButton *roleBtn;
@property (nonatomic, strong) UIButton *muteBtn;
@property (nonatomic, strong) UIButton *blackBtn;
@property (nonatomic, strong) UIButton *kickBtn;
@property (nonatomic, strong) UIButton *saveBtn;
@end

@implementation EdtingLiveChatRoomMember

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timeL = [[UILabel alloc] init];
        self.timeL.font = [UIFont systemFontOfSize:11.0f];
        [self addSubview:self.timeL];
        
        self.iconImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatui_head_bg"]];
        [self addSubview:self.iconImgV];
        
        self.accountL = [[UILabel alloc] init];
        [self.accountL sizeToFit];
        [self addSubview:self.accountL];
        
        self.nickF = [[UITextField alloc] init];
        self.nickF.placeholder = @"请输入昵称";
        self.nickF.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.nickF];
        
        self.saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.saveBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [self.saveBtn addTarget:self action:@selector(clickedSaveBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.saveBtn];
        
        self.roleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.roleBtn setTitle:@"成员" forState:UIControlStateNormal];
        [self.roleBtn addTarget:self action:@selector(clickedRoleBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.roleBtn];
        
        self.muteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.muteBtn setTitle:@"禁言" forState:UIControlStateNormal];
        [self.muteBtn addTarget:self action:@selector(clickedMuteBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.muteBtn];
        
        self.blackBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.blackBtn setTitle:@"拉黑" forState:UIControlStateNormal];
        [self.blackBtn addTarget:self action:@selector(clickedBlackBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.blackBtn];
        
        self.kickBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.kickBtn setTitle:@"踢出" forState:UIControlStateNormal];
        [self.kickBtn addTarget:self action:@selector(clickedKickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.kickBtn];
    }
    return self;
}

+ (instancetype)loadCustomView {
    
    EdtingLiveChatRoomMember *view = [[EdtingLiveChatRoomMember alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    view.frame = CGRectMake((EC_kScreenW-viewW)/2.0f, (EC_kScreenH-viewH)/2.0f, viewW, viewH);
    view.layer.cornerRadius = 5.0f;
    view.layer.masksToBounds = YES;
    return view;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.member) {
        self.accountL.text = self.member.useId;
        self.timeL.text = [NSString dateTime:self.member.enterTime.longLongValue];
        self.nickF.text = self.member.nickName;
        [self.muteBtn setTitle:(self.member.isMute==YES)?@"取消禁言":@"禁言" forState:UIControlStateNormal];
        [self.blackBtn setTitle:(self.member.isBlack==YES)?@"取消拉黑":@"拉黑" forState:UIControlStateNormal];
        NSInteger row = arc4random() % 8 + 1;
        NSString *imgStr = [NSString stringWithFormat:@"def_usericon%d",(int)row];
        self.iconImgV.image = [UIImage imageNamed:imgStr];
        
        NSString *roleStr = @"";
        switch (self.member.type) {
            case 1:
                roleStr = @"创建者";
                break;
            case 2:
                roleStr = @"管理员";
                break;
            case 3:
                roleStr = @"成员";
                
                break;
                
            default:
                break;
        }
        [self.roleBtn setTitle:roleStr forState:UIControlStateNormal];

        if ([self.member.useId isEqualToString:[ECAppInfo sharedInstanced].userName]) {
            self.muteBtn.hidden = YES;
            self.blackBtn.hidden = YES;
            self.kickBtn.hidden = YES;
        } else {
            self.nickF.enabled = NO;
            if([[ECAppInfo sharedInstanced].userName isEqualToString:[LiveChatRoomBaseModel sharedInstanced].roomInfo.creator]) {
                self.muteBtn.hidden = NO;
                self.blackBtn.hidden = NO;
                self.kickBtn.hidden = NO;
            } else if(self.member.type == LiveChatRoomMemberRole_Member){
                self.muteBtn.hidden = NO;
                self.blackBtn.hidden = NO;
                self.kickBtn.hidden = NO;
            } else {
                self.muteBtn.hidden = YES;
                self.blackBtn.hidden = YES;
                self.kickBtn.hidden = YES;
            }
        }
    }

    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(20.0f);
        make.height.offset(44.0f);
        make.width.offset(60.0f);
        make.left.equalTo(self).offset(20.0f);
    }];
    
    [self.timeL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-10.0f);
        make.top.equalTo(self).offset(10.0f);
        make.height.offset(20.0f);
    }];
    
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self).offset(30.0f);
        make.size.sizeOffset([UIImage imageNamed:@"chatui_head_bg"].size);
    }];
    
    [self.accountL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.iconImgV.mas_bottom).offset(10.0f);
    }];

    [self.nickF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.accountL.mas_bottom).offset(10.0f);
        make.centerX.equalTo(self.mas_centerX);
        make.height.offset(30.0f);
        make.width.offset(120.0f);
    }];
    
    [self.roleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.nickF.mas_bottom).offset(20.0f);
        make.height.offset(44.0f);
        make.width.offset(100.0f);
    }];

    [self.kickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self).offset(-20.0f);
        make.height.offset(44.0f);
        make.width.offset(100.0f);
    }];

    [self.muteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20.0f);
        make.bottom.equalTo(self.kickBtn.mas_top).offset(-20.0f);
        make.height.equalTo(self.kickBtn.mas_height);
        make.width.equalTo(self.kickBtn.mas_width);
    }];

    [self.blackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-20.0f);
        make.bottom.equalTo(self.kickBtn.mas_top).offset(-20.0f);
        make.height.equalTo(self.kickBtn.mas_height);
        make.width.equalTo(self.kickBtn.mas_width);
    }];
}

- (void)clickedMuteBtn:(UIButton *)sender {
    ECForbidLiveChatRoomMemberRequest *request = [[ECForbidLiveChatRoomMemberRequest alloc] init];
    request.roomId = self.member.roomId;
    request.userId = self.member.useId;
    request.isMute = [sender.titleLabel.text isEqualToString:@"禁言"];
    
    [[ECDevice sharedInstance].liveChatRoomManager forbidLiveChatRoomMember:request completion:^(ECError *error, ECLiveChatRoomMember *member) {
        if (error.errorCode == ECErrorType_NoError) {
            [sender setTitle:member.isMute==YES?@"取消禁言":@"禁言" forState:UIControlStateNormal];
        } else {
            [ECCommonTool toast:[NSString stringWithFormat:@"%ld",(long)error.errorCode]];
        }
    }];
}

- (void)clickedBlackBtn:(UIButton *)sender {
    ECDefriendLiveChatRoomMemberRequest *request = [[ECDefriendLiveChatRoomMemberRequest alloc] init];
    request.roomId = self.member.roomId;
    request.userId = self.member.useId;
    request.isBlack = [sender.titleLabel.text isEqualToString:@"拉黑"];
    
    [[ECDevice sharedInstance].liveChatRoomManager dfriendLiveChatRoomMember:request completion:^(ECError *error, ECLiveChatRoomMember *member) {
        if (error.errorCode == ECErrorType_NoError) {
            [sender setTitle:member.isBlack==YES?@"取消拉黑":@"拉黑" forState:UIControlStateNormal];
            if (request.isBlack) {
                [[NSNotificationCenter defaultCenter] postNotificationName:EC_KECNOTIFICATION_LIVECHATROOM_BLACKMEMBER object:member.useId];
            }
        } else {
            [ECCommonTool toast:[NSString stringWithFormat:@"%ld",(long)error.errorCode]];
        }
    }];
}

- (void)clickedRoleBtn:(UIButton *)sender {
    
    if ([sender.titleLabel.text isEqualToString:@"创建者"])
        return;
    
    ECModifyLiveChatRoomMemberRoleRequest *request = [[ECModifyLiveChatRoomMemberRoleRequest alloc] init];
    request.roomId = self.member.roomId;
    request.userId = self.member.useId;

    request.type = [sender.titleLabel.text isEqualToString:@"成员"]==YES?2:3;
    [[ECDevice sharedInstance].liveChatRoomManager modifyLiveChatRoomMemberRole:request completion:^(ECError *error, ECLiveChatRoomMember *member) {
        if (error.errorCode == ECErrorType_NoError) {
            [sender setTitle:member.type==2?@"管理员":@"成员" forState:UIControlStateNormal];
            [LiveChatRoomBaseModel sharedInstanced].type = request.type;
        } else {
            [ECCommonTool toast:[NSString stringWithFormat:@"%ld",(long)error.errorCode]];
        }
    }];
}

- (void)clickedKickBtn:(UIButton *)sender {
    
    ECKickLiveChatRoomMemberRequest *request = [[ECKickLiveChatRoomMemberRequest alloc] init];
    request.roomId = self.member.roomId;
    request.userId = self.member.useId;
    
    [[ECDevice sharedInstance].liveChatRoomManager kickLiveChatRoomMember:request completion:^(ECError *error, NSString *userId) {
        
        if (error.errorCode == ECErrorType_NoError) {
            _kickBtn.enabled = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_KECNOTIFICATION_LIVECHATROOM_KICKMEMBER object:userId];
        } else {
            [ECCommonTool toast:[NSString stringWithFormat:@"%ld",(long)error.errorCode]];
        }
    }];
}

- (void)clickedSaveBtn:(UIButton *)sender {
    
    if (_nickF.text.length==0 || [_nickF.text isEqualToString:self.member.nickName]) {
        [self removeFromSuperview];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"昵称已修改,是否保存更改的信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
    }
}

+ (instancetype)animation:(UIView *)supView {
    
    for (UIView *view in supView.subviews) {
        if ([view isKindOfClass:[EdtingLiveChatRoomMember class]]) {
            [view removeFromSuperview];
        }
    }
    
    EdtingLiveChatRoomMember *memberView = [EdtingLiveChatRoomMember loadCustomView];
    [supView addSubview:memberView];

    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"position"];
    ani.fromValue = [NSValue valueWithCGRect:CGRectMake(EC_kScreenW/2.0f, EC_kScreenH,viewW , viewH)];
    ani.toValue = [NSValue valueWithCGPoint:supView.center];
    ani.duration = 0.25f;
    [memberView.layer addAnimation:ani forKey:@"positionToCenter"];
    return memberView;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex != buttonIndex) {
        NSString *nickN = [_nickF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        ECModifyLiveChatRoomMemberInfoRequest *request = [[ECModifyLiveChatRoomMemberInfoRequest alloc] init];
        request.roomId = self.member.roomId;
        request.nickName = nickN;
        request.infoExt = @"{\n  \"livechatroom_pimg\" : \"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1495789173924&di=4ba75c037c4c4766a08a74937ce7d6f4&imgtype=0&src=http%3A%2F%2Fscimg.jb51.net%2Ftouxiang%2F201705%2F2017050421474180.jpg\"\n}";
        
        [[ECDevice sharedInstance].liveChatRoomManager modifyLiveChatRoomSelfInfo:request completion:^(ECError *error, ECLiveChatRoomMember *member) {
            if (error.errorCode == ECErrorType_NoError) {
                [ECCommonTool toast:@"保存成功"];
                self.member = member;
                [LiveChatRoomBaseModel sharedInstanced].nickName = member.nickName;
                [self removeFromSuperview];
            } else {
                [ECCommonTool toast:@"保存失败"];
            }
        }];
    } else {
        [self removeFromSuperview];
    }
}
@end
