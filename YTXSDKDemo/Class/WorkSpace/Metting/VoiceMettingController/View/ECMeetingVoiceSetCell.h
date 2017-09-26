//
//  ECMeetingVoiceSetCell.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/16.
//
//

#import <UIKit/UIKit.h>

@interface ECMeetingVoiceSetCell : UITableViewCell

@property (nonatomic, copy) void (^selectVoiceModel)(NSInteger model);

@end
