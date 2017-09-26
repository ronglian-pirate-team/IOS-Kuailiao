//
//  ECVoiceChangeCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/5.
//
//

#import "ECVoiceChangeCell.h"

@interface ECVoiceChangeCell()

@property (nonatomic, strong) UIImageView *changeImage;
@property (nonatomic, strong) UILabel *voiceLabel;

@end

@implementation ECVoiceChangeCell

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self buildUI];
    }
    return self;
}

- (void)setInfoDic:(NSDictionary *)infoDic{
    _infoDic = infoDic;
    self.voiceLabel.text = [NSString stringWithFormat:@" %@  ", infoDic[@"title"]];
    self.changeImage.image = EC_Image_Named(infoDic[@"image"]);
}

- (void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    self.voiceLabel.backgroundColor = (isSelected ? EC_Color_App_Main : EC_Color_Clear);
    self.voiceLabel.textColor = (isSelected ? EC_Color_White : EC_Color_Main_Text);
}

#pragma mark - UI创建
- (void)buildUI{
    [self.contentView addSubview:self.changeImage];
    [self.contentView addSubview:self.voiceLabel];
    self.voiceLabel.backgroundColor = EC_Color_Clear;
    EC_WS(self)
    [self.changeImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(53);
        make.centerX.equalTo(weakSelf);
        make.top.equalTo(weakSelf).offset(10);
    }];
    [self.voiceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(weakSelf);
        make.centerX.equalTo(weakSelf);
        make.top.equalTo(weakSelf.changeImage.mas_bottom).offset(10);
    }];
}

- (UIImageView *)changeImage{
    if(!_changeImage){
        _changeImage = [[UIImageView alloc] init];
        _changeImage.image = EC_Image_Named(@"chatIconYuyinNormal");
    }
    return _changeImage;
}

- (UILabel *)voiceLabel{
    if(!_voiceLabel){
        _voiceLabel = [[UILabel alloc] init];
        _voiceLabel.font = EC_Font_System(12);
        _voiceLabel.textColor = EC_Color_Black;
        _voiceLabel.text = @"原声";
        _voiceLabel.textAlignment = NSTextAlignmentCenter;
        _voiceLabel.layer.masksToBounds = YES;
        [_voiceLabel sizeToFit];
        _voiceLabel.layer.cornerRadius = 4;
    }
    return _voiceLabel;
}

@end
