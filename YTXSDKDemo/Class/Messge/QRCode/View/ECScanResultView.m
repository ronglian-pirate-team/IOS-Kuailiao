//
//  ECScanResultView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/1.
//
//

#import "ECScanResultView.h"

@interface ECScanResultView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *resultLabel;

@end

@implementation ECScanResultView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self buildUI];
    }
    return self;
}

- (void)setResult:(NSString *)result{
    _result = result;
    _resultLabel.text = result;
}

#pragma mark - UI创建
- (void)buildUI{
    [self addSubview:self.titleLabel];
    [self addSubview:self.resultLabel];
    EC_WS(self)
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(64);
        make.left.right.equalTo(weakSelf);
        make.height.offset(30);
    }];
    
    [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.titleLabel.mas_bottom).offset(10);
        make.left.equalTo(weakSelf).offset(10);
        make.right.equalTo(weakSelf);
    }];
}

- (UILabel *)resultLabel{
    if(!_resultLabel){
        _resultLabel = [[UILabel alloc] init];
        _resultLabel.numberOfLines = 0;
    }
    return _resultLabel;
}

- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"您扫描的结果如下： ";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end
