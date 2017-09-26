//
//  ECRecordShortVideoVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/2.
//
//

#import "ECRecordShortVideoVC.h"
#import "PKShortVideoRecorder.h"
#import "PKShortVideoProgressBar.h"
#import <AVFoundation/AVFoundation.h>
#import "PKFullScreenPlayerViewController.h"
#import "UIImage+PKShortVideoPlayer.h"

#define EC_ShortVideo_BtnW 84
#define EC_ShortVideo_BtnH 84
#define EC_ShortVideo_BottomH 118

@interface ECRecordShortVideoVC() <PKShortVideoRecorderDelegate>

@property (nonatomic, strong) NSString *outputFilePath;
@property (nonatomic, assign) CGSize outputSize;

@property (nonatomic, strong) UIColor *themeColor;

@property (strong, nonatomic) NSTimer *stopRecordTimer;
@property (nonatomic, assign) CFAbsoluteTime beginRecordTime;

@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, strong) PKShortVideoProgressBar *progressBar;
@property (nonatomic, strong) PKShortVideoRecorder *recorder;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, assign) NSInteger seconds;

@end

@implementation ECRecordShortVideoVC

#pragma mark - Init

- (instancetype)initWithOutputFilePath:(NSString *)outputFilePath outputSize:(CGSize)outputSize themeColor:(UIColor *)themeColor {
    self = [super init];
    if (self) {
        _themeColor = themeColor;
        _outputFilePath = outputFilePath;
        _outputSize = outputSize;
        _videoMaximumDuration = 10;
        _videoMinimumDuration = 1;
    }
    return self;
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildUI];
    [self.recorder startRunning];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
}

#pragma mark - Private
- (void)cancelShoot {
    [self.recorder stopRunning];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)swapCamera {
    [self.recorder swapFrontAndBackCameras];
}

- (void)recordButtonAction {
    [self.recordButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    [self.recordButton addTarget:self action:@selector(toggleRecording) forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(buttonStopRecording) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
}

- (void)sendButtonAction  {
    [self.sendButton addTarget:self action:@selector(sendVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
}

- (void)refreshView {
    [[NSFileManager defaultManager] removeItemAtPath:self.outputFilePath error:nil];
    
    [self recordButtonAction ];
    [self.playButton removeFromSuperview];
    self.playButton = nil;
    [self.sendButton removeFromSuperview];
    self.sendButton = nil;
    
    [self.progressBar restore];
}

- (void)playVideo {
    UIImage *image = [UIImage pk_previewImageWithVideoURL:[NSURL fileURLWithPath:self.outputFilePath]];
    PKFullScreenPlayerViewController *vc = [[PKFullScreenPlayerViewController alloc] initWithVideoPath:self.outputFilePath previewImage:image];
    [self presentViewController:vc animated:NO completion:NULL];
}

- (void)toggleRecording {
    //静止自动锁屏
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    //记录开始录制时间
    self.beginRecordTime = CACurrentMediaTime();
    //开始录制视频
    [self.recorder startRecording];
    //进度条开始动
    [self.progressBar play];
}

- (void)buttonStopRecording {
    //停止录制
    [self.recorder stopRecording];
}

- (void)sendVideo {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate didFinishRecordingToOutputFilePath:self.outputFilePath];
    }];
}

- (void)endRecordingWithPath:(NSString *)path failture:(BOOL)failture {
}

+ (void)showAlertViewWithText:(NSString *)text {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"录制小视频失败" message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

- (void)invalidateTime {
    if ([self.stopRecordTimer isValid]) {
        [self.stopRecordTimer invalidate];
        self.stopRecordTimer = nil;
    }
}

#pragma mark - PKShortVideoRecorderDelegate
///录制开始回调
- (void)recorderDidBeginRecording:(PKShortVideoRecorder *)recorder {
    //录制长度限制到时间停止
    self.stopRecordTimer = [NSTimer scheduledTimerWithTimeInterval:self.videoMinimumDuration target:self selector:@selector(recordTimeStart) userInfo:nil repeats:YES];
    self.seconds = 0;
}

- (void)recordTimeStart{
    self.seconds++;
    self.timeLabel.text = [NSString stringWithFormat:@"%ld''", self.seconds];
    if(self.seconds == self.videoMaximumDuration)
        [self buttonStopRecording];
}

//录制结束回调
- (void)recorderDidEndRecording:(PKShortVideoRecorder *)recorder {
    //停止进度条
    [self.progressBar stop];
}

//视频录制结束回调
- (void)recorder:(PKShortVideoRecorder *)recorder didFinishRecordingToOutputFilePath:(NSString *)outputFilePath error:(NSError *)error {
    //解除自动锁屏限制
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    //取消计时器
    [self invalidateTime];
    if (error) {
        NSLog(@"视频拍摄失败: %@", error );
        [self endRecordingWithPath:outputFilePath failture:YES];
    } else {
        //当前时间
        CFAbsoluteTime nowTime = CACurrentMediaTime();
        if (self.beginRecordTime != 0 && nowTime - self.beginRecordTime < self.videoMinimumDuration) {
            [self endRecordingWithPath:outputFilePath failture:NO];
        } else {
            self.outputFilePath = outputFilePath;
            self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.playButton.backgroundColor = EC_Color_Clear;
            [self.playButton setTitleColor:EC_Color_White forState:UIControlStateNormal];
            [self.playButton setTitle:NSLocalizedString(@"回播", nil) forState:UIControlStateNormal];
            self.playButton.frame = CGRectMake(0, EC_kScreenH - EC_ShortVideo_BottomH, (EC_kScreenW - EC_ShortVideo_BtnW) / 2, EC_ShortVideo_BottomH);
            [self.view addSubview:self.playButton];
            
            self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.sendButton setTitle:NSLocalizedString(@"发送", nil) forState:UIControlStateNormal];
            self.sendButton.backgroundColor = EC_Color_Clear;
            [self.sendButton setTitleColor:EC_Color_White forState:UIControlStateNormal];
            self.sendButton.frame = CGRectMake(CGRectGetMaxX(self.recordButton.frame), EC_kScreenH - EC_ShortVideo_BottomH, (EC_kScreenW - EC_ShortVideo_BtnW) / 2, EC_ShortVideo_BottomH);
            [self.view addSubview:self.sendButton];
            [self sendButtonAction];
        }
    }
}

- (void)buildUI{
    self.view.backgroundColor = [UIColor blackColor];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, 44)];
    toolbar.barTintColor = EC_Color_Black;
    toolbar.translucent = YES;
    toolbar.alpha = 0.5;
    [self.view addSubview:toolbar];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"取消", nil) style:UIBarButtonItemStyleDone target:self action:@selector(cancelShoot)];
    cancelItem.tintColor = [UIColor whiteColor];
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *transformItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"PK_Camera_Turn"] style:UIBarButtonItemStyleDone target:self action:@selector(swapCamera)];
    transformItem.tintColor = [UIColor whiteColor];
    [toolbar setItems:@[cancelItem,flexible,transformItem]];
    
    //创建视频录制对象
    self.recorder = [[PKShortVideoRecorder alloc] initWithOutputFilePath:self.outputFilePath outputSize:self.outputSize];
    //通过代理回调
    self.recorder.delegate = self;
    //录制时需要获取预览显示的layer，根据情况设置layer属性，显示在自定义的界面上
    AVCaptureVideoPreviewLayer *previewLayer = [self.recorder previewLayer];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = CGRectMake(0, 0, EC_kScreenW, EC_kScreenH);
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    UIView *bottomBgView = [[UIView alloc] initWithFrame:CGRectMake(0, EC_kScreenH - EC_ShortVideo_BottomH, EC_kScreenW, EC_ShortVideo_BottomH)];
    bottomBgView.backgroundColor = EC_Color_Black;
    bottomBgView.alpha = 0.4;
    [self.view addSubview:bottomBgView];

    self.progressBar = [[PKShortVideoProgressBar alloc] initWithFrame:CGRectMake(0, EC_kScreenH - EC_ShortVideo_BottomH, EC_kScreenW, 5) themeColor:EC_Color_White duration:self.videoMaximumDuration];
    [self.view addSubview:self.progressBar];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.progressBar.frame) - 25, EC_kScreenW, 25)];
    self.timeLabel.backgroundColor = EC_Color_Clear;
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.textColor = EC_Color_White;
    self.timeLabel.font = EC_Font_System(15);
    self.timeLabel.text = @"0''";
    [self.view addSubview:self.timeLabel];
    
    self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordButton setBackgroundImage:EC_Image_Named(@"recordingNormal") forState:UIControlStateNormal];
    [self.recordButton setBackgroundImage:EC_Image_Named(@"recordingPress") forState:UIControlStateFocused];
    [self.recordButton setTitle:NSLocalizedString(@"按住录", nil) forState:UIControlStateNormal];
    [self.recordButton setTitleColor:EC_Color_White forState:UIControlStateNormal];
    self.recordButton.titleLabel.font = EC_Font_System(12);
    self.recordButton.frame = CGRectMake((EC_kScreenW - EC_ShortVideo_BtnW) / 2, EC_kScreenH - EC_ShortVideo_BtnH - 15, EC_ShortVideo_BtnW, EC_ShortVideo_BtnH);
    [self recordButtonAction];
    [self.view addSubview:self.recordButton];
}

- (void)dealloc {
    [_recorder stopRunning];
}

@end
