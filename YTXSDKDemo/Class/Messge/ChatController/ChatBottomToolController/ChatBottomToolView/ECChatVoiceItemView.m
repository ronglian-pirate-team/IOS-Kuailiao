//
//  ECChatVoiceItemView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/2.
//
//

#import "ECChatVoiceItemView.h"

#define EC_VoiceItem_BtnH 109

@interface ECChatVoiceItemView()

@property (nonatomic, strong) UIButton *voiceBtn;
@property (nonatomic, strong) UILabel *voiceLabel;

@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UIButton *playBtn;

@end

@implementation ECChatVoiceItemView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self buildUI];
    }
    return self;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    self.voiceLabel.text = title;
}

- (void)setImageName:(NSString *)imageName{
    _imageName = imageName;
    [self.voiceBtn setImage:EC_Image_Named(imageName) forState:UIControlStateNormal];
}

- (void)setSelectImageName:(NSString *)selectImageName{
    _selectImageName = selectImageName;
    [self.voiceBtn setImage:EC_Image_Named(selectImageName) forState:UIControlStateHighlighted];
}

- (void)setVoiceType:(ECChatVoiceType)voiceType{
    _voiceType = voiceType;
    if(voiceType == ECChatVoiceType_Normal){
        [self addSubview:self.deleteBtn];
        [self addSubview:self.playBtn];
        self.deleteBtn.hidden = YES;
        self.playBtn.hidden = YES;
        [self addLine];
        EC_WS(self)
        [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.offset(40);
            make.right.equalTo(weakSelf).offset(-22);
            make.top.equalTo(weakSelf.voiceLabel.mas_bottom).offset(14);
        }];
        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.offset(40);
            make.left.equalTo(weakSelf).offset(22);
            make.top.equalTo(weakSelf.voiceLabel.mas_bottom).offset(14);
        }];
    }else if (voiceType == ECChatVoiceType_Change){
    }
}

- (void)addTarget:(id)target action:(SEL)sel forControlEvents:(UIControlEvents)event{
    [self.voiceBtn addTarget:target action:sel forControlEvents:event];
}

- (void)hiddenHelperView{
    self.deleteBtn.hidden = YES;
    self.playBtn.hidden = YES;
}

- (void)showHelperView{
//    self.deleteBtn.hidden = NO;
//    self.playBtn.hidden = NO;
}

#pragma mark - UI创建
- (void)buildUI{
    [self addSubview:self.voiceLabel];
    [self addSubview:self.voiceBtn];
    EC_WS(self)
    [self.voiceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.top.equalTo(weakSelf).offset(10);
    }];
    [self.voiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf);
        make.size.mas_equalTo(CGSizeMake(EC_VoiceItem_BtnH, EC_VoiceItem_BtnH));
        make.top.equalTo(weakSelf.voiceLabel.mas_bottom).offset(14);
    }];
}

- (UILabel *)voiceLabel{
    if(!_voiceLabel){
        _voiceLabel = [[UILabel alloc] init];
        _voiceLabel.font = EC_Font_System(15);
        _voiceLabel.textColor = EC_Color_Sec_Text;
        _voiceLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _voiceLabel;
}

- (UIButton *)voiceBtn{
    if(!_voiceBtn){
        _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _voiceBtn;
}

- (UIButton *)deleteBtn{
    if(!_deleteBtn){
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn setBackgroundImage:EC_Image_Named(@"chatYuyinIconDeleteNormal") forState:UIControlStateNormal];
    }
    return _deleteBtn;
}

- (UIButton *)playBtn{
    if(!_playBtn){
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setBackgroundImage:EC_Image_Named(@"chatYuyinIconHuiboNormal") forState:UIControlStateNormal];
    }
    return _playBtn;
}

- (void)addLine{
    CAShapeLayer *progressLayer = [CAShapeLayer new];
    progressLayer.lineWidth = 1;
    progressLayer.fillColor = EC_Color_Clear.CGColor;
    UIBezierPath *progressPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.ec_width / 2, 0) radius:(EC_kScreenW - 84) startAngle:0 endAngle:2 * M_PI clockwise:YES];
    progressLayer.path = progressPath.CGPath;
//    [self.layer addSublayer:progressLayer];
}

@end
