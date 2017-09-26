//
//  ECChatClickCellTool.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/7.
//

#import <Foundation/Foundation.h>

@interface ECChatClickCellTool : NSObject

+ (instancetype)sharedInstanced;

/**
 图片相关
 */
@property (nonatomic, assign) BOOL isOpenSavePhoto;
@property (nonatomic, strong) NSMutableArray *photos;

@property (nonatomic, strong) ECMessage *message;
/**
 点击cell的方法

 @param message 消息体
 */
- (void)ec_Click_ChatCellEventWithMessage:(ECMessage *)message;

- (void)ec_Click_ChatCelltapPortraitEventWithMessage:(ECMessage *)message;

- (void)ec_Click_ChatCelltapReadLEventWithMessage:(ECMessage *)message;

@end
