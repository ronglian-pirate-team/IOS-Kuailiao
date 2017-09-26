//
//  ECAboutHeaderView.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/24.
//

#import "ECAboutHeaderView.h"

#define EC_labelH 13.0f
#define EC_margin 17.0f

@interface ECAboutHeaderView ()
@property (nonatomic, strong) UIImageView *imgV;
@property (nonatomic, strong) UILabel *label1;
@end

@implementation ECAboutHeaderView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self buildUi];
    }
    return self;
}

- (void)buildUi {
    _imgV = [[UIImageView alloc] init];
    UIImage *img = [UIImage imageNamed:(@"ECAboutIconHeader")];
    _imgV.image = img;
    _imgV.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_imgV];
    
    _label1 = [[UILabel alloc] init];
    _label1.text = [NSString stringWithFormat:@"%@%@",EC_AppName,EC_APPVersion];
    _label1.textAlignment = NSTextAlignmentCenter;
    _label1.font = EC_Font_System(14.0f);
    [self addSubview:_label1];
    
    [self.imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.size.sizeOffset(img.size);
        make.top.equalTo(self).offset(28.0f);
    }];
    
    [self.label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.size.sizeOffset(CGSizeMake(EC_kScreenW, EC_labelH));
        make.top.equalTo(self.imgV).offset(img.size.height + EC_margin);
    }];
}
@end
