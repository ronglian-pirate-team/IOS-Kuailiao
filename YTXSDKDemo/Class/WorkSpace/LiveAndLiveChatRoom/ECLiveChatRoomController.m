//
//  ECLiveChatRoomController.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/17.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ECLiveChatRoomController.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "ECLiveChatRoomBaseController.h"

@interface ECLiveChatRoomController ()<UIAlertViewDelegate>

@property (nonatomic, strong) IJKFFMoviePlayerController *meadiaPlay;
@property (nonatomic, strong) ECLiveChatRoomBaseController *baseVC;
@end

@implementation ECLiveChatRoomController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建子页面
    [self prepareUI];
    
    // 注册映客通知观察者
    [self addObserver];
    
    UISwipeGestureRecognizer *rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipGesture:)];
    [self.view addGestureRecognizer:rightGesture];
    
    UISwipeGestureRecognizer *leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipGesture:)];
    leftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftGesture];
}

- (void)swipGesture:(UISwipeGestureRecognizer *)gesture {
    _baseVC.view.hidden = (gesture.direction == UISwipeGestureRecognizerDirectionRight);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    if (![self.meadiaPlay isPlaying]) {
        [self.meadiaPlay prepareToPlay];
    }
    [self.meadiaPlay play];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if ([self.meadiaPlay isPlaying]) {
        [self.meadiaPlay shutdown];
    }
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)prepareUI {
    
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_UNKNOWN];
    self.meadiaPlay = [[IJKFFMoviePlayerController alloc] initWithContentURLString:_url withOptions:[IJKFFOptions optionsByDefault]];
    _meadiaPlay.view.frame = self.view.bounds;
    [_meadiaPlay prepareToPlay];
    [self.view addSubview:_meadiaPlay.view];
    [_meadiaPlay setScalingMode:IJKMPMovieScalingModeAspectFill];
    _meadiaPlay.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    _baseVC = [[ECLiveChatRoomBaseController alloc] init];
    _baseVC.roomId = self.roomId;
    _baseVC.view.frame = self.view.bounds;
    [self addChildViewController:_baseVC];
    [self.view addSubview:_baseVC.view];
}

- (void)playBtnClicked:(UIButton *)sender {
    
    BOOL isSelected = sender.isSelected;
    [sender setImage:[UIImage imageNamed:isSelected?@"playing":@"pause"] forState:UIControlStateNormal];
    [self.meadiaPlay isPlaying]?[self.meadiaPlay pause]:[self.meadiaPlay play];
    
    isSelected = !isSelected;
    sender.selected = isSelected;
}

- (void)removeInfo {
    [self.meadiaPlay stop];
    [self.navigationController popViewControllerAnimated:true];
}
#pragma mark - 通知

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChangeNoti:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_meadiaPlay];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackFinishNoti:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_meadiaPlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaPlaybackIsPreparedToPlayDidChangeNoti:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_meadiaPlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChangeNoti:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_meadiaPlay];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeInfo) name:KECNOTIFICATION_LIVECHATROOM_EIXT object:nil];
}

- (void)removeObserver {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                  object:_meadiaPlay];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                                  object:_meadiaPlay];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                  object:_meadiaPlay];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:_meadiaPlay];
}

#pragma mark - 通知方法

- (void)loadStateDidChangeNoti:(NSNotification *)nofi {
    
}

- (void)moviePlayBackFinishNoti:(NSNotification *)noti {
    if (!noti.userInfo) return;

    int reason =[[[noti userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    switch (reason) {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"%s Ended:%d", __func__,(int)reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"%s UserExited:%d", __func__,(int)reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"%s Error:%d", __func__,(int)reason);
            break;
            
        default:
            NSLog(@"%s default:%d", __func__,(int)reason);
            break;
    }
}

- (void)mediaPlaybackIsPreparedToPlayDidChangeNoti:(NSNotification *)noti {
    NSLog(@"%s %@", __func__,noti);
}

- (void)moviePlayBackStateDidChangeNoti:(NSNotification *)noti {
    
    NSLog(@"%s %@", __func__,noti);

    switch (_meadiaPlay.playbackState) {
            
        case IJKMPMoviePlaybackStateStopped:
            NSLog(@"%s %d: stoped", __func__,(int)_meadiaPlay.playbackState);
            break;
            
        case IJKMPMoviePlaybackStatePlaying:
            NSLog(@"%s %d: playing", __func__, (int)_meadiaPlay.playbackState);
            break;
            
        case IJKMPMoviePlaybackStatePaused:
            NSLog(@"%s %d: paused", __func__, (int)_meadiaPlay.playbackState);
            break;
            
        case IJKMPMoviePlaybackStateInterrupted:
            NSLog(@"%s %d: interrupted", __func__, (int)_meadiaPlay.playbackState);
            break;
            
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"%s %d: seeking", __func__, (int)_meadiaPlay.playbackState);
            break;
        }
        default: {
            NSLog(@"%s %d: default", __func__, (int)_meadiaPlay.playbackState);
            break;
        }
    }
}

#pragma mark - UIAlertViewDelegate 
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex != buttonIndex) {
        [self removeInfo];
    }
}

#pragma mark - 懒加载
-(void)dealloc {
    [self removeObserver];
}
@end
