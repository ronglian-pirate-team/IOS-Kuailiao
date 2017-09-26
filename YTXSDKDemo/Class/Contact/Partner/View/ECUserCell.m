//
//  ECUserCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/26.
//
//

#import "ECUserCell.h"
#import "ECFriendManager.h"

@interface ECUserCell()

@end

@implementation ECUserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self buildUI];
    }
    return self;
}

- (void)operationAction{
    switch (self.contactType) {
        case ECUserOperationType_None:
            break;
        case ECUserOperationType_Add:{
            [[ECFriendManager sharedInstanced] addFriendWithAccount:self.addressBook.phone];
        }
            break;
        case ECUserOperationType_Request:{
            [[ECFriendManager sharedInstanced] agreeFrendAddRequest:self.addRequestUser.friendUseracc completion:^(NSString *errCode, id responseObject) {
                if(errCode.integerValue == 0 || errCode.integerValue == 112195) {
                    [[ECDBManager sharedInstanced].addRequestMgr updateRequestStatus:@"1" onRequest:self.addRequestUser.friendUseracc];
                    [self.agreeBtn setTitle:NSLocalizedString(@"已同意", nil) forState:UIControlStateNormal];
                    self.agreeBtn.backgroundColor = EC_Color_Clear;
                    self.agreeBtn.enabled = NO;
                    [self.agreeBtn setTitleColor:EC_Color_Sec_Text forState:UIControlStateNormal];
                }
            }];
        }
            break;
        case ECUserOperationType_Forbid:{
            [[ECDevice sharedInstance].messageManager forbidMemberSpeakStatus:self.groupId member:self.member.memberId speakStatus:ECSpeakStatus_Allow completion:^(ECError *error, NSString *groupId, NSString *memberId) {
                if(error.errorCode == ECErrorType_NoError){
                    EC_Demo_AppLog(@"解除禁言成功");
                    [[ECDBManager sharedInstanced].groupMemberMgr updateGroupMember:memberId speakerStatus:ECSpeakStatus_Allow inGroup:groupId];
                    if(self.completionOperation){
                        self.completionOperation(self);
                    }
                }else{
                    [ECCommonTool toast:error.errorDescription];
                }
            }];
        }
            break;
        case ECUserOperationType_Delete:
            if(self.completionOperation){
                self.completionOperation(self);
            }            
            break;
        case ECUserOperationType_GroupNotice:{
            if(self.groupNoticeMessage.messageType == ECGroupMessageType_Invite){
                EC_ShowHUD_OnView(@"", [AppDelegate sharedInstanced].currentVC.view);
                EC_Demo_AppLog(@"group id = %@", self.groupNoticeMessage.groupId);
                [[ECDevice sharedInstance].messageManager ackInviteJoinGroupRequest:self.groupNoticeMessage.groupId invitor:((ECInviterMsg *)self.groupNoticeMessage).admin ackType:EAckType_Agree completion:^(ECError *error, NSString *gorupId) {
                    EC_HideHUD_OnView([AppDelegate sharedInstanced].currentVC.view)
                    EC_Demo_AppLog(@"%ld === %@", error.errorCode, error.errorDescription);
                    if(error.errorCode == ECErrorType_NoError){
                        [_agreeBtn setTitle:NSLocalizedString(@"已同意", nil) forState:UIControlStateNormal];
                        self.agreeBtn.backgroundColor = EC_Color_Clear;
                        self.agreeBtn.enabled = NO;
                        [self.agreeBtn setTitleColor:EC_Color_Sec_Text forState:UIControlStateNormal];
                        [[ECDBManager sharedInstanced].groupNoticeMgr updateGroupNoticeMessage:self.groupNoticeMessage.groupId withMember:((ECInviterMsg *)self.groupNoticeMessage).admin confirm:2];
                    }else if(error.errorCode == 590010){//群组不存在
                        [ECCommonTool toast:@"群组不存在"];
                        _agreeBtn.hidden = YES;
                        [[ECDBManager sharedInstanced].groupNoticeMgr deleteGroupNoticeMessage:self.groupNoticeMessage.groupId withMember:((ECInviterMsg *)self.groupNoticeMessage).admin];
                    }else if (error.errorCode == ECErrorType_Have_Joined){
                        [_agreeBtn setTitle:NSLocalizedString(@"已同意", nil) forState:UIControlStateNormal];
                        self.agreeBtn.backgroundColor = EC_Color_Clear;
                        self.agreeBtn.enabled = NO;
                        [self.agreeBtn setTitleColor:EC_Color_Sec_Text forState:UIControlStateNormal];
                        [[ECDBManager sharedInstanced].groupNoticeMgr updateGroupNoticeMessage:self.groupNoticeMessage.groupId withMember:((ECInviterMsg *)self.groupNoticeMessage).admin confirm:2];
                    }else{
                        [ECCommonTool toast:[NSString stringWithFormat:@"error code = %ld, error desc = %@", error.errorCode, error.errorDescription]];
                    }
                }];
            }else if(self.groupNoticeMessage.messageType == ECGroupMessageType_Propose){
                EC_ShowHUD_OnView(@"", [AppDelegate sharedInstanced].currentVC.view);
                [[ECDevice sharedInstance].messageManager ackJoinGroupRequest:self.groupNoticeMessage.groupId member:((ECProposerMsg *)self.groupNoticeMessage).proposer ackType:EAckType_Agree completion:^(ECError *error, NSString *gorupId, NSString *memberId) {
                    EC_HideHUD_OnView([AppDelegate sharedInstanced].currentVC.view)
                    if(error.errorCode == ECErrorType_NoError){
                        [[ECDBManager sharedInstanced].groupNoticeMgr updateGroupNoticeMessage:self.groupNoticeMessage.groupId withMember:((ECProposerMsg *)self.groupNoticeMessage).proposer confirm:2];
                        [_agreeBtn setTitle:NSLocalizedString(@"已同意", nil) forState:UIControlStateNormal];
                        self.agreeBtn.backgroundColor = EC_Color_Clear;
                        self.agreeBtn.enabled = NO;
                        [self.agreeBtn setTitleColor:EC_Color_Sec_Text forState:UIControlStateNormal];
                    }
                }];
            }
        }
            break;
        case ECUserOperationType_FriendNotice: {
            if (self.friendNoticeMessage.type == ECFriendNoticeMsg_Type_AddFriend) {
                [[ECFriendManager sharedInstanced] agreeFrendAddRequest:[NSString stringWithFormat:@"%@#%@",ECSDK_Key,self.friendNoticeMessage.sender] completion:^(NSString *errCode, id responseObject) {
                    if(errCode.integerValue == 0 || errCode.integerValue == 112195){
                        [[ECDBManager sharedInstanced].addRequestMgr updateRequestStatus:@"1" onRequest:self.friendNoticeMessage.friendAccount];
                        self.friendNoticeMessage.friendState = 2;
                        [[ECDBManager sharedInstanced].friendNoticeMgr updateFriendNoticeMsg:self.friendNoticeMessage];
                        [self.agreeBtn setTitle:NSLocalizedString(@"已同意", nil) forState:UIControlStateNormal];
                        self.agreeBtn.backgroundColor = EC_Color_Clear;
                        self.agreeBtn.enabled = NO;
                        [self.agreeBtn setTitleColor:EC_Color_Sec_Text forState:UIControlStateNormal];
                    }
                }];
            }
        }
            break;
        default:
            break;
    }
}

- (void)setAddressBook:(ECAddressBook *)addressBook{
    _addressBook = addressBook;
    self.contactType = ECUserOperationType_Add;
//    self.imageView.image = EC_Image_Named(@"messageIconHeader");
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:addressBook.avatar] placeholderImage:EC_Image_Named(@"messageIconHeader")];
    self.textLabel.text = addressBook.name;
    self.detailTextLabel.text = addressBook.phone;
    if(addressBook.isAdded){
        [self.agreeBtn setTitle:NSLocalizedString(@"已添加", nil) forState:UIControlStateNormal];
        self.agreeBtn.backgroundColor = EC_Color_Clear;
        self.agreeBtn.enabled = NO;
        [self.agreeBtn setTitleColor:EC_Color_Sec_Text forState:UIControlStateNormal];
    }else{
        [_agreeBtn setTitle:NSLocalizedString(@"添加", nil) forState:UIControlStateNormal];
        self.agreeBtn.backgroundColor = [UIColor colorWithHex:0x38adff];
        self.agreeBtn.enabled = YES;
        [self.agreeBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
    }
}

- (void)setAddRequestUser:(ECAddRequestUser *)addRequestUser{
    _addRequestUser = addRequestUser;
    self.contactType = ECUserOperationType_Request;
    self.imageView.image = EC_Image_Named(@"messageIconHeader");
    if(![addRequestUser.friendUseracc hasPrefix:ECSDK_Key]){
        self.textLabel.text = addRequestUser.friendUseracc;
    }else if([addRequestUser.friendUseracc hasPrefix:ECSDK_Key]){
        self.textLabel.text = [addRequestUser.friendUseracc substringFromIndex:ECSDK_Key.length + 1];
    }
    if(addRequestUser.isInvited.integerValue == 0 && addRequestUser.dealState.integerValue == 0){
        [_agreeBtn setTitle:NSLocalizedString(@"待确认", nil) forState:UIControlStateNormal];
        self.agreeBtn.backgroundColor = EC_Color_Clear;
        self.agreeBtn.enabled = NO;
        [self.agreeBtn setTitleColor:EC_Color_Sec_Text forState:UIControlStateNormal];
    }else if(addRequestUser.isInvited.integerValue == 1 && addRequestUser.dealState.integerValue == 1){
        [_agreeBtn setTitle:NSLocalizedString(@"已同意", nil) forState:UIControlStateNormal];
        self.agreeBtn.backgroundColor = EC_Color_Clear;
        self.agreeBtn.enabled = NO;
        [self.agreeBtn setTitleColor:EC_Color_Sec_Text forState:UIControlStateNormal];
    } else if(addRequestUser.dealState.integerValue == 0){
        [_agreeBtn setTitle:NSLocalizedString(@"同意", nil) forState:UIControlStateNormal];
        self.agreeBtn.backgroundColor = [UIColor colorWithHex:0x38adff];
        [self.agreeBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
    }else if(addRequestUser.dealState.integerValue == 1){
        [_agreeBtn setTitle:NSLocalizedString(@"已同意", nil) forState:UIControlStateNormal];
        self.agreeBtn.backgroundColor = EC_Color_Clear;
        self.agreeBtn.enabled = NO;
        [self.agreeBtn setTitleColor:EC_Color_Sec_Text forState:UIControlStateNormal];
    }
    self.detailTextLabel.text = addRequestUser.message;
}

- (void)setMember:(ECGroupMember *)member{
    _member = member;
    self.textLabel.text = member.display ? member.display : member.memberId;
    self.imageView.image = [UIImage ec_circleImageWithColor:EC_Color_App_Main withSize:CGSizeMake(60, 60) withName:self.textLabel.text];
    self.detailTextLabel.text = member.memberId;
}

- (void)setVoiceMeetingMember:(ECMultiVoiceMeetingMember *)voiceMeetingMember{
    _voiceMeetingMember = voiceMeetingMember;
    self.imageView.image = EC_Image_Named(@"messageIconWork");
    if([voiceMeetingMember isKindOfClass:[ECMultiVideoMeetingMember class]]){
        self.textLabel.text = ((ECMultiVideoMeetingMember *)voiceMeetingMember).voipAccount.account;
        self.detailTextLabel.text = ((ECMultiVideoMeetingMember *)voiceMeetingMember).voipAccount.account;
    }else{
        self.textLabel.text = voiceMeetingMember.account.account;
        self.detailTextLabel.text = voiceMeetingMember.account.account;
    }
}

- (void)setFriendInfo:(ECFriend *)friendInfo{
    _friendInfo = friendInfo;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:friendInfo.avatar] placeholderImage:EC_Image_Named(@"messageIconHeader")];
    self.textLabel.text = friendInfo.nickName;
    self.detailTextLabel.text = friendInfo.useracc;
    self.textLabel.font = EC_Font_System(15);
}

- (void)setGroupNoticeMessage:(ECGroupNoticeMessage *)groupNoticeMessage{
    _groupNoticeMessage = groupNoticeMessage;
    self.contactType = ECUserOperationType_GroupNotice;
    if(groupNoticeMessage.messageType == ECGroupMessageType_Invite){//邀请加入
        self.imageView.image = EC_Image_Named(@"addressbookIconQunzu");
        ECInviterMsg *msg = (ECInviterMsg *)groupNoticeMessage;
        NSString *display = @"";
        if(msg.nickName && msg.nickName != nil && msg.nickName.length > 0)
            display = msg.nickName;
        else
            display = msg.admin;
        self.textLabel.text = display;
        self.detailTextLabel.text = ((ECInviterMsg *)groupNoticeMessage).declared;
        if(msg.confirm == 2){
            [_agreeBtn setTitle:NSLocalizedString(@"已同意", nil) forState:UIControlStateNormal];
            self.agreeBtn.backgroundColor = EC_Color_Clear;
            self.agreeBtn.enabled = NO;
            [self.agreeBtn setTitleColor:EC_Color_Sec_Text forState:UIControlStateNormal];
        }else{
            [_agreeBtn setTitle:NSLocalizedString(@"同意", nil) forState:UIControlStateNormal];
            self.agreeBtn.backgroundColor = [UIColor colorWithHex:0x38adff];
            [self.agreeBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
        }
    }else if (groupNoticeMessage.messageType == ECGroupMessageType_Propose){//申请加入
        self.imageView.image = EC_Image_Named(@"addressbookIconQunzu");
        ECProposerMsg *msg = (ECProposerMsg *)groupNoticeMessage;
        NSString *display = @"";
        if(msg.nickName && msg.nickName != nil && msg.nickName.length > 0)
            display = msg.nickName;
        else
            display = msg.proposer;
        self.textLabel.text = display;
        self.detailTextLabel.text = ((ECProposerMsg *)groupNoticeMessage).declared;
        if(msg.confirm == 2){
            [_agreeBtn setTitle:NSLocalizedString(@"已同意", nil) forState:UIControlStateNormal];
            self.agreeBtn.backgroundColor = EC_Color_Clear;
            self.agreeBtn.enabled = NO;
            [self.agreeBtn setTitleColor:EC_Color_Sec_Text forState:UIControlStateNormal];
        }else{
            [_agreeBtn setTitle:NSLocalizedString(@"同意", nil) forState:UIControlStateNormal];
            self.agreeBtn.backgroundColor = [UIColor colorWithHex:0x38adff];
            [self.agreeBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
        }
    }
}

- (void)setFriendNoticeMessage:(ECFriendNoticeMsg *)friendNoticeMessage {
    _friendNoticeMessage = friendNoticeMessage;
    self.contactType = ECUserOperationType_FriendNotice;
    [[SDImageCache sharedImageCache] removeImageForKey:friendNoticeMessage.avatarUrl fromDisk:NO withCompletion:nil];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:friendNoticeMessage.avatarUrl] placeholderImage:EC_Image_Named(@"messageIconHeader") completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
    }];
    if (friendNoticeMessage.type == ECFriendNoticeMsg_Type_AddFriend) {
        self.textLabel.text = friendNoticeMessage.nickName;
        self.detailTextLabel.text = friendNoticeMessage.noticeMsg;
        if(friendNoticeMessage.friendState == 2){
            [_agreeBtn setTitle:NSLocalizedString(@"已同意", nil) forState:UIControlStateNormal];
            self.agreeBtn.backgroundColor = EC_Color_Clear;
            self.agreeBtn.enabled = NO;
            [self.agreeBtn setTitleColor:EC_Color_Sec_Text forState:UIControlStateNormal];
        } else if(friendNoticeMessage.friendState == 1) {
            [_agreeBtn setTitle:NSLocalizedString(@"同意", nil) forState:UIControlStateNormal];
            self.agreeBtn.backgroundColor = [UIColor colorWithHex:0x38adff];
            [self.agreeBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
        }
    }
}

- (void)setContactType:(ECUserOperationType)contactType{
    _contactType = contactType;
    switch (contactType) {
        case ECUserOperationType_None:
        case ECUserOperationType_AdminSet:
            _agreeBtn.hidden = YES;
            break;
        case ECUserOperationType_Add:
            [_agreeBtn setTitle:NSLocalizedString(@"添加", nil) forState:UIControlStateNormal];
            self.agreeBtn.backgroundColor = [UIColor colorWithHex:0x38adff];
            [self.agreeBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
            break;
        case ECUserOperationType_FriendNotice:
        case ECUserOperationType_Request:
            [_agreeBtn setTitle:NSLocalizedString(@"同意", nil) forState:UIControlStateNormal];
            self.agreeBtn.backgroundColor = [UIColor colorWithHex:0x38adff];
            [self.agreeBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
            break;
        case  ECUserOperationType_Forbid:
            self.agreeBtn.backgroundColor = [UIColor colorWithHex:0xf8f8f8];
            [self.agreeBtn setTitle:NSLocalizedString(@"解禁", nil) forState:UIControlStateNormal];
            [self.agreeBtn setTitleColor:EC_Color_Main_Text forState:UIControlStateNormal];
            break;
        case ECUserOperationType_Delete:
            self.agreeBtn.backgroundColor = [UIColor colorWithHex:0xf88dbb];
            [self.agreeBtn setTitle:NSLocalizedString(@"移除", nil) forState:UIControlStateNormal];
            [self.agreeBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

#pragma mark - UI创建
- (void)buildUI{
    self.textLabel.font = EC_Font_System(16);
    self.detailTextLabel.font = EC_Font_System(14);
    self.textLabel.textColor = EC_Color_Main_Text;
    self.detailTextLabel.textColor = EC_Color_Sec_Text;
    UIButton *agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    agreeBtn.backgroundColor = [UIColor colorWithHex:0x38adff];
    [agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
    [agreeBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
    agreeBtn.titleLabel.font = EC_Font_System(14);
    [agreeBtn addTarget:self action:@selector(operationAction) forControlEvents:UIControlEventTouchUpInside];
    agreeBtn.ec_radius = 4.0;
    [self.contentView addSubview:agreeBtn];
    self.agreeBtn = agreeBtn;
    EC_WS(self);
    [agreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.contentView).offset(-12);
        make.bottom.equalTo(weakSelf.contentView).offset(-22);
        make.height.offset(25);
        make.width.offset(53);
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 20;
    self.imageView.frame = CGRectMake(12, 7, 40, 40);
    self.imageView.center = CGPointMake(self.imageView.center.x, self.contentView.center.y);
    self.textLabel.ec_x = 64;
    self.detailTextLabel.ec_x = self.textLabel.ec_x;
    self.separatorInset = UIEdgeInsetsMake(0, 64, 0, 0);
}

@end
