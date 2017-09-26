//
//  ECChatBaseImgCell.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/11.
//

#import "ECChatBaseImgCell.h"
#import <YLGIFImage/YLGIFImage.h>
#import "ECMessage+ECUtil.h"
#import "ECMessage+BQMMMessage.h"

#define EC_CHAT_BASEIMGCELL_H 120.0f
#define EC_CHAT_BASEIMGCELL_V 120.0f

@interface ECChatBaseImgCell ()
@end

@implementation ECChatBaseImgCell

#pragma mark - UI创建
- (void)layoutSubviews {
    [super layoutSubviews];
    _displayImgV.frame = self.bgContentView.bounds;
}

- (void)updateChildUI {
    [super updateChildUI];
    [self.bgContentView addSubview:self.displayImgV];
    UIImage *sourceImage = nil;
    if ([ECMessage ExtendTypeOfTextMessage:self.message] == EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_BQMM) {
        sourceImage = [ECMessage messageToBQMM:self.message];
        self.bgContenImgV.hidden = YES;
    }
    self.displayImgV.image = sourceImage;
}
#pragma mark - 懒加载
- (UIImageView *)displayImgV {
    if (!_displayImgV) {
        _displayImgV = [[YLImageView alloc] init];
        _displayImgV.userInteractionEnabled = YES;
        _displayImgV.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _displayImgV;
}
@end
