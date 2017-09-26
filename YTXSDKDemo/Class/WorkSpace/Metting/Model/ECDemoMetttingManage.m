//
//  ECDemoMetttingManage.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/5.
//
//

#import "ECDemoMetttingManage.h"
#import <objc/runtime.h>
#import "ECMeetingVoiceVC.h"
#import "ECMeetingVideoVC.h"


static const void *ec_meetingRoomNumKey = &ec_meetingRoomNumKey;
static const void *ec_callTypeKey = &ec_callTypeKey;
static const void *ec_callId = &ec_callId;
static const void *ec_callData = &ec_callData;

@implementation ECDemoMetttingManage

+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static ECDemoMetttingManage *mgr = nil;
    dispatch_once(&onceToken, ^{
        mgr = [[[self class] alloc] init];
    });
    return mgr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_KNOTIFICATION_Meeting_OnIncomingReceiveInfo object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            [[AppDelegate sharedInstanced].currentVC.view endEditing:YES];
            if (note.userInfo) {
                NSDictionary *dict = note.userInfo;
                NSString *meetingRoomNum = dict[EC_KMetting_CurNo];
                NSString *callId = dict[EC_KMetting_CallId];
                NSDictionary *callData = dict[EC_KMetting_CallData];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"是否加入%@会议", meetingRoomNum] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"加入", nil];
                objc_setAssociatedObject(alertView, ec_meetingRoomNumKey, meetingRoomNum, OBJC_ASSOCIATION_COPY_NONATOMIC);
                objc_setAssociatedObject(alertView, ec_callId, callId, OBJC_ASSOCIATION_COPY_NONATOMIC);
                objc_setAssociatedObject(alertView, ec_callData, callData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                objc_setAssociatedObject(alertView, ec_callTypeKey, dict[EC_KMetting_CallType], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                [alertView show];
            }
        }];
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *meetingRoomNum = objc_getAssociatedObject(alertView, ec_meetingRoomNumKey);
    NSString *callId = objc_getAssociatedObject(alertView, ec_callId);
    NSDictionary *callData = objc_getAssociatedObject(alertView, ec_callData);
    if(buttonIndex != alertView.cancelButtonIndex){
        CallType calltype = [objc_getAssociatedObject(alertView, ec_callTypeKey) integerValue];
        
        UIViewController *vc = nil;
        if(calltype == VOICE){
            vc = [[ECMeetingVoiceVC alloc] init];
            ((ECMeetingVoiceVC *)vc).meetingRoomNum = meetingRoomNum;
            ((ECMeetingVoiceVC *)vc).isInvite = YES;
            ((ECMeetingVoiceVC *)vc).callId = callId;
            ((ECMeetingVoiceVC *)vc).creater = callData[@"ECMeetingDelegate_CallerName"];
            ((ECMeetingVoiceVC *)vc).roomName = callData[@"ECMeetingDelegate_CallerConfInviteUserData"];
            [((ECMeetingVoiceVC *)vc) showVoiceMeetingView];
        }else if (calltype == VIDEO){
            vc = [[ECMeetingVideoVC alloc] init];
            ((ECMeetingVideoVC *)vc).meetingRoomNum = meetingRoomNum;
            ((ECMeetingVideoVC *)vc).creater = callData[@"ECMeetingDelegate_CallerName"];
            ((ECMeetingVideoVC *)vc).roomName = callData[@"ECMeetingDelegate_CallerConfInviteUserData"];
            [((ECMeetingVideoVC *)vc) showVideoMeetingView];
        }
    }
    [[ECDevice sharedInstance].VoIPManager rejectCall:meetingRoomNum andReason:ECErrorType_CallBusy];
}

- (NSMutableArray *)deleteSelfOfMeeting:(NSMutableArray *)members {
    NSMutableArray *array = [members mutableCopy];
    for (ECMeetingMember *member in array) {
        NSString *account = nil;
        if(member.meetingType == ECMeetingType_MultiVoice || member.meetingType == ECMeetingType_MultiVideo) {
            ECVoIPAccount *voipAccount = nil;
            if (member.meetingType == ECMeetingType_MultiVoice)
                voipAccount = [(ECMultiVoiceMeetingMember *)member account];
            else
                voipAccount = [(ECMultiVideoMeetingMember *)member voipAccount];
            account = voipAccount.account;
        } else {
            account = [(ECInterphoneMeetingMember *)member number];
        }
        if([account isEqualToString:[ECAppInfo sharedInstanced].persionInfo.userName]) {
            [array removeObject:member];
            break;
        }
    }
    return array;
}
@end
