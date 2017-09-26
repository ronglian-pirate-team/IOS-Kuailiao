//
//  ECMessage+RedpacketMessage.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/7/25.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "ECMessage.h"
#import "RedpacketMessageModel.h"

@interface ECMessage(RedPacketMessage)

@property(nonatomic,strong)RedpacketMessageModel * rpModel;
// 是否红包消息
- (BOOL)isRedpacket;
// 是否红包已抢消息
- (BOOL)isRedpacketOpenMessage;

// 红包的文本消息
- (NSString *)redpacketString;

// 把红包对象转换成字典
- (NSDictionary *)redPacketDic;

// 把红包对象转换成字符串
+ (NSString *)voluationModele:(RedpacketMessageModel *)model;

- (RedpacketMessageModel*)getRpmodel:(NSString*)userdata;

@end
