//
//  ECMessage+BQMMMessage.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/10.
//

#import "ECMessage+BQMMMessage.h"
#import <YLGIFImage/YLGIFImage.h>
#import <objc/runtime.h>

@implementation ECMessage (BQMMMessage)

const char ec_chat_message_bqmm;

- (void)setEmojiCode:(NSString *)emojiCode {
    objc_setAssociatedObject(self, &ec_chat_message_bqmm, emojiCode, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)emojiCode {
    NSString *emojiC = objc_getAssociatedObject(self, &ec_chat_message_bqmm);
    return emojiC;
}

+ (UIImage *)messageToBQMM:(ECMessage *)message {
    return [[[[self class] alloc] init] messageToBQMM:message];
}

- (UIImage *)messageToBQMM:(ECMessage *)message {
    __block UIImage *image = nil;
    if (message.userData) {
        image = [UIImage imageNamed:@"mm_emoji_loading"];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[message.userData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if (!dict) {
            return nil;
        }
        if (dict[txt_msgType]) {
            NSArray *codes = nil;
            if (dict[faceEmojiArray]) {
                codes = @[dict[faceEmojiArray][0][0]];
            }
            MMFetchType type = dict[faceEmojiArray][0][1]?MMFetchTypeBig:MMFetchTypeSmall;
            [[MMEmotionCentre defaultCentre] fetchEmojisByType:type codes:codes completionHandler:^(NSArray *emojis) {
                if (emojis.count > 0) {
                    MMEmoji *emoji = emojis[0];
                    if ([codes[0] isEqualToString:emoji.emojiCode]) {
                        image = [YLGIFImage imageWithData:emoji.emojiData];
                        message.emojiCode = emoji.emojiCode;
                    }
                }
                else {
                    image = [UIImage imageNamed:@"mm_emoji_error"];
                }
            }];
        }
    }
    return image;
}
@end
