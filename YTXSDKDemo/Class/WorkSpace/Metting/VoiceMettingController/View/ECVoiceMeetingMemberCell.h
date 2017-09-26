//
//  ECVoiceMeetingMemberCell.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/17.
//
//

#import <UIKit/UIKit.h>

@interface ECVoiceMeetingMemberCell : UICollectionViewCell

@property (nonatomic, strong) ECMultiVoiceMeetingMember *voiceMember;
@property (nonatomic, strong) ECMultiVideoMeetingMember *videoMember;

@property (nonatomic, strong) ECInterphoneMeetingMember *interphoneMember;

@property (nonatomic, strong) NSDictionary *operationInfo;

@end
