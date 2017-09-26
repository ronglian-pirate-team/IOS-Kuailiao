//
//  ECCallVideoView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/12.
//
//

#import "ECCallVideoView.h"
#import "ECCallOpenView.h"
#import "ECCallOperationView.h"
#import "ECFriendManager.h"
#import <AVFoundation/AVFoundation.h>

#define EC_LocalViewW 80.0f
#define EC_LocalViewH 107.0f

@interface ECCallVideoView ()<CAAnimationDelegate>

@property (nonatomic, strong) ECCallOpenView *localView;
@property (nonatomic, strong) UIView *remoteVIew;
@property (nonatomic, strong) UIButton *packUpBtn;
@property (nonatomic, strong) UIButton *switchCamnerBtn;

@property (nonatomic, strong) ECCallOpenView *openView;

@property (strong, nonatomic) CAShapeLayer *shapeLayer;

@property (nonatomic, strong) ECCallOperationView *quietView;
@property (nonatomic, strong) ECCallOperationView *cameraView;
@property (nonatomic, strong) ECCallOperationView *speakerView;
@property (nonatomic, strong) ECCallOperationView *beautyView;
@property (nonatomic, strong) ECCallOperationView *hangUpView;
@property (nonatomic, strong) ECCallOperationView *rejectView;
@property (nonatomic, strong) ECCallOperationView *answerView;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *statusLabel;

@property (nonatomic, assign) NSInteger status;//0 呼叫 1被呼叫 2通话中


@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger second;

@property (nonatomic, assign) NSInteger currentCameraIndex;

@end

@implementation ECCallVideoView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.alpha = 0;
        [[ECDevice sharedInstance].VoIPManager setMute:NO];
        self.currentCameraIndex = [ECDeviceVoipHelper sharedInstanced].cameraInfoArray.count - 1;
        [self switchCameraAction];
        [self buildUI];
    }
    return self;
}

- (void)show{
    if(self.isIncomingCall){
        self.status = 1;
    }else{
        self.status = 0;
        self.callId = [[ECDevice sharedInstance].VoIPManager makeCallWithType:VIDEO andCalled:self.callNumber];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallEvents:) name:EC_KNOTIFICATION_Voip_ReceiveCallEvents object:nil];
    [[AppDelegate sharedInstanced].window addSubview:self];
    [[ECDevice sharedInstance].VoIPManager setVideoView:self.remoteVIew andLocalView:self.localView];
    self.nameLabel.text = self.callNumber;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [self fetchFriendInfo];
    }];
}

- (void)fetchFriendInfo{
    self.friendInfo = [[ECDBManager sharedInstanced].friendMgr queryFriend:self.callNumber];
    [self updateViewInfo];
//    [[ECFriendManager sharedInstanced] fetchFriendInfoFromServer:self.callNumber completion:^(ECFriend *friend) {
//        self.friendInfo = friend;
//        [self updateViewInfo];
//    }];
}

#pragma mark - 获取好友信息后更新数据
- (void)updateViewInfo{
    if(self.friendInfo){
        if(self.friendInfo.remarkName && self.friendInfo != nil && self.friendInfo.remarkName.length > 0)
            self.nameLabel.text = self.friendInfo.remarkName;
        else if(self.friendInfo.nickName && self.friendInfo.nickName.length > 0)
            self.nameLabel.text = self.friendInfo.nickName;
    }
}

- (void)onCallEvents:(NSNotification *)noti{
    VoIPCall* voipCall = noti.object;
    if (![self.callId isEqualToString:voipCall.callID]) {
        return;
    }
    switch (voipCall.callStatus) {
        case ECallProceeding:
            self.statusLabel.text = NSLocalizedString(@"连接中...", nil);
            break;
        case ECallAlerting:
            self.statusLabel.text = NSLocalizedString(@"等待对方接听...", nil);
            break;
        case ECallStreaming:
            [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:YES];
            self.statusLabel.text = @"00:00";
            self.second = 0;
            self.status = 2;
            [self.timer setFireDate:[NSDate distantPast]];
            break;
            
        case ECallFailed:
            if( voipCall.reason == ECErrorType_NoResponse) {
                self.statusLabel.text = NSLocalizedString(@"网络不给力", nil);
            } else if ( voipCall.reason == ECErrorType_CallBusy || voipCall.reason == ECErrorType_Declined ) {
                self.statusLabel.text = NSLocalizedString(@"您拨叫的用户正忙，请稍后再拨", nil);
            } else if ( voipCall.reason == ECErrorType_OtherSideOffline) {
                self.statusLabel.text = NSLocalizedString(@"对方不在线", nil);
            } else if ( voipCall.reason == ECErrorType_CallMissed ) {
                self.statusLabel.text = NSLocalizedString(@"呼叫超时", nil);
            } else if ( voipCall.reason == ECErrorType_SDKUnSupport) {
                self.statusLabel.text = NSLocalizedString(@"该版本不支持此功能", nil);
            } else if ( voipCall.reason == ECErrorType_CalleeSDKUnSupport ) {
                self.statusLabel.text = NSLocalizedString(@"对方版本不支持音频", nil);
            } else {
                self.statusLabel.text = NSLocalizedString(@"呼叫失败", nil);
            }
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(hangUpAction) userInfo:nil repeats:NO];
            break;
        case ECallEnd:
            [self.timer setFireDate:[NSDate distantFuture]];
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(hangUpAction) userInfo:nil repeats:NO];
            break;
        default:
            break;
    }
}

- (void)setStatus:(NSInteger)status{
    _status = status;
    self.localView.hidden = (status == 1);
    self.rejectView.hidden = (status != 1);
    self.answerView.hidden = (status != 1);
    self.beautyView.hidden = (status == 1);
    self.hangUpView.hidden = (status == 1);
    self.cameraView.hidden = (status == 1);
    self.quietView.hidden = (status == 1);
    self.speakerView.hidden = (status == 1);
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
    self.statusLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", min, sec];
}

#pragma mark - 免提、静音等操作
- (void)quietAction{
    BOOL isQuiet = [[ECDevice sharedInstance].VoIPManager getMuteStatus];
    [[ECDevice sharedInstance].VoIPManager setMute:!isQuiet];
    self.quietView.imageName = (!isQuiet ? @"yuyinliaotianIconJingyinHigh" : @"shipinliaotianIconJingyinNormal");
}

- (void)speakerAction{
    BOOL isSpeaker = [[ECDevice sharedInstance].VoIPManager getLoudsSpeakerStatus];
    [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:!isSpeaker];
    self.speakerView.imageName = (!isSpeaker ? @"yuyinliaotianIconMiantiHigh": @"shipinliaotianIconMiantiNormal");
}

- (void)beautyAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    [[ECDevice sharedInstance].VoIPManager enableBeautyFilter:sender.selected];
    self.beautyView.imageName = (sender.selected ? @"meiyan": @"shipinliaotianIconMeiyanNormal");
}

- (void)hangUpAction{
    if(_timer){
        [_timer invalidate];
        _timer = nil;
    }
    [ECDeviceDelegateHelper sharedInstanced].isCallBusy = NO;
    [[ECDevice sharedInstance].VoIPManager releaseCall:self.callId];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)rejectAction{
    [self hangUpAction];
}

- (void)answerAction{
    [[ECDevice sharedInstance].VoIPManager acceptCall:self.callId withType:VIDEO];
    self.status = 2;
}

- (void)switchCameraAction{
    [[ECDeviceVoipHelper sharedInstanced] selectCamera:self.currentCameraIndex];
    self.currentCameraIndex++;
    if(self.currentCameraIndex >= [ECDeviceVoipHelper sharedInstanced].cameraInfoArray.count)
        self.currentCameraIndex = 0;
}

- (void)switchCameraAction:(UIButton *)sender{
//    [self switchCameraAction];
    [[ECDevice sharedInstance].VoIPManager setLocalCameraOfCallId:self.callId andEnable:sender.selected];
    sender.selected = !sender.selected;
    self.cameraView.imageName = (sender.selected ? @"shipinliaotianIconShexiangNormal" : @"shexiangtou");
}

- (void)switchVideoViewAction{
    static BOOL currentStatus = YES;
    if(currentStatus)
        [[ECDevice sharedInstance].VoIPManager resetVideoView:self.localView andLocalView:self.remoteVIew ofCallId:self.callId];
    else
        [[ECDevice sharedInstance].VoIPManager resetVideoView:self.remoteVIew andLocalView:self.localView ofCallId:self.callId];
    currentStatus = !currentStatus;
}

- (void)packupAction{
    UIView *currentMinView = self.localView;
    UIBezierPath *endPath = [UIBezierPath bezierPathWithRect:currentMinView.frame];
    CGFloat radius = MAX(self.ec_height - currentMinView.center.y, currentMinView.center.y);
    CGRect startRect = CGRectInset(currentMinView.frame, -radius, -radius);
    UIBezierPath *startPath = [UIBezierPath bezierPathWithRect:startRect];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = endPath.CGPath;
    self.layer.mask = shapeLayer;
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
    UIView *tmpView = self.localView;
    [self.openView removeFromSuperview];
    self.openView = nil;
    self.bounds = [UIScreen mainScreen].bounds;
    self.frame = self.bounds;
    CAShapeLayer *shapeLayer = self.shapeLayer;
    UIBezierPath *startPath = [UIBezierPath bezierPathWithRect:tmpView.frame];
    CGFloat radius = MAX(self.ec_height - tmpView.center.y, tmpView.center.y);
    CGRect endRect = CGRectInset(tmpView.frame, -radius, -radius);
    UIBezierPath *endPath = [UIBezierPath bezierPathWithRect:endRect];
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
}

#pragma mark - Animation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    UIView *currentMinView = self.localView;
    if ([anim isEqual:[self.shapeLayer animationForKey:@"packupAnimation"]]) {
        CGRect rect = self.frame;
        rect.origin = currentMinView.frame.origin;
        self.bounds = rect;
        rect.size = currentMinView.frame.size;
        self.frame = rect;
        [self.superview addSubview:self.openView];
    }else if ([anim isEqual:[self.shapeLayer animationForKey:@"openAnimation"]]) {
        self.layer.mask = nil;
        self.shapeLayer = nil;
    }
}

#pragma mark - UI创建
- (void)buildUI{
    self.backgroundColor = [UIColor colorWithPatternImage:EC_Image_Named(@"background")];
    [self addSubview:self.remoteVIew];
    [self addSubview:self.localView];
    [self addSubview:self.packUpBtn];
    [self addSubview:self.switchCamnerBtn];
    [self addSubview:self.nameLabel];
    [self addSubview:self.statusLabel];
    [self addSubview:self.quietView];
    [self addSubview:self.cameraView];
    [self addSubview:self.speakerView];
    [self addSubview:self.beautyView];
    [self addSubview:self.hangUpView];
    [self addSubview:self.rejectView];
    [self addSubview:self.answerView];
    EC_WS(self)
    [self.packUpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(22);
        make.top.equalTo(weakSelf).offset(32);
    }];
    [self.switchCamnerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf).offset(-22);
        make.top.equalTo(weakSelf).offset(32);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.packUpBtn.mas_left);
        make.top.equalTo(weakSelf.packUpBtn.mas_bottom).offset(10);
    }];

    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.nameLabel.mas_left);
        make.top.equalTo(weakSelf.nameLabel.mas_bottom).offset(10);
    }];

    NSArray *operationViews = @[self.quietView, self.cameraView, self.speakerView, self.beautyView];
    [operationViews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:35 leadSpacing:20 tailSpacing:20];
    [operationViews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf).offset(-120);
        make.height.offset(85);
    }];
    [self.hangUpView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.mas_centerX);
        make.height.width.offset(85);
        make.bottom.equalTo(weakSelf);
    }];
    NSArray *incomingOperationViews = @[self.rejectView, self.answerView];
    [incomingOperationViews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:46 leadSpacing:70 tailSpacing:70];
    [incomingOperationViews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf).offset(-10);
        make.height.offset(85);
    }];
}

- (UIView *)remoteVIew{
    if(!_remoteVIew){
        _remoteVIew = [[UIView alloc] initWithFrame:self.bounds];
        _remoteVIew.backgroundColor = [UIColor colorWithPatternImage:EC_Image_Named(@"background")];
    }
    return _remoteVIew;
}

- (ECCallOpenView *)localView{
    if(!_localView){
        _localView = [[ECCallOpenView alloc] initWithFrame:CGRectMake(0, (self.ec_height - EC_LocalViewH) / 2, EC_LocalViewW, EC_LocalViewH)];
        _localView.backgroundColor = EC_Color_Clear;
        _localView.callType = VIDEO;
        EC_WS(self)
        _localView.touchMoveEnd = ^(CGFloat x, CGFloat y){
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.localView.frame = CGRectMake(x, y, weakSelf.localView.ec_width, weakSelf.localView.ec_height);
            }];
        };
        _localView.userInteractionEnabled = YES;
        UITapGestureRecognizer *switchViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchVideoViewAction)];
        [_localView addGestureRecognizer:switchViewTap];
    }
    return _localView;
}

- (UIButton *)packUpBtn{
    if(!_packUpBtn){
        _packUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_packUpBtn setImage:EC_Image_Named(@"yuyinliaotianIconSuoxiao") forState:UIControlStateNormal];
        [_packUpBtn addTarget:self action:@selector(packupAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _packUpBtn;
}

- (UIButton *)switchCamnerBtn{
    if(!_switchCamnerBtn){
        _switchCamnerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchCamnerBtn setImage:EC_Image_Named(@"cameraFanzhuan") forState:UIControlStateNormal];
        [_switchCamnerBtn addTarget:self action:@selector(switchCameraAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCamnerBtn;
}

- (UILabel *)nameLabel{
    if(!_nameLabel){
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = EC_Color_White;
        _nameLabel.font = EC_Font_SystemBold(21);
        _nameLabel.text = self.callNumber;
    }
    return _nameLabel;
}

- (UILabel *)statusLabel{
    if(!_statusLabel){
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.textColor = EC_Color_White;
        _statusLabel.font = EC_Font_System(16);
        _statusLabel.text = self.callNumber;
        _statusLabel.text = @"";
    }
    return _statusLabel;
}

- (ECCallOperationView *)quietView{
    if(!_quietView){
        _quietView = [[ECCallOperationView alloc] initWithImage:@"shipinliaotianIconJingyinNormal" title:NSLocalizedString(@"静音", nil)];
        _quietView.textColor = EC_Color_White;
        [_quietView addTarget:self action:@selector(quietAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _quietView;
}

- (ECCallOperationView *)cameraView{
    if(!_cameraView){
        _cameraView = [[ECCallOperationView alloc] initWithImage:@"shexiangtou" title:NSLocalizedString(@"摄像头", nil)];
        _cameraView.textColor = EC_Color_White;
        [_cameraView addTarget:self action:@selector(switchCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraView;
}

- (ECCallOperationView *)speakerView{
    if(!_speakerView){
        _speakerView = [[ECCallOperationView alloc] initWithImage:@"yuyinliaotianIconMiantiHigh" title:NSLocalizedString(@"免提", nil)];
        _speakerView.textColor = EC_Color_White;
        [_speakerView addTarget:self action:@selector(speakerAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speakerView;
}

- (ECCallOperationView *)beautyView{
    if(!_beautyView){
        _beautyView = [[ECCallOperationView alloc] initWithImage:@"shipinliaotianIconMeiyanNormal" title:NSLocalizedString(@"美颜", nil)];
        _beautyView.textColor = EC_Color_White;
        [_beautyView addTarget:self action:@selector(beautyAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beautyView;
}

- (ECCallOperationView *)hangUpView{
    if(!_hangUpView){
        _hangUpView = [[ECCallOperationView alloc] initWithImage:@"yuyinliaotianIconGuaduanNormal" title:NSLocalizedString(@"", nil)];
        _hangUpView.textColor = EC_Color_White;
        [_hangUpView addTarget:self action:@selector(hangUpAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hangUpView;
}

- (ECCallOpenView *)openView{
    if(!_openView){
        _openView = [[ECCallOpenView alloc] initWithFrame:self.frame];
        _openView.userInteractionEnabled = YES;
        _openView.backgroundColor = EC_Color_Clear;
        _openView.callType = VIDEO;
        EC_WS(self)
        _openView.touchMove = ^(CGRect frame){
            weakSelf.frame = frame;
        };
        _openView.touchMoveEnd = ^(CGFloat x, CGFloat y){
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.frame = CGRectMake(x, y, weakSelf.ec_width, weakSelf.ec_height);
                weakSelf.openView.frame = CGRectMake(x, y, weakSelf.ec_width, weakSelf.ec_height);
            }];
        };
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openAction)];
        [_openView addGestureRecognizer:tap];
    }
    return _openView;
}

- (ECCallOperationView *)rejectView{
    if(!_rejectView){
        _rejectView = [[ECCallOperationView alloc] initWithImage:@"yuyinliaotianIconGuaduanNormal" title:NSLocalizedString(@"拒绝", nil)];
        _rejectView.textColor = EC_Color_VoiceCall_Text_Gray;
        [_rejectView addTarget:self action:@selector(rejectAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rejectView;
}

- (ECCallOperationView *)answerView{
    if(!_answerView){
        _answerView = [[ECCallOperationView alloc] initWithImage:@"yuyinliaotianIconMiantiNormal" title:NSLocalizedString(@"接听", nil)];
        _answerView.textColor = EC_Color_VoiceCall_Text_Gray;
        [_answerView addTarget:self action:@selector(answerAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _answerView;
}

@end
