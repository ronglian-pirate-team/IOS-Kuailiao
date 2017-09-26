//
//  ECChatCellUtil.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/10.
//

#import "ECChatCellUtil.h"
#import <objc/runtime.h>
#import "ECChatCellMacros.h"

#define EC_CHATCELL_VOICE_DURATION_BASE_W 80.0f
#define EC_CHATCELL_VOICE_DURATION_ROTE_W 8.0f

@implementation ECChatCellUtil

+(instancetype)sharedInstanced {
    static ECChatCellUtil *cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cls = [[[self class] alloc] init];
    });
    return cls;
}

#pragma mark - 语音处理
- (void)ec_stopVoiceWithMsg:(ECMessage *)msg {
    if ([msg isEqual:self.playVoiceMessage]) {
        NSNumber* isplay = objc_getAssociatedObject(self.playVoiceMessage, EC_KVoiceIsPlayKey);
        if (self.playVoiceMessage && isplay.boolValue) {
            objc_setAssociatedObject(self.playVoiceMessage, EC_KVoiceIsPlayKey, @NO, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [[ECDevice sharedInstance].messageManager stopPlayingVoiceMessage];
            self.playVoiceMessage = nil;
        }
    }
}

- (CGFloat)ec_getVoiceWidthWithTime:(NSInteger)time {
    CGFloat width = 160.0f;
    if (time <= 0)
        width = 120.0f;
    else if (time <= 2)
        width = EC_CHATCELL_VOICE_DURATION_BASE_W;
    else if (time < 10)
        width = (EC_CHATCELL_VOICE_DURATION_BASE_W + EC_CHATCELL_VOICE_DURATION_ROTE_W * (time - 2));
    else if (time < 60)
        width = (EC_CHATCELL_VOICE_DURATION_BASE_W + EC_CHATCELL_VOICE_DURATION_ROTE_W * (7 + time / 10));
    return width;
}

- (void)ec_scalImageSizeWithMessage:(ECMessage *)message img:(UIImage *)img completion:(void(^)(UIImage *dstImg , CGSize size))completion {
    
    CGSize size = img.size;
    CGFloat newWidth = EC_CHATCELL_IMAGE_V * size.width / size.height;
    if (newWidth > 200) {
        newWidth = 200;
    } else if (newWidth < 70) {
        newWidth = 70;
    }
    CGFloat newHeight = EC_CHATCELL_IMAGE_V;
    size = CGSizeMake(newWidth + EC_CHAT_CELL_H_Other, newHeight + EC_CHAT_CELL_V_Other);
    if (message.cellHeight == size.height) {
        if (completion)
            completion(img,size);
        return;
    }
    message.cellWidth = size.width;
    message.cellHeight = size.height;
    [[ECMessageDB sharedInstanced] updateMessageSize:message.sessionId messageId:message.messageId withCellSize:size];
    if (completion)
        completion(img,size);
}
@end
