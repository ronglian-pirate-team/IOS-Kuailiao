//
//  LiveChatRoomTool.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/9.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "LiveChatRoomTool.h"
#import "CustomEmojiView.h"

#define ECMarginH 5.0f
#define ECBito 0.85
@interface LiveChatRoomTool ()<HPGrowingTextViewDelegate,CustomEmojiViewDelegate>
@property (nonatomic, strong) UIButton *emojiBtn;
@end

@implementation LiveChatRoomTool

+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static LiveChatRoomTool *cls;
    dispatch_once(&onceToken, ^{
        cls = [[[self class] alloc] init];
    });
    return cls;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.inputTextView];
    [self addSubview:self.emojiBtn];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _inputTextView.frame = CGRectMake(ECMarginH, ECMarginH, self.frame.size.width*ECBito, self.frame.size.height-2*ECMarginH);
    _emojiBtn.frame = CGRectMake(ECMarginH+CGRectGetMaxX(_inputTextView.frame), ECMarginH, self.frame.size.width*(1-ECBito)-3*ECMarginH, self.frame.size.height-2*ECMarginH);
}
#pragma mark - 按钮方法
- (void)switchToolbarDisplay:(UIButton *)sender {
    BOOL isSelected = sender.selected;
    isSelected = !isSelected;
    sender.selected = isSelected;
    
    if (!_inputTextView.isFirstResponder) {
        return;
    }
    if (sender.selected) {
        [_emojiBtn setImage:[UIImage imageNamed:@"keyboard_icon"] forState:UIControlStateNormal];
        [_emojiBtn setImage:[UIImage imageNamed:@"keyboard_icon_on"] forState:UIControlStateHighlighted];
        [CustomEmojiView shardInstance].delegate = self;
        [[CustomEmojiView shardInstance] attachEmotionKeyboardTo:_emojiBtn Input:_inputTextView.internalTextView];
    } else {
        [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon"] forState:UIControlStateNormal];
        [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon_on"] forState:UIControlStateHighlighted];
        [[CustomEmojiView shardInstance] switchToDefaultKeyboard];
    }
}
#pragma mark - HPGrowingTextViewDelegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(liveChatRoomTool:growingTextView:willChangeHeight:)]) {
        [self.delegate liveChatRoomTool:self growingTextView:growingTextView willChangeHeight:height];
    }
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView {
    return YES;
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (self.delegate && [self.delegate respondsToSelector:@selector(liveChatRoomTool:growingTextView:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegate liveChatRoomTool:self growingTextView:growingTextView shouldChangeTextInRange:range replacementText:text];
    }
    return NO;
}

#pragma mark - CustomEmojiViewDelegate
// 点击发送按钮
-(void)emojiSendBtn:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(LiveChatRoomTool:emojiSendBtn:)]) {
        [self.delegate LiveChatRoomTool:self emojiSendBtn:sender];
    }
}

// 点击uitexview
- (void)tapTextView {
    [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon"] forState:UIControlStateNormal];
    [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon_on"] forState:UIControlStateHighlighted];
    _emojiBtn.selected = NO;
}

#pragma mark - 懒加载
- (HPGrowingTextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[HPGrowingTextView alloc] init];
        _inputTextView.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1];
        _inputTextView.layer.cornerRadius = 5.0f;
        _inputTextView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
        _inputTextView.minNumberOfLines = 1;
        _inputTextView.maxNumberOfLines = 4;
        _inputTextView.returnKeyType = UIReturnKeySend;
        _inputTextView.font = [UIFont systemFontOfSize:15.0f];
        _inputTextView.delegate = self;
        _inputTextView.placeholder = @"添加文本";
        _inputTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _inputTextView;
}

- (UIButton *)emojiBtn {
    if (!_emojiBtn) {
        _emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emojiBtn addTarget:self action:@selector(switchToolbarDisplay:) forControlEvents:UIControlEventTouchUpInside];
        [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon"] forState:UIControlStateNormal];
        [_emojiBtn setImage:[UIImage imageNamed:@"facial_expression_icon_on"] forState:UIControlStateHighlighted];
        _emojiBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _emojiBtn.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_emojiBtn];

    }
    return _emojiBtn;
}

@end
