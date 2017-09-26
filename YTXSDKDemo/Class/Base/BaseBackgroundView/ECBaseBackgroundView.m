//
//  ECBaseBackgroundView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/31.
//
//

#import "ECBaseBackgroundView.h"

@interface ECBaseBackgroundView()

@property (nonatomic, strong)UILabel *nothingLabel;

@end

@implementation ECBaseBackgroundView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self buildUI];
    }
    return self;
}

- (void)setNothingTitle:(NSString *)nothingTitle{
    _nothingTitle = nothingTitle;
    _nothingLabel.text = nothingTitle;
}

- (void)buildUI{
    UIImageView *nothingImage = [[UIImageView alloc] initWithImage:EC_Image_Named(@"qunzuBackimg")];
    [self addSubview:nothingImage];
    
    _nothingLabel = [[UILabel alloc] init];
    _nothingLabel.font = EC_Font_System(14);
    _nothingLabel.text = @"您还没有创建任何群组，点击右上角+号按钮创建";
    _nothingLabel.textColor = EC_Color_Sec_Text;
    _nothingLabel.textAlignment = NSTextAlignmentCenter;
    _nothingLabel.numberOfLines = 0;
    [self addSubview:_nothingLabel];
    EC_WS(self)
    [_nothingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nothingImage.mas_bottom).offset(20);
        make.left.right.equalTo(weakSelf).offset(0);
    }];
}

@end
