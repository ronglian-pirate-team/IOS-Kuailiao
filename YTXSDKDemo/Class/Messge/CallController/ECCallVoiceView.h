//
//  ECCallVoiceView.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/9.
//
//

#import <UIKit/UIKit.h>

@interface ECCallVoiceView : UIView

@property (nonatomic, copy) NSString *callNumber;//拨打/收到的电话
@property (nonatomic, assign) BOOL isIncomingCall;
@property (nonatomic, strong) NSString *callId;//通话id,如果是打进来的则由外部传入，打出去的则在makeCall时生成
@property (nonatomic, strong) ECFriend *friendInfo;

- (void)show;

@end
