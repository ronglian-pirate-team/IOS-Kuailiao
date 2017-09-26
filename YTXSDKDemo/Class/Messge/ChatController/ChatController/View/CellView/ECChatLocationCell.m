//
//  ECChatLocationCell.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/5.
//

#import "ECChatLocationCell.h"
#import "ECChatCellUtil.h"

#define EC_CHATCELL_LOCATION_L_H 32.0F

@interface ECChatLocationCell ()
@property (nonatomic, strong) UIImageView *displayImgV;
@property (nonatomic, strong) UILabel *localtionL;
@end

@implementation ECChatLocationCell

#pragma mark - UI创建
- (void)layoutSubviews {
    [super layoutSubviews];
    self.displayImgV.frame = self.bgContentView.bounds;
    CGFloat location_x = [ECMessage validSendMessage:self.message]?0:8.0f;
    self.localtionL.frame = (CGRect) {
        location_x,
        self.bgContentView.ec_height - EC_CHATCELL_LOCATION_L_H ,
        self.bgContentView.ec_width - EC_CHAT_BGCONTENT_ANGLE_W,
        EC_CHATCELL_LOCATION_L_H
    };
}

- (void)updateChildUI {
    [super updateChildUI];
    [self.bgContentView addSubview:self.displayImgV];
    [self.bgContentView addSubview:self.localtionL];
    _displayImgV.layer.mask = self.bgContenImgV.layer;
    if ([self.message.messageBody isKindOfClass:[ECLocationMessageBody class]]) {
        ECLocationMessageBody *locationBody = (ECLocationMessageBody *)self.message.messageBody;
        _localtionL.text = locationBody.title;
        if (self.message.shotImg)
            self.displayImgV.image = self.message.shotImg;
    }
}
#pragma mark - 懒加载
- (UIImageView *)displayImgV {
    if (!_displayImgV) {
        _displayImgV = [[UIImageView alloc] initWithImage:EC_Image_Named(@"chatView_location_map")];
        _displayImgV.layer.mask = self.bgContenImgV.layer;
    }
    return _displayImgV;
}

- (UILabel *)localtionL {
    if (!_localtionL) {
        _localtionL = [[UILabel alloc] init];
        _localtionL.numberOfLines = 0;
        [_localtionL sizeToFit];
        _localtionL.textColor = [UIColor whiteColor];
        _localtionL.font = EC_Font_System(12.0f);
        _localtionL.backgroundColor = EC_Color_ChatLocationMessageView_LBg;
    }
    return _localtionL;
}
@end
