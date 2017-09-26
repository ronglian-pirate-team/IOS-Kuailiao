//
//  ECChatFetchModel.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/3.
//
//

#import <Foundation/Foundation.h>

#define EC_CHAT_LOADMESSAGE_MAXCOUNT 15

typedef void(^EC_CHATMODEL_BLOCK)(NSMutableArray *array);

@interface ECChatFetchModel : NSObject

+ (instancetype)sharedInstanced;

@property (nonatomic, strong) EC_CHATMODEL_BLOCK chatModelBlock;

- (NSMutableArray *)ec_fetchMessageModel:(NSString *)sessionId;

@end
