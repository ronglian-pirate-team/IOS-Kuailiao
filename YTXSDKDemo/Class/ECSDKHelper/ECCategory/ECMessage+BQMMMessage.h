//
//  ECMessage+BQMMMessage.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/10.
//

#import "ECMessage.h"
#import <BQMM/BQMM.h>

#define txt_msgType @"txt_msgType"
#define faceEmojiArray @"msg_data"
#define EmojiType_BigeEmoji @"EmojiType_BigeEmoji"

@interface ECMessage (BQMMMessage)

+ (UIImage *)messageToBQMM:(ECMessage *)message;

@property (nonatomic, copy) NSString *emojiCode;
@end
