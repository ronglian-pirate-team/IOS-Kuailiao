//
//  ECCallVideoView.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/12.
//
//

#import <UIKit/UIKit.h>

@interface ECCallVideoView : UIView

@property (nonatomic, copy) NSString *callId;
@property (nonatomic, copy) NSString *callNumber;
@property (nonatomic, assign) BOOL isIncomingCall;
@property (nonatomic, strong) ECFriend *friendInfo;

- (void)show;

@end
