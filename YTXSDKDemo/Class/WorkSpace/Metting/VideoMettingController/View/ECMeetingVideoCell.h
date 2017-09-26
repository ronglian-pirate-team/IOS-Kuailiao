//
//  ECMutiVideoCell.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/19.
//
//

#import <UIKit/UIKit.h>

@interface ECMeetingVideoCell : UICollectionViewCell

@property (nonatomic, strong) ECMultiVideoMeetingMember *videoMeetingMember;
@property (nonatomic, copy) NSString *meetingRoomNum;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, assign) BOOL isDisplayVideo;


@end
