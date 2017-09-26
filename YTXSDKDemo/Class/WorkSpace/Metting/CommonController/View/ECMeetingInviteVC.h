//
//  ECMeetingInviteVC.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/17.
//
//

#import "ECBaseContoller.h"

@interface ECMeetingInviteVC : ECBaseContoller

@property (nonatomic, assign) NSInteger inviteType;// 1 voip 2 手机号邀请
@property (nonatomic, copy) NSString *meetingNum;
@property (nonatomic, copy) NSString *meetingName;

@property (nonatomic, copy) void (^inviteCompletion)();

@end
