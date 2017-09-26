//
//  ECMeetingVoiceVC.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/17.
//
//

#import "ECBaseContoller.h"

@interface ECMeetingVoiceVC : ECBaseContoller

@property (nonatomic, copy) NSString *meetingRoomNum;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) ECCreateMeetingParams *meetingParams;
@property (nonatomic, strong) ECMultiVoiceMeetingRoom *meetingRoom;

@property (nonatomic, assign) BOOL isInvite;//是否是邀请加入
@property (nonatomic, copy) NSString *callId;//邀请加入是有值
@property (nonatomic, copy) NSString *creater;//邀请加入时
@property (nonatomic, copy) NSString *roomName;//邀请加入时

- (void)showVoiceMeetingView;

@end
