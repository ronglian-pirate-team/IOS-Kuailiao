//
//  ECGroupNoticeCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/9/16.
//
//

#import "ECGroupNoticeCell.h"

@interface ECGroupNoticeCell()

@property (nonatomic, strong) UIImageView *headImage;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIButton *agreeBtn;
@property (nonatomic, strong) UIButton *refuseBtn;
@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation ECGroupNoticeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.separatorInset = UIEdgeInsetsMake(0, 64, 0, 0);
        [self buildUI];
    }
    return self;
}

- (void)agreeAction{
    if(self.groupNoticeMessage.messageType == ECGroupMessageType_Invite){
        EC_ShowHUD_OnView(@"", [AppDelegate sharedInstanced].currentVC.view);
        [[ECDevice sharedInstance].messageManager ackInviteJoinGroupRequest:self.groupNoticeMessage.groupId invitor:((ECInviterMsg *)self.groupNoticeMessage).admin ackType:EAckType_Agree completion:^(ECError *error, NSString *gorupId) {
            EC_HideHUD_OnView([AppDelegate sharedInstanced].currentVC.view)
            if(error.errorCode == ECErrorType_NoError){
                [(ECInviterMsg *)self.groupNoticeMessage setConfirm:2];
                [self setConfirm:2];
                [[ECDBManager sharedInstanced].groupNoticeMgr updateGroupNoticeMessage:self.groupNoticeMessage.groupId withMember:((ECInviterMsg *)self.groupNoticeMessage).admin confirm:2];
            }else if(error.errorCode == 590010){//群组不存在
                [ECCommonTool toast:@"群组不存在"];
                _agreeBtn.hidden = YES;
                [[ECDBManager sharedInstanced].groupNoticeMgr deleteGroupNoticeMessage:self.groupNoticeMessage.groupId withMember:((ECInviterMsg *)self.groupNoticeMessage).admin];
            }else if (error.errorCode == ECErrorType_Have_Joined){
                [(ECInviterMsg *)self.groupNoticeMessage setConfirm:2];
                [self setConfirm:2];
                [[ECDBManager sharedInstanced].groupNoticeMgr updateGroupNoticeMessage:self.groupNoticeMessage.groupId withMember:((ECInviterMsg *)self.groupNoticeMessage).admin confirm:2];
            }else{
                [ECCommonTool toast:[NSString stringWithFormat:@"error code = %ld, error desc = %@", error.errorCode, error.errorDescription]];
            }
        }];
    } else if(self.groupNoticeMessage.messageType == ECGroupMessageType_Propose){
        EC_ShowHUD_OnView(@"", [AppDelegate sharedInstanced].currentVC.view);
        [[ECDevice sharedInstance].messageManager ackJoinGroupRequest:self.groupNoticeMessage.groupId member:((ECProposerMsg *)self.groupNoticeMessage).proposer ackType:EAckType_Agree completion:^(ECError *error, NSString *gorupId, NSString *memberId) {
            EC_HideHUD_OnView([AppDelegate sharedInstanced].currentVC.view)
            if(error.errorCode == ECErrorType_NoError){
                [(ECProposerMsg *)self.groupNoticeMessage setConfirm:2];
                [[ECDBManager sharedInstanced].groupNoticeMgr updateGroupNoticeMessage:self.groupNoticeMessage.groupId withMember:((ECProposerMsg *)self.groupNoticeMessage).proposer confirm:2];
                [self setConfirm:2];
            }
        }];
    }
}

- (void)refuresAction{
    if(self.groupNoticeMessage.messageType == ECGroupMessageType_Invite){
        EC_ShowHUD_OnView(@"", [AppDelegate sharedInstanced].currentVC.view);
        [[ECDevice sharedInstance].messageManager ackInviteJoinGroupRequest:self.groupNoticeMessage.groupId invitor:((ECInviterMsg *)self.groupNoticeMessage).admin ackType:EAckType_Reject completion:^(ECError *error, NSString *gorupId) {
            EC_HideHUD_OnView([AppDelegate sharedInstanced].currentVC.view)
            if(error.errorCode == ECErrorType_NoError){
                [(ECInviterMsg *)self.groupNoticeMessage setConfirm:3];
                [self setConfirm:3];
                [[ECDBManager sharedInstanced].groupNoticeMgr updateGroupNoticeMessage:self.groupNoticeMessage.groupId withMember:((ECInviterMsg *)self.groupNoticeMessage).admin confirm:3];
            }else if(error.errorCode == 590010){//群组不存在
                [ECCommonTool toast:@"群组不存在"];
                _agreeBtn.hidden = YES;
                [[ECDBManager sharedInstanced].groupNoticeMgr deleteGroupNoticeMessage:self.groupNoticeMessage.groupId withMember:((ECInviterMsg *)self.groupNoticeMessage).admin];
            }else if (error.errorCode == ECErrorType_Have_Joined){
                [(ECInviterMsg *)self.groupNoticeMessage setConfirm:2];
                [self setConfirm:2];
                [[ECDBManager sharedInstanced].groupNoticeMgr updateGroupNoticeMessage:self.groupNoticeMessage.groupId withMember:((ECInviterMsg *)self.groupNoticeMessage).admin confirm:2];
            }else{
                [ECCommonTool toast:[NSString stringWithFormat:@"error code = %ld, error desc = %@", error.errorCode, error.errorDescription]];
            }
        }];
    }else if(self.groupNoticeMessage.messageType == ECGroupMessageType_Propose){
        EC_ShowHUD_OnView(@"", [AppDelegate sharedInstanced].currentVC.view);
        [[ECDevice sharedInstance].messageManager ackJoinGroupRequest:self.groupNoticeMessage.groupId member:((ECProposerMsg *)self.groupNoticeMessage).proposer ackType:EAckType_Reject completion:^(ECError *error, NSString *gorupId, NSString *memberId) {
            EC_HideHUD_OnView([AppDelegate sharedInstanced].currentVC.view)
            if(error.errorCode == ECErrorType_NoError){
                [(ECProposerMsg *)self.groupNoticeMessage setConfirm:3];
                [[ECDBManager sharedInstanced].groupNoticeMgr updateGroupNoticeMessage:self.groupNoticeMessage.groupId withMember:((ECProposerMsg *)self.groupNoticeMessage).proposer confirm:3];
                [self setConfirm:3];
            }
        }];
    }
}

- (void)setGroupNoticeMessage:(ECGroupNoticeMessage *)groupNoticeMessage{
    _groupNoticeMessage = groupNoticeMessage;
    if(groupNoticeMessage.messageType == ECGroupMessageType_Invite){//邀请加入
        self.imageView.image = EC_Image_Named(@"addressbookIconQunzu");
        ECInviterMsg *msg = (ECInviterMsg *)groupNoticeMessage;
        [self setConfirm:msg.confirm];
        self.infoLabel.text = [ECSession noticeConvertToSession:msg].text;
    }else if (groupNoticeMessage.messageType == ECGroupMessageType_Propose){//申请加入
        self.imageView.image = EC_Image_Named(@"addressbookIconQunzu");
        ECProposerMsg *msg = (ECProposerMsg *)groupNoticeMessage;
        self.infoLabel.text = [ECSession noticeConvertToSession:msg].text;
    }
}

- (void)setConfirm:(NSInteger)confirm{
    if(confirm == 2){
        self.agreeBtn.hidden = YES;
        self.refuseBtn.hidden = YES;
        self.statusLabel.hidden = NO;
        self.statusLabel.text = @"已同意";
    }else if(confirm == 3){
        self.agreeBtn.hidden = YES;
        self.refuseBtn.hidden = YES;
        self.statusLabel.hidden = NO;
        self.statusLabel.text = @"已拒绝";
    }else if(confirm == 0){
        self.agreeBtn.hidden = YES;
        self.refuseBtn.hidden = YES;
        self.statusLabel.hidden = NO;
    } else {
        self.agreeBtn.hidden = NO;
        self.refuseBtn.hidden = NO;
        self.statusLabel.hidden = YES;
    }
}

#pragma mark - UI 创建
- (void)buildUI{
    [self.contentView addSubview:self.headImage];
    [self.contentView addSubview:self.infoLabel];
    [self.contentView addSubview:self.agreeBtn];
    [self.contentView addSubview:self.refuseBtn];
    [self.contentView addSubview:self.statusLabel];
    EC_WS(self)
    [self.headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(12);
        make.centerY.equalTo(weakSelf);
    }];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(64);
        make.top.equalTo(weakSelf).offset(5);
        make.bottom.equalTo(weakSelf).offset(-5);
        make.right.equalTo(weakSelf).offset(-70);
    }];
    NSArray *arr = @[self.agreeBtn, self.refuseBtn];
    [arr mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:12 leadSpacing:5 tailSpacing:5];
    [arr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf).offset(-12);
        make.height.offset(25);
        make.width.offset(53);
    }];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf).offset(-12);
        make.height.offset(25);
        make.width.offset(53);
        make.centerY.equalTo(weakSelf);
    }];
}

- (UIImageView *)headImage {
    if(!_headImage){
        _headImage = [[UIImageView alloc] init];
    }
    return _headImage;
}

- (UILabel *)infoLabel {
    if(!_infoLabel){
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = EC_Font_System(16);
        _infoLabel.textColor = EC_Color_Main_Text;
        _infoLabel.numberOfLines = 0;
    }
    return _infoLabel;
}

- (UIButton *)agreeBtn {
    if(!_agreeBtn){
        _agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _agreeBtn.backgroundColor = [UIColor colorWithHex:0x38adff];
        [_agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
        [_agreeBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
        _agreeBtn.titleLabel.font = EC_Font_System(14);
        [_agreeBtn addTarget:self action:@selector(agreeAction) forControlEvents:UIControlEventTouchUpInside];
        _agreeBtn.ec_radius = 4.0;
    }
    return _agreeBtn;
}

- (UIButton *)refuseBtn {
    if(!_refuseBtn){
        _refuseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _refuseBtn.backgroundColor = EC_Color_lightGray;
        [_refuseBtn setTitle:@"拒绝" forState:UIControlStateNormal];
        [_refuseBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
        _refuseBtn.titleLabel.font = EC_Font_System(14);
        [_refuseBtn addTarget:self action:@selector(refuresAction) forControlEvents:UIControlEventTouchUpInside];
        _refuseBtn.ec_radius = 4.0;
    }
    return _refuseBtn;
}

- (UILabel *)statusLabel {
    if(!_statusLabel){
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = EC_Font_System(14);
        _statusLabel.textColor = EC_Color_Sec_Text;
        _statusLabel.numberOfLines = 0;
    }
    return _statusLabel;
}

@end
