//
//  LiveChatRoomTool.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/9.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

#define ECToolViewH 44.0f

@class LiveChatRoomTool;

@protocol LiveChatRoomToolDelegate <NSObject>

- (BOOL)liveChatRoomTool:(LiveChatRoomTool*)liveChatRoomTool growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

- (void)liveChatRoomTool:(LiveChatRoomTool*)liveChatRoomTool growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height;

- (void)LiveChatRoomTool:(LiveChatRoomTool *)liveChatRoomTool emojiSendBtn:(UIButton *)sender;
@end

@interface LiveChatRoomTool : UIView

+ (instancetype)sharedInstanced;

@property (nonatomic, strong) HPGrowingTextView *inputTextView;

@property (nonatomic, weak) id<LiveChatRoomToolDelegate> delegate;

- (void)tapTextView;
@end
