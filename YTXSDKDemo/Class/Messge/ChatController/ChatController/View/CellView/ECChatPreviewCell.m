//
//  ECChatPreviewCell.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/5.
//

#import "ECChatPreviewCell.h"

#define EC_CHATCELL_PREVIEW_TITLE_LEFT EC_SIZE_SCALE(11.5f)
#define EC_CHATCELL_PREVIEW_TITLE_RIGHT EC_SIZE_SCALE(36.0f)
#define EC_CHATCELL_PREVIEW_TITLE_TOP 11.0f
#define EC_CHATCELL_PREVIEW_TITLE_H 45.0f

#define EC_CHATCELL_PREVIEW_CONTENT_LEFT EC_SIZE_SCALE(12.0f)
#define EC_CHATCELL_PREVIEW_CONTENT_TOP 6.0f
#define EC_CHATCELL_PREVIEW_CONTENT_W EC_SIZE_SCALE(150.0f)
#define EC_CHATCELL_PREVIEW_CONTENT_H 41.0f

#define EC_CHATCELL_PREVIEW_THUMB_LEFT EC_SIZE_SCALE(13.5f)
#define EC_CHATCELL_PREVIEW_THUMB_WH EC_SIZE_SCALE(44.0f)

@interface ECChatPreviewCell ()
@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic, strong) UILabel *contentL;
@property (nonatomic, strong) UIImageView *thumbImgV;
@end

@implementation ECChatPreviewCell

#pragma mark - UI创建
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat title_x = [ECMessage validSendMessage:self.message]?EC_CHATCELL_PREVIEW_TITLE_LEFT:EC_CHATCELL_PREVIEW_TITLE_LEFT + EC_CHAT_BGCONTENT_ANGLE_W;
    CGFloat content_x = [ECMessage validSendMessage:self.message]?EC_CHATCELL_PREVIEW_CONTENT_LEFT:EC_CHATCELL_PREVIEW_CONTENT_LEFT + EC_CHAT_BGCONTENT_ANGLE_W;
    _titleL.frame = (CGRect){
        title_x,
        EC_CHATCELL_PREVIEW_TITLE_TOP,
        self.bgContentView.ec_width - EC_CHATCELL_PREVIEW_TITLE_LEFT - EC_CHATCELL_PREVIEW_TITLE_RIGHT,
        EC_CHATCELL_PREVIEW_TITLE_H
    };
    _contentL.frame = (CGRect){
        content_x,
        CGRectGetMaxY(self.titleL.frame) + EC_CHATCELL_PREVIEW_CONTENT_TOP,
        EC_CHATCELL_PREVIEW_CONTENT_W,
        EC_CHATCELL_PREVIEW_CONTENT_H
    };
    _thumbImgV.frame = (CGRect){
        CGRectGetMaxX(self.contentL.frame) + EC_CHATCELL_PREVIEW_THUMB_LEFT,
        CGRectGetMinY(self.contentL.frame),
        EC_CHATCELL_PREVIEW_THUMB_WH,
        EC_CHATCELL_PREVIEW_THUMB_WH
    };
}

- (void)updateChildUI {
    [super updateChildUI];
    [self.bgContentView addSubview:self.titleL];
    [self.bgContentView addSubview:self.contentL];
    [self.bgContentView addSubview:self.thumbImgV];
    if ([self.message.messageBody isKindOfClass:[ECPreviewMessageBody class]]) {
        ECPreviewMessageBody *body = (ECPreviewMessageBody *)self.message.messageBody;
        _titleL.text = body.title;
        _contentL.text = body.desc;
        __block UIImage *sourceImage = EC_Image_Named(@"attachment");
        if (body.localPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:body.localPath] && (body.mediaDownloadStatus==ECMediaDownloadSuccessed || self.message.messageState != ECMessageState_Receive)) {
            
            sourceImage = [UIImage imageWithContentsOfFile:body.localPath];
            if (sourceImage)
                self.thumbImgV.image = sourceImage;
        } else if (self.message.messageState == ECMessageState_Receive && body.thumbnailRemotePath.length>0) {
            [self.thumbImgV sd_setImageWithURL:[NSURL URLWithString:body.thumbnailRemotePath]
                              placeholderImage:sourceImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                              }];
        }
    }
}

#pragma mark - 懒加载
- (UILabel *)titleL {
    if (!_titleL) {
        _titleL = [[UILabel alloc] init];
        _titleL.numberOfLines = 0;
        _titleL.font = EC_Font_System(15.0f);
    }
    return _titleL;
}

- (UILabel *)contentL {
    if (!_contentL) {
        _contentL = [[UILabel alloc] init];
        _contentL.numberOfLines = 0;
        _contentL.textColor = EC_Color_Sec_Text;
        _contentL.font = EC_Font_System(11.0f);
        _contentL.textAlignment = NSTextAlignmentJustified;
        _contentL.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _contentL;
}

- (UIImageView *)thumbImgV {
    if (!_thumbImgV) {
        _thumbImgV = [[UIImageView alloc] initWithImage:EC_Image_Named(@"attachment")];
    }
    return _thumbImgV;
}
@end
