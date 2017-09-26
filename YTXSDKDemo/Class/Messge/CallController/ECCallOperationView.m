//
//  ECCallOperationView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/9.
//
//

#import "ECCallOperationView.h"

@interface ECCallOperationView()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, copy) NSString *title;

@end

@implementation ECCallOperationView

- (instancetype)initWithImage:(NSString *)imageName title:(NSString *)title{
    if(self = [super init]){
        _imageName = imageName;
        _title = title;
        [self buildUI];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    [self.button addTarget:target action:action forControlEvents:controlEvents];
}

- (void)setTextColor:(UIColor *)textColor{
    _titleLabel.textColor = textColor;
}

- (void)setImageName:(NSString *)imageName{
    _imageName = imageName;
    [self.button setImage:EC_Image_Named(imageName) forState:UIControlStateNormal];
}

- (void)setSelectImageName:(NSString *)selectImageName{
    _selectImageName = selectImageName;
    [self.button setImage:EC_Image_Named(selectImageName) forState:UIControlStateSelected];
}

#pragma mark - UI创建
- (void)buildUI{
    [self addSubview:self.button];
    [self addSubview:self.titleLabel];
    EC_WS(self)
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf);
        make.top.equalTo(weakSelf);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.top.equalTo(weakSelf.button.mas_bottom).offset(10);
    }];
}

- (UIButton *) button{
    if (_button == nil) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setImage:EC_Image_Named(_imageName) forState:UIControlStateNormal];
    }
    return _button;
}

- (UILabel *) titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = EC_Font_System(12);
        _titleLabel.textColor = EC_Color_Black;
        _titleLabel.text = _title;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
@end
