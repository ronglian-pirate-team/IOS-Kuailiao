//
//  ECChatFileCell.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/5.
//

#import "ECChatFileCell.h"

#define EC_CHATCELL_FILE_H 210.5f
#define EC_CHATCELL_FILE_V 50.0f
#define EC_CHATCELL_FILE_L_H 30.0F

@interface ECChatFileCell ()
@property (nonatomic, strong) UIImageView *displayImgV;
@property (nonatomic, strong) UILabel *fileNameL;
@end

@implementation ECChatFileCell

#pragma mark - UI创建
- (void)layoutSubviews {
    [super layoutSubviews];
    self.displayImgV.frame = self.bgContentView.bounds;
    self.fileNameL.frame = (CGRect) {
        EC_CHAT_BGCONTENT_ANGLE_W,
        self.bgContentView.ec_height - EC_CHATCELL_FILE_L_H ,
        self.bgContentView.ec_width - EC_CHAT_BGCONTENT_ANGLE_W,
        EC_CHATCELL_FILE_L_H
    };
}

- (void)updateChildUI {
    [super updateChildUI];
    [self.bgContentView addSubview:self.displayImgV];
    [self.bgContentView addSubview:self.fileNameL];
    _displayImgV.layer.mask = self.bgContenImgV.layer;

    if ([self.message.messageBody isKindOfClass:[ECFileMessageBody class]]) {
        ECFileMessageBody *fileBody = (ECFileMessageBody *)self.message.messageBody;
        _fileNameL.text = fileBody.displayName;
    }
}
#pragma mark - 懒加载
- (UIImageView *)displayImgV {
    if (!_displayImgV) {
        _displayImgV = [[UIImageView alloc] initWithImage:EC_Image_Named(@"attachment_icon")];
        _displayImgV.layer.mask = self.bgContenImgV.layer;
    }
    return _displayImgV;
}

- (UILabel *)fileNameL {
    if (!_fileNameL) {
        _fileNameL = [[UILabel alloc] init];
        _fileNameL.font = EC_Font_System(13.0f);
        _fileNameL.numberOfLines = 0;
    }
    return _fileNameL;
}
@end

