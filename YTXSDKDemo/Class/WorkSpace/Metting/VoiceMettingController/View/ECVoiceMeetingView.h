//
//  ECVoiceMeetingVC.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/17.
//
//

#import "ECBaseContoller.h"

@interface ECVoiceMeetingView : UIView

@property (nonatomic, copy) NSString *meetingRoomNum;
@property (nonatomic, strong) ECCreateMeetingParams *meetingParams;

- (void)show;

@end
