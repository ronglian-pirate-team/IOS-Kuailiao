//
//  ECMeetingVideoVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/18.
//
//

#import "ECMeetingVideoVC.h"
#import "ECCallSettingView.h"
#import "ECMeetingMemberView.h"
#import "ECCallOperationView.h"
#import "ECMutiVideoCollectionView.h"
#import "ECCallOpenView.h"

#define EC_Scale_W 80
#define EC_Scale_H 105

#define EC_Animation_Duration 0.2

@interface ECMeetingVideoVC ()<CAAnimationDelegate>

@property (nonatomic, strong) UIButton *packUpBtn;//收起
@property (nonatomic, strong) UIButton *dismissBtn;//解散
@property (nonatomic, strong) UILabel *hostLabel;//会议创建者
@property (nonatomic, strong) UILabel *meetingNameLabel;//会议名称

@property (nonatomic, strong) UILabel *alertLabel;
@property (nonatomic, strong) UILabel *timeLabel;//会议时间显示

@property (nonatomic, strong) ECMeetingMemberView *collectionView;
@property (nonatomic, strong) NSMutableArray *collectionSource;

@property (nonatomic, assign) BOOL isCreater;

@property (nonatomic, assign) NSInteger second;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) ECMutiVideoCollectionView *videosView;

@property (strong, nonatomic) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) ECCallOpenView *openView;
@property (nonatomic, strong) UIView *localView;

@property (nonatomic, strong) ECMultiVideoMeetingMember *selfVideoMember;

@end

@implementation ECMeetingVideoVC
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveChatroomMsg:) name:EC_KNOTIFICATION_ReceiveMultiVideoMeetingMsg object:nil];
    [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:YES];
    [[ECDevice sharedInstance].VoIPManager setMute:NO];
    self.collectionSource = [NSMutableArray array];
    if(self.meetingParams){
        [self createMeetingRoom];
    }else if(self.meetingRoomNum && self.meetingRoomNum.length > 0){
        if(!EC_ISNullStr(self.creater)){
            self.hostLabel.text = [NSLocalizedString(@"主持人：", nil) stringByAppendingString:EC_ValidateNullStr(self.creater)];
            self.meetingNameLabel.text = [NSString stringWithFormat:@"%@：%@", NSLocalizedString(@"房间名称", nil), self.roomName];
        }
        [self joinMeetingRoom:self.meetingRoomNum];
    }
}

- (void)showVideoMeetingView{
    [[AppDelegate sharedInstanced].window addSubview:self.view];
}

- (void)onReceiveChatroomMsg:(NSNotification *)noti{
    ECMultiVideoMeetingMsg* receiveMsgInfo = noti.object;
    if (![receiveMsgInfo.roomNo isEqualToString: self.meetingRoomNum]) {
        return;
    }
    switch (receiveMsgInfo.type) {
        case MultiVideo_JOIN:
            for (ECVoIPAccount *who in receiveMsgInfo.joinArr) {
                BOOL isHave = NO;
                for (ECMultiVideoMeetingMember *m in self.collectionSource) {
                    if([m.voipAccount.account isEqualToString:who.account]){
                        isHave = YES;
                        break;
                    }
                }
                if(isHave)
                    continue;
                ECMultiVideoMeetingMember *member = [[ECMultiVideoMeetingMember alloc] init];
                member.voipAccount = who;
                member.role = 0;
                member.videoState = receiveMsgInfo.videoState;
                member.videoSource = receiveMsgInfo.videoSource;
                [self.collectionSource addObject:member];
            }
            self.collectionView.collectionSource = self.collectionSource;
            self.videosView.collectionSource = self.collectionSource;
            break;
        case MultiVideo_EXIT:
            for (ECVoIPAccount *who in receiveMsgInfo.exitArr) {
                for (ECMultiVideoMeetingMember *m in self.collectionSource) {
                    if ([who.account isEqualToString:m.voipAccount.account] && who.isVoIP == m.voipAccount.isVoIP && ![who.account isEqualToString:[ECDevicePersonInfo sharedInstanced].userName]) {
                        UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"退出房间" message:[NSString stringWithFormat:@"%@退出房间", who.account]  delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alertview show];
                        [self.collectionSource removeObject:m];
                        break;
                    }
                }
            }
            self.collectionView.collectionSource = self.collectionSource;
            self.videosView.collectionSource = self.collectionSource;
            break;
        case MultiVideo_DELETE:{
            UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:nil message:@"房间已解散"  delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertview show];
            [self exitMeeting];
        }
            break;
        case MultiVideo_CUT:{
            UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:nil message:@"会议中断"  delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertview show];
            [self exitMeeting];
        }
            break;
        case MultiVideo_REMOVEMEMBER:{
            if ([self.meetingRoomNum isEqualToString:receiveMsgInfo.roomNo]){
                if([receiveMsgInfo.who.account isEqualToString:[ECAppInfo sharedInstanced].persionInfo.userName]){
                    UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"您已被请出房间" message:@"抱歉，您被创建者请出房间"  delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertview show];
                    [self disMissAction];
                    return;
                }
                for (ECMultiVideoMeetingMember *m in self.collectionSource) {
                    if ([receiveMsgInfo.who.account isEqualToString:m.voipAccount.account] && receiveMsgInfo.who.isVoIP==m.voipAccount.isVoIP){
                        [self.collectionSource removeObject:m];
                        self.collectionView.collectionSource = self.collectionSource;
                        self.videosView.collectionSource = self.collectionSource;
                        break;
                    }
                }
            }
        }
            break;
        case MultiVideo_SPEAKLISTEN:
            for (ECMultiVideoMeetingMember *m in self.collectionSource) {
                if([m.voipAccount.account isEqualToString:receiveMsgInfo.who.account]){
                    m.speakListen = [NSString stringWithFormat:@"%@", receiveMsgInfo.speakListen];
                    EC_Demo_AppLog(@"%@", receiveMsgInfo.speakListen);
                    if(receiveMsgInfo.speakListen.integerValue == 0)
                        m.speakListen = @"00";
                    break;
                }
            }
            self.collectionView.collectionSource = self.collectionSource;
            break;
        case MultiVideo_PUBLISH:
            for (ECMultiVideoMeetingMember *m in self.collectionSource) {
                if([m.voipAccount.account isEqualToString:receiveMsgInfo.who.account]){
                    m.videoState = 1;
                    break;
                }
            }
            self.collectionView.collectionSource = self.collectionSource;
            break;
        case MultiVideo_UNPUBLISH:
            for (ECMultiVideoMeetingMember *m in self.collectionSource) {
                if([m.voipAccount.account isEqualToString:receiveMsgInfo.who.account]){
                    m.videoState = 2;
                    break;
                }
            }
            self.collectionView.collectionSource = self.collectionSource;
            break;
        default:
            break;
    }
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
    [[ECDevice sharedInstance].meetingManager queryMeetingMembersByMeetingType:ECMeetingType_MultiVideo andMeetingNumber:self.meetingRoomNum completion:^(ECError *error, NSArray *members) {
        for (ECMultiVideoMeetingMember *who in members) {
            if(who.role == 2 && [[ECDevicePersonInfo sharedInstanced].userName isEqualToString:who.voipAccount.account])
                self.isCreater = YES;
            BOOL isHave = NO;
            for (ECMultiVideoMeetingMember *m in self.collectionSource) {
                if([m.voipAccount.account isEqualToString:[ECDevicePersonInfo sharedInstanced].userName])
                    self.selfVideoMember = m;
                if([m.voipAccount.account isEqualToString:who.voipAccount.account]){
                    isHave = YES;
                    break;
                }
            }
            if(isHave)
                continue;
            [self.collectionSource addObject:who];
        }
        self.videosView.collectionSource = self.collectionSource;
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
        self.videosView.meetingRoomNum = meetingNumber;
        self.collectionView.meetingRoomNum = meetingNumber;
        self.collectionView.meetingRoomName = self.meetingParams.meetingName;
        if(error.errorCode == ECErrorType_NoError){
            [ECDeviceDelegateHelper sharedInstanced].isCallBusy = YES;
            self.isCreater = YES;
            [self showDismissBtn];
            self.collectionView.isCreater = YES;
            EC_Demo_AppLog(@"视频会议创建成功");
            self.second = 0;
            self.timer.fireDate = [NSDate distantPast];
            [self quertMeetingMember];
        }else{
            EC_Demo_AppLog(@"视频会议创建失败, %ld ==%@", error.errorCode, error.errorDescription);
            [ECCommonTool toast:@"视频会议创建失败"];
//            [self.navigationController popViewControllerAnimated:YES];
            [self.view removeFromSuperview];
        }
    }];
}

- (void)joinMeetingRoom:(NSString *)meetingNum{
    EC_ShowHUD(@"")
    [[ECDevice sharedInstance].meetingManager exitMeeting];
    [[ECDevice sharedInstance].meetingManager joinMeeting:meetingNum ByMeetingType:ECMeetingType_MultiVideo andMeetingPwd:self.password completion:^(ECError *error, NSString *meetingNumber) {
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
            EC_Demo_AppLog(@"视频会议加入失败, %ld ==%@", error.errorCode, error.errorDescription);
            [ECCommonTool toast:@"视频会议加入失败"];
//            [self.navigationController popViewControllerAnimated:YES];
            [self.view removeFromSuperview];
        }
    }];
}

#pragma mark -
- (void)openAction{
//    [[ECDevice sharedInstance].VoIPManager setVideoView:nil andLocalView:self.view];
    [self showView];
    [UIView animateWithDuration:EC_Animation_Duration animations:^{
        self.localView.frame = CGRectMake(0, 0, EC_kScreenW, EC_kScreenH);
    }];
    CGRect frame = self.view.frame;//CGRectMake(0, 150, EC_Scale_W, EC_Scale_H);
    CGPoint center = CGPointMake(EC_Scale_W / 2, 150 + EC_Scale_H / 2);
    [self.openView removeFromSuperview];
    self.openView = nil;
    self.view.bounds = [UIScreen mainScreen].bounds;
    self.view.frame = self.view.bounds;
    CAShapeLayer *shapeLayer = self.shapeLayer;
    UIBezierPath *startPath = [UIBezierPath bezierPathWithRect:frame];
    CGFloat radius = MAX(self.view.ec_height - center.y, center.y);
    CGRect endRect = CGRectInset(frame, -radius, -radius);
    UIBezierPath *endPath = [UIBezierPath bezierPathWithRect:endRect];
    shapeLayer.path = endPath.CGPath;
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (id)startPath.CGPath;
    pathAnimation.toValue = (id)endPath.CGPath;
    pathAnimation.duration = EC_Animation_Duration;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.delegate = self;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fillMode = kCAFillModeForwards;
    [shapeLayer addAnimation:pathAnimation forKey:@"openAnimation"];
}

- (void)packupAction{
    [UIView animateWithDuration:EC_Animation_Duration animations:^{
        self.localView.frame = CGRectMake(0, 150, EC_Scale_W, EC_Scale_H);
    }];
    [self hiddenView];
    CGRect frame = CGRectMake(0, 150, EC_Scale_W, EC_Scale_H);
    CGPoint center = CGPointMake(EC_Scale_W / 2, EC_Scale_H / 2 + 150);
    UIBezierPath *endPath = [UIBezierPath bezierPathWithRect:frame];
    CGFloat radius = MAX(self.view.ec_height - center.y, center.y);
    CGRect startRect = CGRectInset(frame, -radius, -radius);
    UIBezierPath *startPath = [UIBezierPath bezierPathWithRect:startRect];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = endPath.CGPath;
    self.view.layer.mask = shapeLayer;
    self.shapeLayer = shapeLayer;
    // 添加动画
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.fromValue = (id)startPath.CGPath;
    pathAnimation.toValue = (id)endPath.CGPath;
    pathAnimation.duration = EC_Animation_Duration;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.delegate = self;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fillMode = kCAFillModeForwards;
    [shapeLayer addAnimation:pathAnimation forKey:@"packupAnimation"];
}

#pragma mark - animation delegate,通话结束处理
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([anim isEqual:[self.shapeLayer animationForKey:@"packupAnimation"]]) {
        CGRect rect = self.view.frame;
        CGRect frame = CGRectMake(0, 150, EC_Scale_W, EC_Scale_H);
        rect.origin = frame.origin;
        self.view.bounds = rect;
        rect.size = frame.size;
        self.view.frame = rect;
        [self.view.superview addSubview:self.openView];
    }else if ([anim isEqual:[self.shapeLayer animationForKey:@"openAnimation"]]) {
        self.view.layer.mask = nil;
        self.shapeLayer = nil;
    }
}

- (void)hiddenView{
    self.packUpBtn.hidden = YES;
    self.hostLabel.hidden = YES;
    self.meetingNameLabel.hidden = YES;
    self.alertLabel.hidden = YES;
    self.timeLabel.hidden = YES;
    self.collectionView.hidden = YES;
    self.videosView.hidden = YES;
}

- (void)showView{
    self.packUpBtn.hidden = NO;
    self.hostLabel.hidden = NO;
    self.meetingNameLabel.hidden = NO;
    self.alertLabel.hidden = NO;
    self.timeLabel.hidden = NO;
    self.collectionView.hidden = NO;
    self.videosView.hidden = NO;
}

- (void)disMissAction{
    [[ECDevice sharedInstance].meetingManager deleteMultMeetingByMeetingType:ECMeetingType_MultiVideo andMeetingNumber:self.meetingRoomNum completion:nil];
    [self clearConfig];
}

- (void)exitMeeting{
    [[ECDevice sharedInstance].meetingManager exitMeeting];
    [self clearConfig];
}

- (void)clearConfig{
    if(_timer){
        [_timer invalidate];
        _timer = nil;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_MeetingEnd object:nil];
    [ECDeviceDelegateHelper sharedInstanced].isCallBusy = NO;
    [self.openView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.view removeFromSuperview];
//    int index = (int)[[self.navigationController viewControllers] indexOfObject:self];
//    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-(self.isCreater ? 2 : 1)]animated:YES];
}

#pragma mark - UI创建
- (void)buildUI{
    self.view.backgroundColor = EC_Color_Tabbar;
    self.localView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, EC_kScreenH)];
    [self.view addSubview:self.localView];
    [self.view addSubview:self.packUpBtn];
    [self.view addSubview:self.hostLabel];
    [self.view addSubview:self.meetingNameLabel];
    [self.view addSubview:self.alertLabel];
    [self.view addSubview:self.timeLabel];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.videosView];
    NSArray *operationInfos = @[@{@"image":@"maikefeng", @"selectImage":@"maikefengNormal", @"title":NSLocalizedString(@"麦克风", nil), @"type":@(ECCallOperationType_Microphone)}, @{@"image":@"exit", @"title":NSLocalizedString(@"退出", nil), @"type":@(ECCallOperationType_Exit)}, @{@"image":@"mianti", @"selectImage":@"meetingmianti", @"title":NSLocalizedString(@"扬声器", nil), @"type":@(ECCallOperationType_Speaker)}, @{@"image":@"camera", @"selectImage":@"meetingcamera", @"title":NSLocalizedString(@"摄像头", nil), @"type":@(ECCallOperationType_Camera)}];
    ECCallSettingView *settingView = [[ECCallSettingView alloc] initWithOperation:operationInfos withFixedSpacing:41 leadSpacing:10 tailSpacing:12];
    settingView.exitMeeting = ^{
        [[ECDevice sharedInstance].meetingManager exitMeeting];
        [self clearConfig];
    };
    [self.view addSubview:settingView];
    EC_WS(self)
    [self.packUpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(22);
        make.top.equalTo(weakSelf).offset(32);
    }];
    [self.hostLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(22);
        make.top.equalTo(weakSelf).offset(72);
        make.height.offset(33);
    }];
    [self.meetingNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.hostLabel.mas_left);
        make.top.equalTo(weakSelf.hostLabel.mas_bottom);
        make.height.offset(33);
    }];
    [self.alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.hostLabel.mas_top).offset(10);
        make.right.equalTo(weakSelf).offset(-30);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.alertLabel.mas_bottom).offset(5);
        make.right.equalTo(weakSelf).offset(-28);
    }];
    [self.videosView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.collectionView.mas_bottom).offset(10);
        make.left.right.equalTo(weakSelf);
        make.height.offset(200);
    }];
    [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.height.offset(85);
        make.bottom.equalTo(weakSelf).offset(-15);
    }];
    [[ECDevice sharedInstance].VoIPManager setVideoView:nil andLocalView:self.localView];
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
        [_packUpBtn setImage:EC_Image_Named(@"yuyinliaotianIconSuoxiao") forState:UIControlStateNormal];
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
        _collectionView = [[ECMeetingMemberView alloc] initWithFrame:CGRectMake(0, 140, EC_kScreenW, 90)];
        _collectionView.meetingType = ECMeetingType_MultiVideo;
        _collectionView.backgroundColor = EC_Color_Clear;
    }
    return _collectionView;
}

- (ECMutiVideoCollectionView *)videosView{
    if(!_videosView){
        _videosView = [[ECMutiVideoCollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.collectionView.frame), EC_kScreenW, 200)];
        _videosView.meetingRoomNum = self.meetingRoomNum;
    }
    return _videosView;
}

- (ECCallOpenView *)openView{
    if(!_openView){
        _openView = [[ECCallOpenView alloc] initWithFrame:self.view.frame];
        _openView.userInteractionEnabled = YES;
        _openView.backgroundColor = EC_Color_Clear;
        _openView.callType = VIDEO;
        EC_WS(self)
        _openView.touchMove = ^(CGRect frame){
            weakSelf.view.frame = frame;
        };
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

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

@end
