//
//  ECCallVoiceView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/9.
//
//

#import "ECCallVoiceView.h"
#import "ECCallOperationView.h"
#import "ECCallOpenView.h"
#import "ECFriendManager.h"
#import "YSCVoiceWaveView.h"
#import <AVFoundation/AVFoundation.h>

#define EC_CallVoice_HeadSize (EC_kScreenW / 375 * 158)
#define EC_CallHead_Margin (EC_kScreenW / 375 * 100)

@interface ECCallVoiceView ()<CAAnimationDelegate>

@property (nonatomic, strong) ECCallOperationView *quietView;
@property (nonatomic, strong) ECCallOperationView *hangUpView;
@property (nonatomic, strong) ECCallOperationView *speakerView;
@property (nonatomic, strong) ECCallOperationView *rejectView;
@property (nonatomic, strong) ECCallOperationView *answerView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIButton *packUpBtn;
@property (nonatomic, strong) UIImageView *headImage;

@property (nonatomic, strong) ECCallOpenView *openView;

@property (strong, nonatomic) CAShapeLayer *shapeLayer;

@property (nonatomic, strong) NSTimer *timer;//通话接通开启计时器
@property (nonatomic, assign) NSInteger second;//通话时间

@property (nonatomic, strong) YSCVoiceWaveView *voiceWaveView;
@property (nonatomic,strong) UIView *voiceWaveParentView;

@end

@implementation ECCallVoiceView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = EC_Color_VCbg;
        self.alpha = 0;
        [self buildUI];
    }
    return self;
}

- (void)show{
    self.second = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCallEvents:) name:EC_KNOTIFICATION_Voip_ReceiveCallEvents object:nil];
    [[AppDelegate sharedInstanced].window addSubview:self];
    if(!self.isIncomingCall){
        self.callId = [[ECDevice sharedInstance].VoIPManager makeCallWithType:VOICE andCalled:self.callNumber];
        [self.voiceWaveView startVoiceWave];
        [_voiceWaveView changeVolume:0.5];
    }else{
        self.statusLabel.text = NSLocalizedString(@"连接中...", nil);
    }
    self.nameLabel.text = self.callNumber;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [self fetchFriendInfo];
    }];
}

#pragma mark - 获取好友数据
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
        [self.headImage sd_setImageWithURL:[NSURL URLWithString:self.friendInfo.avatar] placeholderImage:EC_Image_Named(@"yuyinliaotianHeaderDefault")];
        if(self.friendInfo.remarkName && self.friendInfo != nil && self.friendInfo.remarkName.length > 0)
            self.nameLabel.text = self.friendInfo.remarkName;
        else if(self.friendInfo.nickName && self.friendInfo.nickName.length > 0)
            self.nameLabel.text = self.friendInfo.nickName;
    }
}

- (void)setIsIncomingCall:(BOOL)isIncomingCall{
    _isIncomingCall = isIncomingCall;
    if(isIncomingCall){
        self.answerView.hidden = NO;
        self.rejectView.hidden = NO;
        self.quietView.hidden = YES;
        self.hangUpView.hidden = YES;
        self.speakerView.hidden = YES;
    }
}

- (void)onCallEvents:(NSNotification *)noti{
    VoIPCall* voipCall = noti.object;
    if (![self.callId isEqualToString:voipCall.callID]) {
        return;
    }
    switch (voipCall.callStatus) {
        case ECallProceeding:
            self.statusLabel.text = NSLocalizedString(@"呼叫中...", nil);
            break;
        case ECallAlerting:
            self.statusLabel.text = NSLocalizedString(@"等待对方接听", nil);
            break;
        case ECallStreaming: {
            self.answerView.hidden = YES;
            self.rejectView.hidden = YES;
            self.quietView.hidden = NO;
            self.hangUpView.hidden = NO;
            self.speakerView.hidden = NO;
            self.statusLabel.text = @"00:00";
            self.second = 0;
            [self.timer setFireDate:[NSDate distantPast]];
            [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:YES];
            [self.voiceWaveView stopVoiceWaveWithShowLoadingViewCallback:nil];
        }
            break;
        case ECallFailed: {
            [self.voiceWaveView stopVoiceWaveWithShowLoadingViewCallback:nil];
            [self performSelector:@selector(hangUpAction) withObject:nil afterDelay:1];
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
        }
            break;
        case ECallEnd:
            [self.voiceWaveView stopVoiceWaveWithShowLoadingViewCallback:nil];
            self.statusLabel.text = NSLocalizedString(@"正在挂机...", nil);
            [self.timer setFireDate:[NSDate distantFuture]];
            [self.timer invalidate];
            self.timer = nil;
            self.second = 0;
            [self performSelector:@selector(hangUpAction) withObject:nil afterDelay:1];
            break;
        case ECallTransfered:
            [self.timer setFireDate:[NSDate distantFuture]];
            [self performSelector:@selector(hangUpAction) withObject:nil afterDelay:1];
            self.statusLabel.text = NSLocalizedString(@"呼叫被转移...", nil);
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
    self.statusLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", min, sec];
    if(_openView)
        [self.openView time:self.second];
}

#pragma mark - 缩小、放大动画
- (void)packupAction{
    UIBezierPath *endPath = [UIBezierPath bezierPathWithOvalInRect:self.headImage.frame];
    CGFloat radius = self.ec_height - self.headImage.center.y;
    CGRect startRect = CGRectInset(self.headImage.frame, -radius, -radius);
    UIBezierPath *startPath = [UIBezierPath bezierPathWithOvalInRect:startRect];
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
    [self.openView removeFromSuperview];
    self.openView = nil;
    [UIView animateWithDuration:1.0 animations:^{
        self.center = self.headImage.center;
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.bounds = [UIScreen mainScreen].bounds;
        self.frame = self.bounds;
        CAShapeLayer *shapeLayer = self.shapeLayer;
        UIBezierPath *startPath = [UIBezierPath bezierPathWithOvalInRect:self.headImage.frame];
        CGFloat radius = self.ec_height - self.headImage.center.y;
        CGRect endRect = CGRectInset(self.headImage.frame, -radius, -radius);
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

#pragma mark - 接听、挂断、静音、扬声器
- (void)quietAction{
    BOOL isQuiet = [[ECDevice sharedInstance].VoIPManager getMuteStatus];
    [[ECDevice sharedInstance].VoIPManager setMute:!isQuiet];
    self.quietView.imageName = (!isQuiet ? @"yuyinliaotianIconJingyinHigh" : @"yuyinliaotianIconJingyinNormal");
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
        if(_openView)
            [self.openView removeFromSuperview];
        [self removeFromSuperview];
        [_voiceWaveView removeFromParent];
        _voiceWaveView = nil;
    }];
}

- (void)speakerAction{
    BOOL isSpeaker = [[ECDevice sharedInstance].VoIPManager getLoudsSpeakerStatus];
    [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:!isSpeaker];
    self.speakerView.imageName = (!isSpeaker ? @"yuyinliaotianIconMiantiHigh": @"yuyinliaotianIconMiantiNormal");
}

- (void)rejectAction{
    [self hangUpAction];
}

- (void)answerAction{
    [[ECDevice sharedInstance].VoIPManager acceptCall:self.callId withType:VOICE];
}

#pragma mark - animation delegate,通话结束处理
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if ([anim isEqual:[self.shapeLayer animationForKey:@"packupAnimation"]]) {
        CGRect rect = self.frame;
        rect.origin = self.headImage.frame.origin;
        self.bounds = rect;
        rect.size = self.headImage.frame.size;
        self.frame = rect;
        [UIView animateWithDuration:0.5 animations:^{
            self.center = CGPointMake(EC_kScreenW - self.ec_width / 2 / 2, self.center.y);
            self.transform = CGAffineTransformMakeScale(0.5, 0.5);
        } completion:^(BOOL finished) {
            [self.superview addSubview:self.openView];
        }];
    }else if ([anim isEqual:[self.shapeLayer animationForKey:@"openAnimation"]]) {
        self.layer.mask = nil;
        self.shapeLayer = nil;
    }
}

#pragma mark - UI创建
- (void)buildUI{
    self.backgroundColor = [UIColor colorWithPatternImage:EC_Image_Named(@"background")];
    [self addSubview:self.packUpBtn];
    [self addSubview:self.headImage];
    [self addSubview:self.quietView];
    [self addSubview:self.hangUpView];
    [self addSubview:self.speakerView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.statusLabel];
    [self addSubview:self.rejectView];
    [self addSubview:self.answerView];
    [self addSubview:self.voiceWaveParentView];
    [self.voiceWaveView showInParentView:self.voiceWaveParentView];
    self.rejectView.hidden = YES;
    self.answerView.hidden = YES;
    EC_WS(self)
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.top.equalTo(weakSelf.headImage.mas_bottom).offset(20);
    }];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.top.equalTo(weakSelf.nameLabel.mas_bottom).offset(10);
    }];
    
    [self.packUpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(22);
        make.top.equalTo(weakSelf).offset(32);
    }];
    NSArray *operationViews = @[self.quietView, self.hangUpView, self.speakerView];
    [operationViews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:46 leadSpacing:56 tailSpacing:56];
    [operationViews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf).offset(-30);
        make.height.offset(85);
    }];
    NSArray *incomingOperationViews = @[self.rejectView, self.answerView];
    [incomingOperationViews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:46 leadSpacing:70 tailSpacing:70];
    [incomingOperationViews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf).offset(-30);
        make.height.offset(85);
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

- (UIImageView *)headImage{
    if(!_headImage){
        _headImage = [[UIImageView alloc] initWithFrame:CGRectMake((EC_kScreenW - EC_CallVoice_HeadSize) / 2, EC_CallHead_Margin, EC_CallVoice_HeadSize, EC_CallVoice_HeadSize)];
        _headImage.ec_radius = EC_CallVoice_HeadSize / 2;
        _headImage.image = EC_Image_Named(@"yuyinliaotianHeaderDefault");
    }
    return _headImage;
}

- (ECCallOperationView *)quietView{
    if(!_quietView){
        _quietView = [[ECCallOperationView alloc] initWithImage:@"yuyinliaotianIconJingyinNormal" title:NSLocalizedString(@"静音", nil)];
        _quietView.textColor = EC_Color_VoiceCall_Text_Gray;
        [_quietView addTarget:self action:@selector(quietAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _quietView;
}

- (ECCallOperationView *)hangUpView{
    if(!_hangUpView){
        _hangUpView = [[ECCallOperationView alloc] initWithImage:@"yuyinliaotianIconGuaduanNormal" title:NSLocalizedString(@"挂断", nil)];
        _hangUpView.textColor = EC_Color_VoiceCall_Text_Gray;
        [_hangUpView addTarget:self action:@selector(hangUpAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hangUpView;
}

- (ECCallOperationView *)speakerView{
    if(!_speakerView){
        _speakerView = [[ECCallOperationView alloc] initWithImage:@"yuyinliaotianIconMiantiHigh" title:NSLocalizedString(@"免提", nil)];
        _speakerView.textColor = EC_Color_VoiceCall_Text_Gray;
        [_speakerView addTarget:self action:@selector(speakerAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speakerView;
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

- (UILabel *)nameLabel{
    if(!_nameLabel){
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = EC_Color_VoiceCall_Text_Gray;
        _nameLabel.font = EC_Font_SystemBold(21);
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.text = self.callNumber;
        [_nameLabel sizeToFit];
    }
    return _nameLabel;
}

- (UILabel *)statusLabel{
    if(!_statusLabel){
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.textColor = EC_Color_VoiceCall_Text_Gray;
        _statusLabel.font = EC_Font_System(16);
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.text = @"等待接听";
    }
    return _statusLabel;
}

- (ECCallOpenView *)openView{
    if(!_openView){
        _openView = [[ECCallOpenView alloc] initWithFrame:self.frame];
        _openView.userInteractionEnabled = YES;
        _openView.backgroundColor = [UIColor colorWithHex:0x12b7f5];
        _openView.ec_radius = self.ec_width / 2;
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

- (YSCVoiceWaveView *)voiceWaveView{
    if (!_voiceWaveView) {
        self.voiceWaveView = [[YSCVoiceWaveView alloc] init];
    }
    return _voiceWaveView;
}

- (UIView *)voiceWaveParentView{
    if (!_voiceWaveParentView) {
        self.voiceWaveParentView = [[UIView alloc] init];
        _voiceWaveParentView.frame = CGRectMake(-100, EC_kScreenH - 180, EC_kScreenW + 200, 50);
        _voiceWaveParentView.backgroundColor = EC_Color_Clear;
    }
    return _voiceWaveParentView;
}

@end
