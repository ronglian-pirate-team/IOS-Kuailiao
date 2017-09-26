//
//  ECChatCellUtil.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/10.
//

#import <Foundation/Foundation.h>

@interface ECChatCellUtil : NSObject

+ (instancetype)sharedInstanced;

/**
 语音相关相关
 */
@property (nonatomic, strong) ECMessage *playVoiceMessage;

- (void)ec_stopVoiceWithMsg:(ECMessage *)msg;
- (CGFloat)ec_getVoiceWidthWithTime:(NSInteger)time;

- (void)ec_scalImageSizeWithMessage:(ECMessage *)message img:(UIImage *)img completion:(void(^)(UIImage *dstImg , CGSize size))completion;
@end
