//
//  ECMeetingListManager.h
//  YTXSDKDemo
//
//  Created by xt on 2017/9/13.
//
//

#import <Foundation/Foundation.h>

@interface ECMeetingListManager : NSObject

+ (instancetype)sharedInstanced;

- (void)fetchMeetingListDataWithType:(ECMeetingType)type completion:(void (^) (NSArray *list))completion;

- (void)joinMeetingRoom:(ECMeetingRoom *)meetingRoom;

- (void)joinInterphoneRoom:(ECInterphoneMeetingMsg *)interphoneRoom;

@end
