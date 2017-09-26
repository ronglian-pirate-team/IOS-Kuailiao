//
//  ECDemoChatManager.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/1.
//
//

#import "ECDemoChatManager.h"
#import "ECChatFetchModel.h"

@implementation ECDemoChatManager

+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static ECDemoChatManager *mgr = nil;
    dispatch_once(&onceToken, ^{
        mgr = [[[self class] alloc] init];
    });
    return mgr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [ECChatFetchModel sharedInstanced];
    }
    return self;
}

- (UIImage *)ec_chatBackgroundImageOfSessionId:(NSString *)sessionId sourceImg:(UIImage *)sourceImg {
    UIImage *img = nil;
    NSString *cachePath = [NSString stringWithFormat:@"%@_backgroundimg.data",[NSString MD5:sessionId]];
    if (sourceImg)
        [[SDImageCache sharedImageCache] storeImage:sourceImg forKey:cachePath completion:nil];
    img = [[SDImageCache sharedImageCache] imageFromCacheForKey:cachePath];
    return img;
}

- (void)ec_removeChatBackgroundImageOfSessionId:(NSString *)sessionId {
    NSString *cachePath = [NSString stringWithFormat:@"%@_backgroundimg.data",[NSString MD5:sessionId]];
    [[SDImageCache sharedImageCache] removeImageForKey:cachePath withCompletion:nil];
}

@end
