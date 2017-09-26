//
//  ECChatClickCellTool+Voice.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/8.
//

#import "ECChatClickCellTool+Voice.h"
#import <objc/runtime.h>
#import <AVFoundation/AVFoundation.h>
#import "ECChatCellMacros.h"
#import "ECChatBlockTool.h"
#import "ECChatCellUtil.h"


@implementation ECChatClickCellTool (Voice)

- (void)ec_Click_ChatVoiceCell {
    if (self.message.messageBody.messageBodyType != MessageBodyType_Voice)
        return;

    NSNumber *isplay = objc_getAssociatedObject(self.message, EC_KVoiceIsPlayKey);
    isplay = isplay == nil?@YES:@(!isplay.boolValue);
    
    if ([ECChatCellUtil sharedInstanced].playVoiceMessage) {
        //如果前一个在播放
        objc_setAssociatedObject([ECChatCellUtil sharedInstanced].playVoiceMessage, EC_KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
        if ([ECChatBlockTool sharedInstanced].ec_reloadSingleCellBlock)
            [ECChatBlockTool sharedInstanced].ec_reloadSingleCellBlock([ECChatCellUtil sharedInstanced].playVoiceMessage);
        [ECChatCellUtil sharedInstanced].playVoiceMessage = nil;
    }
    if (isplay.boolValue) {
        [ECChatCellUtil sharedInstanced].playVoiceMessage = self.message;
        objc_setAssociatedObject(self.message, EC_KVoiceIsPlayKey, isplay, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        
        [[ECDevice sharedInstance].messageManager playVoiceMessage:(ECVoiceMessageBody *)self.message.messageBody completion:^(ECError *error) {
            if (error.errorCode == ECErrorType_NoError) {
                objc_setAssociatedObject([ECChatCellUtil sharedInstanced].playVoiceMessage, EC_KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                if ([ECChatBlockTool sharedInstanced].ec_reloadSingleCellBlock)
                    [ECChatBlockTool sharedInstanced].ec_reloadSingleCellBlock([ECChatCellUtil sharedInstanced].playVoiceMessage);
                [ECChatCellUtil sharedInstanced].playVoiceMessage = nil;
            }
        }];
        if ([ECChatBlockTool sharedInstanced].ec_reloadSingleCellBlock)
            [ECChatBlockTool sharedInstanced].ec_reloadSingleCellBlock([ECChatCellUtil sharedInstanced].playVoiceMessage);
    }
}
@end
