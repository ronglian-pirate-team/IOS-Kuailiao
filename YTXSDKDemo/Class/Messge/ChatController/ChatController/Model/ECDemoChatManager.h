//
//  ECDemoChatManager.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/1.
//
//

#import <Foundation/Foundation.h>

@interface ECDemoChatManager : NSObject

+ (instancetype)sharedInstanced;

- (UIImage *)ec_chatBackgroundImageOfSessionId:(NSString *)sessionId sourceImg:(UIImage *)sourceImg;

- (void)ec_removeChatBackgroundImageOfSessionId:(NSString *)sessionId;
@end
