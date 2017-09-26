//
//  ECMeetingVoiceVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/17.
//
//

#import "ECMeetingVoiceVC.h"
#import "ECCallOperationView.h"
#import "ECVoiceMeetingMemberCell.h"
#import "ECMeetingInviteVC.h"
#import "ECMeetingMemberView.h"
#import "ECMeetingUserStatusView.h"
#import "ECCallSettingView.h"
#import "ECCallOpenView.h"

#define EC_Scale_Size 80

@interface ECMeetingVoiceVC ()<CAAnimationDelegate>

@property (nonatomic, strong) UIButton *packUpBtn;//收起
@property (nonatomic, strong) UIButton *dismissBtn;//解散
@property (nonatomic, strong) UILabel *nameLabel;//当前操作者名字
@property (nonatomic, strong) UILabel *hostLabel;//会议创建者
@property (nonatomic, strong) UILabel *meetingNameLabel;//会议名称

@property (nonatomic, strong) ECMeetingMemberView *collectionView;//会议成员展示
@property (nonatomic, strong) ECMeetingUserStatusView *tableView;//会议成员加入/退出消息展示

@property (nonatomic, strong) NSMutableArray *tableSource;//会议成员加入/退出消息
@property (nonatomic, strong) NSMutableArray *collectionSource;//会议成员

@property (nonatomic, strong) UILabel *alertLabel;
@property (nonatomic, strong) UILabel *timeLabel;//会议时间显示

@property (nonatomic, strong) NSTimer *timer;//开始会议定时器
@property (nonatomic, assign) NSInteger second;//会议时间

@property (nonatomic, assign) BOOL isCreater;//是否是会议创建者

@property (nonatomic, strong) ECCallOpenView *openView;
@property (strong, nonatomic) CAShapeLayer *shapeLayer;

@end

@implementation ECMeetingVoiceVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableSource = [NSMutableArray array];
    self.collectionSource = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveChatroomMsg:) name:EC_KNOTIFICATION_ReceiveMultiVoiceMeetingMsg object:nil];
    [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:YES];
    [[ECDevice sharedInstance].VoIPManager setMute:NO];
    if(self.meetingParams){
        [self createMeetingRoom];
    }else if(self.meetingRoomNum && self.meetingRoomNum.length > 0 && !self.isInvite){
        [self joinMeetingRoom:self.meetingRoomNum];
    }else if(self.isInvite && self.callId){
        self.hostLabel.text = [NSLocalizedString(@"主持人：", nil) stringByAppendingString:EC_ValidateNullStr(self.creater)];
        _meetingNameLabel.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedString(@"房间名称", nil), self.roomName];
        [self acceptInvite];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)showVoiceMeetingView{
    [[AppDelegate sharedInstanced].window addSubview:self.view];
}

- (NSTimer *)timer{
    if(!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startTimer) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}

- (void)startTimer{
    self.second++;
    NSInteger sec = self.second % 60;
    NSInteger min = self.second / 60;
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", min, sec];
}

#pragma mark - 群聊操作
- (void)quertMeetingMember{
    [[ECDevice sharedInstance].meetingManager queryMeetingMembersByMeetingType:ECMeetingType_MultiVoice andMeetingNumber:self.meetingRoomNum completion:^(ECError *error, NSArray *members) {
        for (ECMultiVoiceMeetingMember *who in members) {
            if(who.role == 2 && [[ECDevicePersonInfo sharedInstanced].userName isEqualToString:who.account.account])
                self.isCreater = YES;
            BOOL isHave = NO;
            for (ECMultiVoiceMeetingMember *m in self.collectionSource) {
                if([m.account.account isEqualToString:who.account.account]){
                    isHave = YES;
                    break;
                }
            }
            if(isHave)
                continue;
            [self.collectionSource addObject:who];
        }
        self.collectionView.isCreater = self.isCreater;
        self.collectionView.collectionSource = self.collectionSource;
    }];
}

- (void)createMeetingRoom{
    if(!self.meetingParams){
        [self disMissAction];
        return;
    }
    EC_ShowHUD(@"")
    [[ECDevice sharedInstance].meetingManager exitMeeting];
    [[ECDevice sharedInstance].meetingManager createMultMeetingByType:self.meetingParams completion:^(ECError *error, NSString *meetingNumber) {
        EC_HideHUD
        self.meetingRoomNum = meetingNumber;
        self.collectionView.meetingRoomNum = meetingNumber;
        self.collectionView.meetingRoomName = self.meetingParams.meetingName;
        if(error.errorCode == ECErrorType_NoError){
            [ECDeviceDelegateHelper sharedInstanced].isCallBusy = YES;
            self.isCreater = YES;
            self.collectionView.isCreater = YES;
            [self showDismissBtn];
            EC_Demo_AppLog(@"语音会议创建成功");
            self.second = 0;
            self.timer.fireDate = [NSDate distantPast];
            [self.tableSource addObject:NSLocalizedString(@"发起会议", nil)];
            self.tableView.tableSource = self.tableSource;
            [self quertMeetingMember];
        }else{
            EC_Demo_AppLog(@"语音会议创建失败, %ld ==%@", error.errorCode, error.errorDescription);
            [ECCommonTool toast:@"语音会议创建失败"];
//            [self.navigationController popViewControllerAnimated:YES];
            [self.view removeFromSuperview];
        }
    }];    
}

- (void)joinMeetingRoom:(NSString *)meetingNum{
    EC_ShowHUD(@"")
    [[ECDevice sharedInstance].meetingManager exitMeeting];
    [[ECDevice sharedInstance].meetingManager joinMeeting:meetingNum ByMeetingType:ECMeetingType_MultiVoice andMeetingPwd:self.password completion:^(ECError *error, NSString *meetingNumber) {
        EC_HideHUD
        self.meetingRoomNum = meetingNumber;
        self.collectionView.meetingRoomNum = meetingNumber;
        self.collectionView.meetingRoomName = self.meetingRoom.roomName;
        if(error.errorCode == ECErrorType_NoError){
            [ECDeviceDelegateHelper sharedInstanced].isCallBusy = YES;
            self.second = 0;
            self.timer.fireDate = [NSDate distantPast];
            [self quertMeetingMember];
        }else{
            EC_Demo_AppLog(@"语音会议加入失败, %ld ==%@", error.errorCode, error.errorDescription);
            [ECCommonTool toast:@"语音会议加入失败"];
//            [self.navigationController popViewControllerAnimated:YES];
            [self.view removeFromSuperview];
        }
    }];
}

- (void)acceptInvite{
    if(![[ECDevice sharedInstance].VoIPManager acceptCall:self.callId withType:VOICE]){
        [ECDeviceDelegateHelper sharedInstanced].isCallBusy = YES;
        self.second = 0;
        self.timer.fireDate = [NSDate distantPast];
        [self quertMeetingMember];        
    }else
        [self.view removeFromSuperview];
}

- (void)joinOrCreateError:(ECError *)error withMeetingNum:(NSString *)meetingNumber{
    if (error.errorCode == ECErrorType_NotExist) {
        error.errorDescription = [NSString stringWithFormat: @"房间%@已解散或者不存在！",meetingNumber];
    } else if (error.errorCode == ECErrorType_PasswordInvalid) {
        error.errorDescription = @"密码验证失败！";
    }
    NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
    UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"加入群聊失败" message:[NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail]  delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertview show];
}

- (void)onReceiveChatroomMsg:(NSNotification *)noti{
    ECMultiVoiceMeetingMsg* receiveMsgInfo = noti.object;
    if (![receiveMsgInfo.roomNo isEqualToString: self.meetingRoomNum]) {
        return;
    }
    EC_Demo_AppLog(@"type = %ld", receiveMsgInfo.type);
    switch (receiveMsgInfo.type) {
        case MultiVoice_JOIN:
            for (ECVoIPAccount *who in receiveMsgInfo.joinArr) {
                BOOL isHave = NO;
                for (ECMultiVoiceMeetingMember *m in self.collectionSource) {
                    if([m.account.account isEqualToString:who.account]){
                        isHave = YES;
                        break;
                    }
                }
                if(isHave)
                    continue;
                [self.tableSource addObject:[NSString stringWithFormat:@"%@ %@%@", [NSDate ec_stringFromCurrentDateWithFormate:@"HH:mm"], who.account, NSLocalizedString(@"进入了会议", nil)]];
                ECMultiVoiceMeetingMember *member = [[ECMultiVoiceMeetingMember alloc] init];
                member.account = who;
                member.role = 0;
                [self.collectionSource addObject:member];
            }
            self.tableView.tableSource = self.tableSource;
            self.collectionView.collectionSource = self.collectionSource;
            break;
        case MultiVoice_EXIT:
            for (ECVoIPAccount *who in receiveMsgInfo.exitArr) {
                [self.tableSource addObject:[NSString stringWithFormat:@"%@ %@%@", [NSDate ec_stringFromCurrentDateWithFormate:@"HH:mm"], who.account, NSLocalizedString(@"退出了会议", nil)]];
                for (ECMultiVoiceMeetingMember *m in self.collectionSource) {
                    if ([who.account isEqualToString:m.account.account] && who.isVoIP == m.account.isVoIP && ![who.account isEqualToString:[ECDevicePersonInfo sharedInstanced].userName]) {
                        UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"退出房间" message:[NSString stringWithFormat:@"%@退出房间", who.account]  delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertview show];
                        [self.collectionSource removeObject:m];
                        break;
                    }
                }
            }
            self.collectionView.collectionSource = self.collectionSource;
            self.tableView.tableSource = self.tableSource;
            break;
        case MultiVoice_DELETE:{
            UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:nil message:@"房间已解散"  delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertview show];
            [[ECDevice sharedInstance].meetingManager exitMeeting];
            [self clearConfig];
        }
            break;
        case MultiVoice_CUT:{
            UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:nil message:@"会议中断"  delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertview show];
            [[ECDevice sharedInstance].meetingManager exitMeeting];
            [self clearConfig];
        }
            break;
        case MultiVoice_REMOVEMEMBER:{
            if ([self.meetingRoomNum isEqualToString:receiveMsgInfo.roomNo]){
                if([receiveMsgInfo.who.account isEqualToString:[ECAppInfo sharedInstanced].persionInfo.userName]){
                    UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"您已被请出房间" message:@"抱歉，您被创建者请出房间"  delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertview show];
                    [self disMissAction];
                    return;
                }
                for (ECMultiVoiceMeetingMember *m in self.collectionSource) {
                    if ([receiveMsgInfo.who.account isEqualToString:m.account.account] && receiveMsgInfo.who.isVoIP==m.account.isVoIP){
                        [self.collectionSource removeObject:m];
                        break;
                    }
                    self.collectionView.collectionSource = self.collectionSource;
                }
            }
        }
            break;
        case MultiVoice_SPEAKLISTEN:
            for (ECMultiVoiceMeetingMember *m in self.collectionSource) {
                if([m.account.account isEqualToString:receiveMsgInfo.who.account]){
                    EC_Demo_AppLog(@"speak listen = %@", receiveMsgInfo.speakListen);
                    m.speakListen = [NSString stringWithFormat:@"%@", receiveMsgInfo.speakListen];
                    if(receiveMsgInfo.speakListen.integerValue == 0)
                        m.speakListen = @"00";
                    break;
                }
            }
            self.collectionView.collectionSource = self.collectionSource;
            break;
        default:
            break;
    }
}

#pragma mark -
- (void)packupAction{
//    [[ECDevice sharedInstance].meetingManager exitMeeting];
//    [self clearConfig];
//    [self.view removeFromSuperview];
    CGRect rect = CGRectMake((EC_kScreenW - EC_Scale_Size) / 2, 150, EC_Scale_Size, EC_Scale_Size);
    UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    CGFloat radius = self.view.ec_height - rect.origin.y;
    CGRect startRect = CGRectInset(rect, -radius, -radius);
    UIBezierPath *startPath = [UIBezierPath bezierPathWithOvalInRect:startRect];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = endPath.CGPath;
    self.view.layer.mask = shapeLayer;
    self.shapeLayer = shapeLayer;
    // 添加动画
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (id)startPath.CGPath;
    pathAnimation.toValue = (id)endPath.CGPath;
    pathAnimation.duration = 1;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.delegate = self;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fillMode = kCAFillModeForwards;
    [shapeLayer addAnimation:pathAnimation forKey:@"packupAnimation"];
}

- (void)openAction{
    [self.openView removeFromSuperview];
    self.openView = nil;
    CGRect rect = CGRectMake((EC_kScreenW - EC_Scale_Size) / 2, 150, EC_Scale_Size, EC_Scale_Size);
    CGPoint center = CGPointMake(EC_kScreenW / 2, 150 + EC_Scale_Size / 2);
    [UIView animateWithDuration:0.3 animations:^{
        self.view.center = center;
    } completion:^(BOOL finished) {
        self.view.bounds = [UIScreen mainScreen].bounds;
        self.view.frame = self.view.bounds;
        CAShapeLayer *shapeLayer = self.shapeLayer;
        UIBezierPath *startPath = [UIBezierPath bezierPathWithOvalInRect:rect];
        CGFloat radius = self.view.ec_height - center.y;
        CGRect endRect = CGRectInset(rect, -radius, -radius);
        UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:endRect];
        shapeLayer.path = endPath.CGPath;
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.fromValue = (id)startPath.CGPath;
        pathAnimation.toValue = (id)endPath.CGPath;
        pathAnimation.duration = 0.5;
        pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        pathAnimation.delegate = self;
        pathAnimation.removedOnCompletion = NO;
        pathAnimation.fillMode = kCAFillModeForwards;
        [shapeLayer addAnimation:pathAnimation forKey:@"openAnimation"];
    }];
}

- (void)disMissAction{
    [[ECDevice sharedInstance].meetingManager deleteMultMeetingByMeetingType:ECMeetingType_MultiVoice andMeetingNumber:self.meetingRoomNum completion:^(ECError *error, NSString *meetingNumber) {
        EC_Demo_AppLog(@"error code = %ld,,,,desc = %@", error.errorCode, error.errorDescription);
    }];
    [self clearConfig];
}

- (void)clearConfig{
    if(_timer){
        [_timer invalidate];
        _timer = nil;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_MeetingEnd object:nil];
    [ECDeviceDelegateHelper sharedInstanced].isCallBusy = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
    [self.openView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    int index = (int)[[self.navigationController viewControllers] indexOfObject:self];
//    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-(self.isCreater ? 2 : 1)]animated:YES];
}

#pragma mark - animation delegate,通话结束处理
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([anim isEqual:[self.shapeLayer animationForKey:@"packupAnimation"]]) {
        CGRect rect = self.view.frame;
        CGRect frame = CGRectMake((EC_kScreenW - EC_Scale_Size) / 2, 150, EC_Scale_Size, EC_Scale_Size);
        rect.origin = frame.origin;
        self.view.bounds = rect;
        rect.size = frame.size;
        self.view.frame = rect;
        [UIView animateWithDuration:0.5 animations:^{
            self.view.center = CGPointMake(EC_kScreenW - EC_Scale_Size / 2, self.view.center.y);
        } completion:^(BOOL finished) {
            [self.view.superview addSubview:self.openView];
        }];
    }else if ([anim isEqual:[self.shapeLayer animationForKey:@"openAnimation"]]) {
        self.view.layer.mask = nil;
        self.shapeLayer = nil;
    }
}

#pragma mark - UI创建
- (void)buildUI{
    self.view.backgroundColor = EC_Color_Tabbar;
    [self.view addSubview:self.packUpBtn];
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.hostLabel];
    [self.view addSubview:self.meetingNameLabel];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.alertLabel];
    [self.view addSubview:self.timeLabel];
    
    EC_WS(self)
    NSArray *operationInfos = @[@{@"image":@"maikefeng", @"selectImage":@"maikefengNormal", @"title":NSLocalizedString(@"麦克风", nil), @"type":@(ECCallOperationType_Microphone)}, @{@"image":@"exit", @"selectImage":@"exit", @"title":NSLocalizedString(@"退出", nil), @"type":@(ECCallOperationType_Exit)}, @{@"image":@"mianti", @"selectImage":@"meetingmianti", @"title":NSLocalizedString(@"扬声器", nil), @"selectImage":@"meetingmianti", @"type":@(ECCallOperationType_Speaker)}];
    ECCallSettingView *settingView = [[ECCallSettingView alloc] initWithOperation:operationInfos withFixedSpacing:46 leadSpacing:56 tailSpacing:56];
    settingView.exitMeeting = ^{
        [weakSelf clearConfig];
    };
    [self.view addSubview:settingView];

    [self.packUpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(22);
        make.top.equalTo(weakSelf).offset(32);
        make.width.height.offset(44);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(15);
        make.top.equalTo(weakSelf.packUpBtn.mas_bottom).offset(20);
        make.width.height.offset(66);
    }];
    [self.hostLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.nameLabel.mas_right).offset(10);
        make.top.equalTo(weakSelf.nameLabel.mas_top);
        make.right.equalTo(weakSelf);
        make.height.offset(33);
    }];
    [self.meetingNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.hostLabel.mas_left);
        make.top.equalTo(weakSelf.hostLabel.mas_bottom);
        make.right.equalTo(weakSelf);
        make.height.offset(33);
    }];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.height.offset(85);
        make.bottom.equalTo(weakSelf).offset(-20);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.top.equalTo(weakSelf.nameLabel.mas_bottom).offset(10);
        make.bottom.equalTo(weakSelf.collectionView.mas_top).offset(-10);
    }];
    [self.alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.nameLabel.mas_bottom).offset(10);
        make.right.equalTo(weakSelf).offset(-30);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.alertLabel.mas_bottom).offset(5);
        make.right.equalTo(weakSelf).offset(-28);
    }];
}

- (void)showDismissBtn{
    [self.view addSubview:self.dismissBtn];
    EC_WS(self)
    [self.dismissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(28);
        make.right.equalTo(weakSelf).offset(-24);
        make.height.offset(28);
        make.width.offset(100);
    }];
}

- (UIButton *)packUpBtn{
    if(!_packUpBtn){
        _packUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_packUpBtn setImage:EC_Image_Named(@"suoxiao") forState:UIControlStateNormal];
        [_packUpBtn addTarget:self action:@selector(packupAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _packUpBtn;
}

- (UIButton *)dismissBtn{
    if(!_dismissBtn){
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dismissBtn addTarget:self action:@selector(disMissAction) forControlEvents:UIControlEventTouchUpInside];
        [_dismissBtn setTitle:NSLocalizedString(@"解散房间", nil) forState:UIControlStateNormal];
        [_dismissBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
        _dismissBtn.backgroundColor = [UIColor colorWithHex:0xf88dbb];
        _dismissBtn.titleLabel.font = EC_Font_SystemBold(16);
        _dismissBtn.ec_radius = 14;
    }
    return _dismissBtn;
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
        NSString *host = @"";
        if(self.meetingRoom){
            host = self.meetingRoom.creator;
        }else if (self.meetingParams){
            host = [ECAppInfo sharedInstanced].persionInfo.userName;
        }
        _hostLabel.text = [NSLocalizedString(@"主持人：", nil) stringByAppendingString:host];
    }
    return _hostLabel;
}

- (UILabel *)meetingNameLabel{
    if(!_meetingNameLabel){
        _meetingNameLabel = [[UILabel alloc] init];
        _meetingNameLabel.textColor = EC_Color_Sec_Text;
        _meetingNameLabel.font = EC_Font_System(14);
        NSString *name = @"";
        if(self.meetingRoom){
            name = self.meetingRoom.roomName;
        }else if (self.meetingParams){
            name = self.meetingParams.meetingName;
        }
        _meetingNameLabel.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedString(@"房间名称", nil), name];
    }
    return _meetingNameLabel;
}

- (ECMeetingUserStatusView *)tableView{
    if(!_tableView){
        _tableView = [[ECMeetingUserStatusView alloc] init];
    }
    return _tableView;
}

- (UILabel *)alertLabel{
    if(!_alertLabel){
        _alertLabel = [[UILabel alloc] init];
        _alertLabel.textColor = EC_Color_Sec_Text;
        _alertLabel.font = EC_Font_System(12);
        _alertLabel.text = NSLocalizedString(@"会议计时", nil);
    }
    return _alertLabel;
}

- (UILabel *)timeLabel{
    if(!_timeLabel){
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor colorWithHex:0x666666];
        _timeLabel.font = EC_Font_SystemBold(17);
        _timeLabel.text = @"00 : 00";
    }
    return _timeLabel;
}

- (ECMeetingMemberView *)collectionView{
    if(!_collectionView){
        _collectionView = [[ECMeetingMemberView alloc] initWithFrame:CGRectMake(0, EC_kScreenH -280, EC_kScreenW, 90)];
        _collectionView.meetingType = ECMeetingType_MultiVoice;
    }
    return _collectionView;
}

- (ECCallOpenView *)openView{
    if(!_openView){
        _openView = [[ECCallOpenView alloc] initWithFrame:self.view.frame];
        _openView.userInteractionEnabled = YES;
        _openView.backgroundColor = [UIColor colorWithHex:0x12b7f5];
        _openView.ec_radius = self.view.ec_width / 2;
        EC_WS(self)
        _openView.touchMove = ^(CGRect frame){
            weakSelf.view.frame = frame;
        };
        _openView.status = @"会议中";
        _openView.touchMoveEnd = ^(CGFloat x, CGFloat y){
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.view.frame = CGRectMake(x, y, weakSelf.view.ec_width, weakSelf.view.ec_height);
                weakSelf.openView.frame = CGRectMake(x, y, weakSelf.view.ec_width, weakSelf.view.ec_height);
            }];
        };
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openAction)];
        [_openView addGestureRecognizer:tap];
    }
    return _openView;
}

- (void)dealloc{
    if(_timer){
        [_timer invalidate];
        _timer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
