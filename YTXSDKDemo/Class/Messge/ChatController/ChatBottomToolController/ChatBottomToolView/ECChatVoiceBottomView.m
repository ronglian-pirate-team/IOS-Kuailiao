//
//  ECChatVoiceBottomView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/2.
//
//

#import "ECChatVoiceBottomView.h"

@implementation ECChatVoiceBottomView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.voiceType = ECChatVoiceType_Normal;
        [self buildUI];
    }
    return self;
}

- (void)setVoiceType:(ECChatVoiceType)voiceType{
    _voiceType = voiceType;
    UIButton *btn1 = (UIButton *)[self viewWithTag:12345];
    UIButton *btn2 = (UIButton *)[self viewWithTag:12346];
    btn1.selected = (voiceType == ECChatVoiceType_Normal);
    btn2.selected = (voiceType == ECChatVoiceType_Change);
}

- (void)voiceBtnAction:(UIButton *)btn{
    UIButton *btn1 = (UIButton *)[self viewWithTag:12345];
    UIButton *btn2 = (UIButton *)[self viewWithTag:12346];
    btn2.selected = (btn.tag == btn2.tag);
    btn1.selected = (btn.tag == btn1.tag);
    if([self.delegate respondsToSelector:@selector(selectVoiceType:)])
        [self.delegate selectVoiceType:btn2.selected ? ECChatVoiceType_Change : ECChatVoiceType_Normal];
}

#pragma mark - UI创建
- (void)buildUI{
    for (int i = 0; i < 2; i++) {
        UIButton *voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceBtn.titleLabel.font = EC_Font_System(12);
        [voiceBtn setTitleColor:EC_Color_App_Main forState:UIControlStateSelected];
        [voiceBtn setTitleColor:EC_Color_Sec_Text forState:UIControlStateNormal];
        [voiceBtn setTitle:(i == 0 ? @"对讲" : @"变声") forState:UIControlStateNormal];
        [voiceBtn addTarget:self action:@selector(voiceBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        voiceBtn.tag = 12345 + i;
        voiceBtn.selected = i == 0;
        [self addSubview:voiceBtn];
        EC_WS(self)
        [voiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.offset(EC_VoiceBtom_H);
            make.width.offset(EC_VoiceBtom_W);
            make.left.equalTo(weakSelf).offset(EC_VoiceBtom_W * i);
            make.top.equalTo(weakSelf);
        }];
    }
}

@end
