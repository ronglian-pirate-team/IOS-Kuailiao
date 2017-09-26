//
//  ECChatMoreViewTool.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/8.
//
//

#import <Foundation/Foundation.h>

@interface ECChatMoreViewTool : NSObject

@property (nonatomic, copy) NSString *receiver;
@property (nonatomic, assign) BOOL isReadDeleteMessage;

+ (instancetype)sharedInstanced;


/**
 @brief 拍照并发送/取消
 */
- (void)sendMessageTakePicture;

/**
 @brief 从相册选取发送图片，可多选
 */
- (void)sendMessageSelectImages;


/**
 @brief 拍摄小视频发送
 */
- (void)sendMessageTakeVideo;


/**
 @brief 选择地点发送
 */
- (void)sendMessageSelectLocation;


/**
 @brief 发红包
 */
- (void)sendMessageRedpacket;


/**
 @brief 阅后即焚
 */
- (void)sendMessageReadFire;


/**
 @brief 语音通话
 */
- (void)takeCallVoice;


/**
 @brief 视频通话
 */
- (void)takeCallVideo;

@end
