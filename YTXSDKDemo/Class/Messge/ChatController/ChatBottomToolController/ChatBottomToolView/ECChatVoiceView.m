//
//  ECChatVoiceView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/2.
//
//

#import "ECChatVoiceView.h"
#import "ECChatVoiceItemView.h"
#import "ECChatVoiceBottomView.h"
#import "ECVoiceChangeView.h"
#import <AVFoundation/AVFoundation.h>

#define EC_Voice_SrollViewH 160

@interface ECChatVoiceView()<UIScrollViewDelegate, ECChatBottomViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) ECChatVoiceBottomView *bottomView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) ECVoiceChangeView *voiceChangeView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) ECChatVoiceItemView *currentVoiceView;
@property (nonatomic, assign) NSInteger recordTime;

@property (nonatomic, assign) BOOL isDragOut;

@end

@implementation ECChatVoiceView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self buildUI];
    }
    return self;
}

- (NSTimer *)timer{
    if(!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startTimer) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}

- (void)startTimer{
    self.recordTime++;
    if (self.recordTime == 60) {
        [self.timer invalidate];
        self.timer = nil;
        return;
    }
    if(self.isDragOut)
        return;
    NSInteger sec = self.recordTime % 60;
    NSInteger min = self.recordTime / 60;
    self.currentVoiceView.title = [NSString stringWithFormat:@"%02ld:%02ld", min, sec];
}

- (void)startRecord{
    self.recordTime = 0;
    [self.timer setFireDate:[NSDate distantPast]];
}

- (void)endRecord{
    self.timer.fireDate = [NSDate distantFuture];
}

#pragma mark - 录音
- (void)recordTouchDownAction:(UIButton *)sender{
    BOOL success = [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
    EC_Demo_AppLog(@"success = %d", success);
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    ECChatVoiceItemView *itemView = (ECChatVoiceItemView *)sender.superview;
    self.currentVoiceView = itemView;
    if(itemView.voiceType == ECChatVoiceType_Normal){
        [itemView showHelperView];
    }
    NSString *currentDateStr = [NSString sigTime:[NSDate date]];
    NSString *file = [NSString stringWithFormat:@"tmp%@.amr", currentDateStr];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:file];
    ECVoiceMessageBody * messageBody = [[ECVoiceMessageBody alloc] initWithFile:path displayName:file];
    [self startRecord];
    [[ECDeviceHelper sharedInstanced]  ec_sendUserState:ECUserInputState_Record to:self.receiver];
    [[ECDevice sharedInstance].messageManager startVoiceRecording:messageBody error:^(ECError *error, ECVoiceMessageBody *messageBody) {
        EC_Demo_AppLog(@"start ,,,%ld====%@", error.errorCode, error.errorDescription);
        if(error.errorCode == ECErrorType_RecordTimeOut) {
            if(itemView.voiceType == ECChatVoiceType_Normal){
                [ECCommonTool toast:NSLocalizedString(@"录音时间超过60s,自动发送", nil)];
                [[ECDeviceHelper sharedInstanced] ec_sendMessage:messageBody to:self.receiver];
            }else if (itemView.voiceType == ECChatVoiceType_Change){
                self.voiceChangeView.messageBody = messageBody;
                self.voiceChangeView.receiver = self.receiver;
                [self addSubview:self.voiceChangeView];
            }
        }
    }];
}

- (void)recordTouchUpInsideAction:(UIButton *)sender{
    [self endRecord];
    ECChatVoiceItemView *itemView = (ECChatVoiceItemView *)sender.superview;
    if(itemView.voiceType == ECChatVoiceType_Normal){
        [itemView hiddenHelperView];
    }
    [[ECDeviceHelper sharedInstanced]  ec_sendUserState:ECUserInputState_None to:self.receiver];
    [[ECDevice sharedInstance].messageManager stopVoiceRecording:^(ECError *error, ECVoiceMessageBody *messageBody) {
        if(error.errorCode == ECErrorType_NoError){
            if(itemView.voiceType == ECChatVoiceType_Change){
                self.voiceChangeView.messageBody = messageBody;
                self.voiceChangeView.receiver = self.receiver;
                [self addSubview:self.voiceChangeView];
            }else if (itemView.voiceType == ECChatVoiceType_Normal){
                [[ECDeviceHelper sharedInstanced] ec_sendMessage:messageBody to:self.receiver];
            }
        } else if  (error.errorCode == ECErrorType_RecordTimeTooShort) {
            [ECCommonTool toast:NSLocalizedString(@"录音时间过短", nil)];
        }
    }];
    itemView.title = (itemView.voiceType == ECChatVoiceType_Normal ? NSLocalizedString(@"按住说话",nil) : NSLocalizedString(@"按住变声",nil));
}

- (void)recordTouchUpOutsideAction:(UIButton *)sender{
    [self endRecord];
    ECChatVoiceItemView *itemView = (ECChatVoiceItemView *)sender.superview;
    if(itemView.voiceType == ECChatVoiceType_Normal){
        [itemView hiddenHelperView];
    }
    [[ECDeviceHelper sharedInstanced]  ec_sendUserState:ECUserInputState_None to:self.receiver];
    itemView.title = (itemView.voiceType == ECChatVoiceType_Normal ? NSLocalizedString(@"按住说话",nil) : NSLocalizedString(@"按住变声",nil));
    [[ECDevice sharedInstance].messageManager stopVoiceRecording:^(ECError *error, ECVoiceMessageBody *messageBody) {
    }];
}

- (void)recordTouchDragOutAction:(UIButton *)sender{
    self.isDragOut = YES;
    self.currentVoiceView.title = @"松开取消";
}

- (void)recordTouchDragInAction:(UIButton *)sender{
    self.isDragOut = NO;
}

#pragma mark - ECChatBottomeView delegate
- (void)selectVoiceType:(ECChatVoiceType)type{
    [UIView animateWithDuration:0.2 animations:^{
        self.scrollView.contentOffset = CGPointMake(EC_kScreenW * (int)type, 0);
    }];
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scale = EC_VoiceBtom_W / scrollView.ec_width;
    self.bottomView.ec_x =  (EC_kScreenW - EC_VoiceBtom_W) / 2 - scrollView.contentOffset.x * scale;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.bottomView.voiceType = (scrollView.contentOffset.x / scrollView.ec_width ? ECChatVoiceType_Change : ECChatVoiceType_Normal);
}

#pragma mark - UI创建
- (void)buildUI{
    [self addSubview:self.scrollView];
    [self configVoiceView];
    [self addSubview:self.pageControl];
    [self addSubview:self.bottomView];
}

- (UIScrollView *)scrollView{
    if(!_scrollView){
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, EC_Voice_SrollViewH)];
        _scrollView.pagingEnabled = YES;
        _scrollView.backgroundColor = EC_Color_White;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (void)configVoiceView{
    NSArray *titles = @[NSLocalizedString(@"按住说话",nil), NSLocalizedString(@"按住变声",nil)];
    NSArray *images = @[@"chatYuyinIconDuijiangNormal", @"chatYuyinIconBianshengNormal"];
    NSArray *selectimages = @[@"chatYuyinIconDuijiangHigh", @"chatYuyinIconBianshengHigh"];
    for (int i = 0; i < 2; i++) {
        ECChatVoiceItemView *itemView = [[ECChatVoiceItemView alloc] initWithFrame:CGRectMake(EC_kScreenW * i, 0, EC_kScreenW, EC_Voice_SrollViewH)];
        itemView.title = titles[i];
        itemView.voiceType = (i == 0 ? ECChatVoiceType_Normal : ECChatVoiceType_Change);
        itemView.imageName = images[i];
        itemView.selectImageName = selectimages[i];
        [itemView addTarget:self action:@selector(recordTouchDownAction:) forControlEvents:UIControlEventTouchDown];
        [itemView addTarget:self action:@selector(recordTouchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
        [itemView addTarget:self action:@selector(recordTouchUpOutsideAction:) forControlEvents:UIControlEventTouchUpOutside];
        [itemView addTarget:self action:@selector(recordTouchDragOutAction:) forControlEvents:UIControlEventTouchDragOutside];
        [itemView addTarget:self action:@selector(recordTouchDragInAction:) forControlEvents:UIControlEventTouchDragInside];
        [self.scrollView addSubview:itemView];
        if(i == 0) self.currentVoiceView = itemView;
    }
    self.scrollView.contentSize = CGSizeMake(EC_kScreenW * 2, self.scrollView.ec_height);
}

- (UIPageControl *)pageControl{
    if(!_pageControl){
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView.frame) + 10, EC_kScreenW, 10)];
        [self addSubview:pageControl];
        _pageControl = pageControl;
        _pageControl.numberOfPages = 1;
        _pageControl.currentPage = 0;
        _pageControl.currentPageIndicatorTintColor = EC_Color_App_Main;
    }
    return _pageControl;
}

- (ECChatVoiceBottomView *)bottomView{
    if(!_bottomView){
        _bottomView = [[ECChatVoiceBottomView alloc] initWithFrame:CGRectMake((EC_kScreenW - EC_VoiceBtom_W) / 2, CGRectGetMaxY(self.pageControl.frame) + 10, EC_VoiceBtom_W * 2, EC_VoiceBtom_H)];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

- (ECVoiceChangeView *)voiceChangeView{
    if(!_voiceChangeView){
        _voiceChangeView = [[ECVoiceChangeView alloc] initWithFrame:self.bounds];
    }
    return _voiceChangeView;
}

- (void)dealloc{
    if(_timer){
        [self.timer invalidate];
        self.timer = nil;
    }
}
@end
