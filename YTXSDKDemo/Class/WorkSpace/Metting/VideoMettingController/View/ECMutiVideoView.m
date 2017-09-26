//
//  ECMutiVideoView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/18.
//
//

#import "ECMutiVideoView.h"

@interface ECMutiVideoView()

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation ECMutiVideoView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self buildUI];
    }
    return self;
}

- (void)setName:(NSString *)name{
    _name = name;
    self.nameLabel.text = name;
}

- (void)buildUI{
    [self addSubview:self.bgView];
    EC_WS(self)
//    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(weakSelf);
//    }];
    [self addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(7);
        make.right.equalTo(weakSelf).offset(-7);
        make.bottom.equalTo(weakSelf).offset(-5);
    }];
}

- (UIView *)bgView{
    if(!_bgView){
        _bgView = [[UIView alloc] initWithFrame:self.bounds];
        _bgView.backgroundColor = EC_Color_Clear;
    }
    return _bgView;
}

- (UILabel *)nameLabel{
    if(!_nameLabel){
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = EC_Color_White;
        _nameLabel.font = EC_Font_System(11);
    }
    return _nameLabel;
}

@end
