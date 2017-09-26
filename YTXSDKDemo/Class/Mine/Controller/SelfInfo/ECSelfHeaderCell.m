//
//  ECSelfHeaderCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/24.
//
//

#import "ECSelfHeaderCell.h"

@implementation ECSelfHeaderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self buildUI];
    }
    return self;
}

- (void)buildUI{
    [self.contentView addSubview:self.headImage];
    EC_WS(self)
    [self.headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(12);
        make.bottom.equalTo(weakSelf).offset(-12);
        make.width.height.offset(50);
        make.right.equalTo(weakSelf).offset(-33);
    }];
    self.headImage.ec_radius = 25;
}

- (UIImageView *)headImage{
    if(!_headImage){
        _headImage = [[UIImageView alloc] init];
        _headImage.image = EC_Image_Named(@"headerMan");
    }
    return _headImage;
}

@end
