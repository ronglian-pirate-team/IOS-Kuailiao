//
//  ECMeetingVoiceSetCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/16.
//
//

#import "ECMeetingVoiceSetCell.h"

@implementation ECMeetingVoiceSetCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self buildUI];
    }
    return  self;
}

- (void)selectVoiceMode:(UIButton *)btn{
    UIButton *btn1 = [self.contentView viewWithTag:123456];
    UIButton *btn2 = [self.contentView viewWithTag:123457];
    UIButton *btn3 = [self.contentView viewWithTag:123458];
    btn1.selected = (btn.tag == btn1.tag);
    btn2.selected = (btn.tag == btn2.tag);
    btn3.selected = (btn.tag == btn3.tag);
    if(self.selectVoiceModel)
        self.selectVoiceModel(btn.tag - 123456 + 1);
}

- (void)buildUI{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.text = NSLocalizedString(@"声音设置", nil);
    self.textLabel.hidden = YES;
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = NSLocalizedString(@"声音设置", nil);
    [self.contentView addSubview:titleLabel];
    UIView *voiceSetView = [[UIView alloc] init];
    [self.contentView addSubview:voiceSetView];
    
    UIButton *btn1 = [self voiceSetBtn:NSLocalizedString(@"仅有背景音", nil) isSelected:YES];
    UIButton *btn2 = [self voiceSetBtn:NSLocalizedString(@"全部提示音", nil) isSelected:NO];
    UIButton *btn3 = [self voiceSetBtn:NSLocalizedString(@"无声", nil) isSelected:NO];
    btn1.tag = 123456;
    btn2.tag = 123457;
    btn3.tag = 123458;
    [voiceSetView addSubview:btn1];
    [voiceSetView addSubview:btn2];
    [voiceSetView addSubview:btn3];
    NSArray *btns = @[btn1, btn2, btn3];
    EC_WS(self)
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.textLabel.mas_left);
        make.top.equalTo(weakSelf.contentView).offset(8);
        make.height.offset(30);
        make.right.equalTo(weakSelf.contentView.mas_right);
    }];
    [voiceSetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView);
        make.right.equalTo(weakSelf.contentView.mas_right);
        make.top.equalTo(titleLabel.mas_bottom).offset(5);
        make.height.offset(40);
        make.bottom.equalTo(weakSelf.contentView).offset(-1);
    }];
    [btns mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:10 leadSpacing:15 tailSpacing:15];
    [btns mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(voiceSetView.mas_top).offset(5);
    }];
}

- (UIButton *)voiceSetBtn:(NSString *)title isSelected:(BOOL)selected{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:EC_Image_Named(@"yaoqingIconCheckNormal") forState:UIControlStateNormal];
    [btn setImage:EC_Image_Named(@"yaoqingIconCheckHigh") forState:UIControlStateSelected];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.selected = selected;
    [btn setTitleColor:EC_Color_Main_Text forState:UIControlStateNormal];
    btn.titleLabel.font = EC_Font_System(16);
    [btn addTarget:self action:@selector(selectVoiceMode:) forControlEvents:UIControlEventTouchUpInside];
    [btn sizeToFit];
    return btn;
}

@end
