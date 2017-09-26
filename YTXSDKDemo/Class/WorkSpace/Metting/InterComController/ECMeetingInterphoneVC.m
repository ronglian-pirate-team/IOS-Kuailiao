//
//  ECMeetingInterphoneVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/19.
//
//

#import "ECMeetingInterphoneVC.h"
#import "ECMeetingMemberView.h"
#import "ECMeetingUserStatusView.h"

@interface ECMeetingInterphoneVC ()

@property (nonatomic, strong) UIButton *packUpBtn;//收起
@property (nonatomic, strong) UIButton *exitBtn;//解散
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *hostLabel;//会议创建者

@property (nonatomic, strong) NSMutableArray *collectionSource;
@property (nonatomic, strong) NSMutableArray *tableSource;
@property (nonatomic, strong) ECMeetingUserStatusView *tableView;
@property (nonatomic, strong) ECMeetingMemberView *collectionView;

@property (nonatomic, strong) UIButton *speakerBtn;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ECMeetingInterphoneVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    self.navigationController.navigationBarHidden = YES;
    [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:YES];
    [[ECDevice sharedInstance].VoIPManager setMute:NO];
}

#pragma mark - 会议查询成员、成员进入/退出消息通知
- (void)queryMeetingMembers{
    [[ECDevice sharedInstance].meetingManager queryMeetingMembersByMeetingType:ECMeetingType_Interphone andMeetingNumber:self.meetingNum completion:^(ECError *error, NSArray *members) {
        EC_Demo_AppLog(@"error ccode = %ld=== error desc = %@", error.errorCode, error.errorDescription);
        for (ECInterphoneMeetingMember *who in members) {
            if(who.role == 2){
                self.hostLabel.text = [NSLocalizedString(@"对讲发起人：", nil) stringByAppendingString:who.number];
                [self showExit];
            }
            BOOL isHave = NO;
            for (ECInterphoneMeetingMember *m in self.collectionSource) {
                if([m.number isEqualToString:who.number]){
                    isHave = YES;
                    break;
                }
            }
            if(isHave)
                continue;
            [self.collectionSource addObject:who];
        }
        self.collectionView.collectionSource = self.collectionSource;
    }];
}

- (void)onReceiveInterphoneMsg:(NSNotification *)noti{
    ECInterphoneMeetingMsg* receiveMsgInfo = noti.object;
    if (![self.meetingNum isEqualToString:receiveMsgInfo.interphoneId]) {
        return;
    }
    switch (receiveMsgInfo.type) {
        case Interphone_INVITE:
            [ECCommonTool toast:[NSString stringWithFormat:@"%@邀请您加入对讲%@", receiveMsgInfo.fromVoip, receiveMsgInfo.interphoneId]];
            break;
        case Interphone_JOIN:{
            NSMutableArray *tmpArr = [self.collectionSource mutableCopy];
            for (NSString *who in receiveMsgInfo.joinArr) {
                int index = 0;
                for (ECInterphoneMeetingMember *m in tmpArr) {
                    if([m.number isEqualToString:who]){
                        m.isOnline = YES;
                        [self.collectionSource replaceObjectAtIndex:index withObject:m];
                    }
                    index++;
                }
                [self.tableSource addObject:[NSString stringWithFormat:@"%@%@", who, NSLocalizedString(@"进入了会议", nil)]];
            }
            self.tableView.tableSource = self.tableSource;
            self.collectionView.collectionSource = self.collectionSource;
        }
            break;
        case Interphone_EXIT:{
            NSMutableArray *tmpArr = [self.collectionSource mutableCopy];
            for (NSString *who in receiveMsgInfo.exitArr) {
                [self.tableSource addObject:[NSString stringWithFormat:@"%@%@", who, NSLocalizedString(@"退出了会议", nil)]];
                int index = 0;
                for (ECInterphoneMeetingMember *m in tmpArr) {
                    if ([who isEqualToString:m.number] && who == m.number) {
                        m.isOnline = NO;
                        [self.collectionSource replaceObjectAtIndex:index withObject:m];
                        break;
                    }
                    index++;
                }
            }
            self.collectionView.collectionSource = self.collectionSource;
            self.tableView.tableSource = self.tableSource;
        }
            break;
        case Interphone_CONTROLMIC://控麦
            for (ECInterphoneMeetingMember *member in self.collectionSource) {
                if ([receiveMsgInfo.voip isEqualToString:member.number]) {
                    member.isMic = YES;
                    break;
                }
            }
            [self.collectionView reloadData];
            [self.tableSource addObject:[NSString stringWithFormat:@"%@%@", receiveMsgInfo.voip, NSLocalizedString(@"在发言", nil)]];
            self.tableView.tableSource = self.tableSource;
            break;
        case Interphone_RELEASEMIC://放麦
            for (ECInterphoneMeetingMember *member in self.collectionSource) {
                if ([receiveMsgInfo.voip isEqualToString:member.number]) {
                    member.isMic = NO;
                    break;
                }
            }
            [self.collectionView reloadData];
            [self.tableSource addObject:[NSString stringWithFormat:@"%@%@", receiveMsgInfo.voip, NSLocalizedString(@"停止发言", nil)]];
            self.tableView.tableSource = self.tableSource;
            break;
        default:
            break;
    }
}

#pragma mark -
- (void)packupAction{
    [[ECDevice sharedInstance].meetingManager exitMeeting];
    [self clearConfig];
}

- (void)exitAction{
    [[ECDevice sharedInstance].meetingManager exitMeeting];
    [self clearConfig];
}

- (void)clearConfig{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    int index = (int)[[self.navigationController viewControllers] indexOfObject:self];
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-(self.isCreater ? 2 : 1)]animated:YES];
}

- (void)releaseMic:(UIButton *)sender{
    [[ECDevice sharedInstance].meetingManager releaseMicInInterphoneMeeting:self.meetingNum completion:^(ECError *error, NSString *memberVoip) {
        if (error.errorCode == ECErrorType_NoError) {
            [self releaseMic];
        } else {
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"release";
            [ECCommonTool toast:detail];
        }
    }];
}

- (void)controlMic:(UIButton *)sender{
    self.timer.fireDate = [NSDate distantPast];
}

- (void)controlMic{
    [[ECDevice sharedInstance].meetingManager controlMicInInterphoneMeeting:self.meetingNum completion:^(ECError *error, NSString *memberVoip) {
        if (error.errorCode == ECErrorType_NoError) {
            self.timer.fireDate = [NSDate distantFuture];
            for (ECInterphoneMeetingMember *member in self.collectionSource) {
                if ([[ECAppInfo sharedInstanced].persionInfo.userName isEqualToString:member.number]) {
                    member.isMic = YES;
                    break;
                }
            }
            [self.collectionView reloadData];
        } else {
            [self releaseMic];
            NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"control";
            [ECCommonTool toast:detail];
        }
    }];
}

- (void)releaseMic{
    self.timer.fireDate = [NSDate distantFuture];
    for (ECInterphoneMeetingMember *member in self.collectionSource) {
        if ([[ECAppInfo sharedInstanced].persionInfo.userName isEqualToString:member.number]) {
            member.isMic = NO;
            break;
        }
    }
    [self.collectionView reloadData];
}

- (NSTimer *)timer{
    if(!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(controlMic) userInfo:nil repeats:YES];
        _timer.fireDate = [NSDate distantFuture];
    }
    return _timer;
}

#pragma mark - UI创建
- (void)buildUI{
    self.collectionSource = [NSMutableArray array];
    self.tableSource = [NSMutableArray array];
    [self queryMeetingMembers];

    self.view.backgroundColor = EC_Color_Tabbar;
    [self.view addSubview:self.packUpBtn];
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.hostLabel];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.speakerBtn];
    EC_WS(self)
    [self.packUpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(22);
        make.top.equalTo(weakSelf).offset(12);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.top.equalTo(weakSelf.nameLabel.mas_bottom).offset(10);
        make.bottom.equalTo(weakSelf.collectionView.mas_top).offset(-10);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(15);
        make.top.equalTo(weakSelf.packUpBtn.mas_bottom).offset(30);
        make.width.height.offset(66);
    }];
    [self.hostLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.nameLabel.mas_right).offset(10);
        make.top.equalTo(weakSelf.nameLabel.mas_top);
        make.right.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf.nameLabel.mas_bottom);
    }];
    [self.speakerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.collectionView.mas_bottom).offset(80);
        make.centerX.equalTo(weakSelf);
    }];
    UILabel *alertLabel = [[UILabel alloc] init];
    alertLabel.text = NSLocalizedString(@"长按麦克风开始抢麦", nil);
    alertLabel.textColor = EC_Color_Sec_Text;
    alertLabel.font = EC_Font_System(14);
    [alertLabel sizeToFit];
    alertLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:alertLabel];
    CGFloat space = (EC_kScreenW - alertLabel.ec_width)/2;
    [alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset(space);
        make.right.equalTo(weakSelf.view).offset(-space);
        make.top.equalTo(weakSelf.speakerBtn.mas_bottom).offset(15);
        make.bottom.equalTo(weakSelf.view).offset(-15);
    }];
    [super buildUI];
}

- (void)ec_addNotify {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveInterphoneMsg:) name:EC_KNOTIFICATION_ReceiveInterphoneMeetingMsg object:nil];
}

- (void)showExit{
    EC_WS(self)
    [self.view addSubview:self.exitBtn];
    [self.exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(18);
        make.right.equalTo(weakSelf.view).offset(-14);
        make.height.offset(28);
        make.width.offset(100);
    }];
}

- (UIButton *)packUpBtn{
    if(!_packUpBtn){
        _packUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_packUpBtn setImage:EC_Image_Named(@"yuyinliaotianIconSuoxiao") forState:UIControlStateNormal];
        [_packUpBtn addTarget:self action:@selector(packupAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _packUpBtn;
}

- (UIButton *)exitBtn{
    if(!_exitBtn){
        _exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_exitBtn addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
        [_exitBtn setTitle:NSLocalizedString(@"退出", nil) forState:UIControlStateNormal];
        [_exitBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
        _exitBtn.backgroundColor = [UIColor colorWithHex:0xf88dbb];
        _exitBtn.titleLabel.font = EC_Font_SystemBold(16);
        _exitBtn.ec_radius = 14;
    }
    return _exitBtn;
}

- (UILabel *)nameLabel{
    if(!_nameLabel){
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor colorWithHex:0x5981f5];
        _nameLabel.textColor = EC_Color_White;
        _nameLabel.font = EC_Font_System(15);
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.ec_radius = 33;
        NSString *name = [ECAppInfo sharedInstanced].persionInfo.userName;
        if([ECAppInfo sharedInstanced].persionInfo.userName.length > 2)
            name = [[ECAppInfo sharedInstanced].persionInfo.userName substringFromIndex:[ECAppInfo sharedInstanced].persionInfo.userName.length - 2];
        _nameLabel.text = name;
    }
    return _nameLabel;
}

- (UILabel *)hostLabel{
    if(!_hostLabel){
        _hostLabel = [[UILabel alloc] init];
        _hostLabel.textColor = EC_Color_Main_Text;
        _hostLabel.font = EC_Font_System(17);
    }
    return _hostLabel;
}

- (ECMeetingUserStatusView *)tableView{
    if(!_tableView){
        _tableView = [[ECMeetingUserStatusView alloc] init];
    }
    return _tableView;
}

- (ECMeetingMemberView *)collectionView{
    if(!_collectionView){
        _collectionView = [[ECMeetingMemberView alloc] initWithFrame:CGRectMake(0, 290, EC_kScreenW, 90)];
        _collectionView.meetingType = ECMeetingType_Interphone;
    }
    return _collectionView;
}

- (UIButton *)speakerBtn{
    if(!_speakerBtn){
        _speakerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_speakerBtn setImage:EC_Image_Named(@"chatYuyinIconDuijiangNormal") forState:UIControlStateNormal];
        [_speakerBtn addTarget:self action:@selector(releaseMic:) forControlEvents:UIControlEventTouchUpInside];
        [_speakerBtn addTarget:self action:@selector(releaseMic:) forControlEvents:UIControlEventTouchUpOutside];
        [_speakerBtn addTarget:self action:@selector(releaseMic:) forControlEvents:UIControlEventTouchCancel];
        [_speakerBtn addTarget:self action:@selector(controlMic:) forControlEvents:UIControlEventTouchDown];
    }
    return _speakerBtn;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    self.navigationController.navigationBarHidden = NO;
}

@end
