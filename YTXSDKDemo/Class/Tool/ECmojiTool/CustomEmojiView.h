//
//  CustomEmojiView.h
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/18.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomEmojiViewDelegate <NSObject>

// 点击发送按钮
-(void)emojiSendBtn:(id)sender;

// 点击uitexview
- (void)tapTextView;
@end

@interface CustomEmojiView : UIView

+(CustomEmojiView*)shardInstance;

@property (nonatomic, weak) id<CustomEmojiViewDelegate> delegate;

// 切换到系统键盘
- (void)switchToDefaultKeyboard;

// 弹出表情键盘
- (void)attachEmotionKeyboardTo:(UIView *)view Input:(UITextView *)input;


- (void)setDefaultEmojiArray:(NSArray<NSString *> *)emojiArray;

- (void)buildEmojiUi;
@end
