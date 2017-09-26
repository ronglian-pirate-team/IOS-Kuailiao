//
//  ECChatVoiceBottomView.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/2.
//
//

#import <UIKit/UIKit.h>

#define EC_VoiceBtom_W 50.0
#define EC_VoiceBtom_H 15

typedef NS_ENUM(NSInteger, ECChatVoiceType) {
    ECChatVoiceType_Normal,//对讲
    ECChatVoiceType_Change //变声
};

@protocol ECChatBottomViewDelegate <NSObject>

- (void)selectVoiceType:(ECChatVoiceType)type;

@end

@interface ECChatVoiceBottomView : UIView

@property (nonatomic, weak) id<ECChatBottomViewDelegate> delegate;
@property (nonatomic, assign) ECChatVoiceType voiceType;

@end
