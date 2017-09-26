//
//  ECMeetingVideoVC.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/18.
//
//

#import "ECBaseContoller.h"

@interface ECMeetingVideoVC : ECBaseContoller

@property (nonatomic, copy) NSString *meetingRoomNum;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) ECCreateMeetingParams *meetingParams;
@property (nonatomic, strong) ECMultiVideoMeetingRoom *meetingRoom;

@property (nonatomic, copy) NSString *creater;//邀请加入时
@property (nonatomic, copy) NSString *roomName;

- (void)showVideoMeetingView;

@end
