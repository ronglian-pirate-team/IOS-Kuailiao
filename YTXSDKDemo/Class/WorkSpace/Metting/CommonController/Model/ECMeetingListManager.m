//
//  ECMeetingListManager.m
//  YTXSDKDemo
//
//  Created by xt on 2017/9/13.
//
//

#import "ECMeetingListManager.h"
#import "ECMeetingVoiceVC.h"
#import "ECMeetingVideoVC.h"
#import "ECMeetingInterphoneVC.h"

@interface ECMeetingListManager()<UIAlertViewDelegate>

@property (nonatomic, assign)ECMeetingType meetingType;
@property (nonatomic, strong) ECMeetingRoom *meetingRoom;

@end

@implementation ECMeetingListManager

+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static ECMeetingListManager *mgr = nil;
    dispatch_once(&onceToken, ^{
        mgr = [[[self class] alloc] init];
    });
    return mgr;
}

- (void)fetchMeetingListDataWithType:(ECMeetingType)type completion:(void (^) (NSArray *list))completion{
    if(type == ECMeetingType_Interphone){
        if(completion)
            completion([ECDeviceDelegateHelper sharedInstanced].interphoneArray);
    }else{
        [[ECDevice sharedInstance].meetingManager listAllMultMeetingsByMeetingType:type andKeywords:nil completion:^(ECError *error, NSArray *meetingList) {
            if(error.errorCode == ECErrorType_NoError){
                if(completion)
                    completion(meetingList);
            }
        }];
    }
}

- (void)joinMeetingRoom:(ECMeetingRoom *)meetingRoom{
    self.meetingRoom = meetingRoom;
    self.meetingType = ([meetingRoom isKindOfClass:[ECMultiVideoMeetingRoom class]] ? ECMeetingType_MultiVideo : ECMeetingType_MultiVoice);
    [self operationMeetingRoom];
}

- (void)joinInterphoneRoom:(ECInterphoneMeetingMsg *)interphoneRoom{
    EC_ShowHUD_OnView(@"", [AppDelegate sharedInstanced].currentVC.view)
    [[ECDevice sharedInstance].meetingManager joinMeeting:interphoneRoom.interphoneId ByMeetingType:ECMeetingType_Interphone andMeetingPwd:nil completion:^(ECError *error, NSString *meetingNumber) {
        EC_HideHUD_OnView([AppDelegate sharedInstanced].currentVC.view)
        if(error.errorCode == ECErrorType_NoError){
            ECMeetingInterphoneVC *interphoneVC = [[ECMeetingInterphoneVC alloc] init];
            interphoneVC.meetingNum = meetingNumber;
            [[AppDelegate sharedInstanced].currentVC.navigationController pushViewController:interphoneVC animated:YES];
        }
    }];
}

- (void)operationMeetingRoom{
    if([self.meetingRoom.creator isEqualToString:[ECDevicePersonInfo sharedInstanced].userName]){//是选中会议的创建者
        [ECAlertController sheetControllerWithTitle:NSLocalizedString(@"提示", nil) message:nil cancelTitle:NSLocalizedString(@"取消", nil) DestructiveTitle:nil DefautTitleArray:@[NSLocalizedString(@"加入会议", nil), NSLocalizedString(@"解散会议", nil)] showInView:[AppDelegate sharedInstanced].currentVC handler:^(UIAlertAction *action) {
            if([action.title isEqualToString:NSLocalizedString(@"加入会议", nil)]){
                self.meetingRoom.isValidate ? [self showPwdAlert] : [self joinMeetingWithPwd:nil];
            }else if ([action.title isEqualToString:NSLocalizedString(@"解散会议", nil)]){
                [self dissMissMeeting];
            }
        }];
    }else{
        self.meetingRoom.isValidate ? [self showPwdAlert] : [self joinMeetingWithPwd:nil];
    }
}

- (void)showPwdAlert{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"输入密码", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)dissMissMeeting{
    [[ECDevice sharedInstance].meetingManager deleteMultMeetingByMeetingType:self.meetingType andMeetingNumber:self.meetingRoom.roomNo completion:^(ECError *error, NSString *meetingNumber) {
        if(error.errorCode == ECErrorType_NoError){
        }else{
            [ECCommonTool toast:[NSString stringWithFormat:@"%ld,%@", error.errorCode, error.errorDescription]];
        }
    }];
}

- (void)joinMeetingWithPwd:(NSString *)pwd{
    if(self.meetingType == ECMeetingType_MultiVoice){
        ECMeetingVoiceVC *voiceVC = [[ECMeetingVoiceVC alloc] init];
        voiceVC.meetingRoomNum = self.meetingRoom.roomNo;
        voiceVC.meetingRoom = (ECMultiVoiceMeetingRoom *)self.meetingRoom;
        voiceVC.password = pwd;
        [voiceVC showVoiceMeetingView];
    }else if(self.meetingType == ECMeetingType_MultiVideo){
        ECMeetingVideoVC *videoVC = [[ECMeetingVideoVC alloc] init];
        videoVC.meetingRoomNum = self.meetingRoom.roomNo;
        videoVC.meetingRoom = (ECMultiVideoMeetingRoom *)self.meetingRoom;
        videoVC.password = pwd;
        [videoVC showVideoMeetingView];
    }
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){
        UITextField *textField = [alertView textFieldAtIndex:0];
        [self joinMeetingWithPwd:textField.text];
    }
}

@end
