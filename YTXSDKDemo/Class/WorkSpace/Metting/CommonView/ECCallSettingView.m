//
//  ECCallSettingView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/18.
//
//

#import "ECCallSettingView.h"
#import "ECCallOperationView.h"
#import "ECMainTabbarVC.h"

@interface ECCallSettingView()

@property (nonatomic, strong)NSArray *operations;
@property (nonatomic, assign) CGFloat fixedSpace;
@property (nonatomic, assign) CGFloat leadSpace;
@property (nonatomic, assign) CGFloat tailSpace;
@property (nonatomic, assign) NSInteger currentCameraIndex;

@end

@implementation ECCallSettingView

- (instancetype)initWithOperation:(NSArray *)operations withFixedSpacing:(CGFloat)fixed leadSpacing:(CGFloat)lead tailSpacing:(CGFloat)tail{
    if(self = [super init]){
        self.currentCameraIndex = [ECDeviceVoipHelper sharedInstanced].cameraInfoArray.count - 1;
        [self switchCamera];
        self.operations = operations;
        self.fixedSpace = fixed;
        self.leadSpace = lead;
        self.tailSpace = tail;
        [self buildUI];
    }
    return self;
}

- (void)operationAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    ECCallOperationView *operationV = (ECCallOperationView *)sender.superview;
    switch (operationV.operationType) {
        case ECCallOperationType_Microphone:{
            BOOL mute = [[ECDevice sharedInstance].VoIPManager getMuteStatus];
            [[ECDevice sharedInstance].VoIPManager setMute:!mute];
        }
            break;
        case ECCallOperationType_Speaker:{
            BOOL isSpeaker = [[ECDevice sharedInstance].VoIPManager getLoudsSpeakerStatus];
            [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:!isSpeaker];
        }
            break;
        case ECCallOperationType_Camera:
            [self switchCamera];
            break;
        case ECCallOperationType_Exit:
            [[ECDevice sharedInstance].meetingManager exitMeeting];
//            [[self currentVC] popViewControllerAnimated:YES];
            if(self.exitMeeting)
                self.exitMeeting();
            break;
        default:
            break;
    }
}

- (void)switchCamera{
    [[ECDeviceVoipHelper sharedInstanced] selectCamera:self.currentCameraIndex];
    self.currentCameraIndex++;
    if(self.currentCameraIndex >= [ECDeviceVoipHelper sharedInstanced].cameraInfoArray.count)
        self.currentCameraIndex = 0;
}

- (UINavigationController *)currentVC{
    if([[AppDelegate sharedInstanced].window.rootViewController isKindOfClass:[UITabBarController class]]){
        ECMainTabbarVC *tabbarVC = (ECMainTabbarVC *)[AppDelegate sharedInstanced].window.rootViewController;
        return tabbarVC.selectedViewController;
    }
    return nil;
}

- (void)buildUI{
    NSMutableArray *views = [NSMutableArray array];
    for (int i = 0; i < self.operations.count; i++) {
        NSDictionary *operationInfo = self.operations[i];
        ECCallOperationView *operationView = [[ECCallOperationView alloc] initWithImage:operationInfo[@"image"] title:operationInfo[@"title"]];
        operationView.textColor = EC_Color_VoiceCall_Text_Gray;
        operationView.selectImageName = operationInfo[@"selectImage"];
        operationView.operationType = [operationInfo[@"type"] integerValue];
        [operationView addTarget:self action:@selector(operationAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:operationView];
        [views addObject:operationView];
    }
    EC_WS(self)
    [views mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:self.fixedSpace leadSpacing:self.leadSpace tailSpacing:self.tailSpace];
    [views mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(weakSelf);
    }];
}

@end
