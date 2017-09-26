//
//  ECMeetingMemberView.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/17.
//
//

#import <UIKit/UIKit.h>

@interface ECMeetingMemberView : UICollectionView

@property (nonatomic, strong) NSMutableArray *collectionSource;
@property (nonatomic, copy) NSString *meetingRoomNum;
@property (nonatomic, copy) NSString *meetingRoomName;

@property (nonatomic, assign) ECMeetingType meetingType;

@property (nonatomic, assign) BOOL isCreater;

@end
