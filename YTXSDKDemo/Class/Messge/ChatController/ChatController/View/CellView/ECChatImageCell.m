//
//  ECChatImageCell.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/5.
//

#import "ECChatImageCell.h"
#import <YLGIFImage/YLImageView.h>
#import <YLGIFImage/YLGIFImage.h>
#import "ECChatCellUtil.h"

#define EC_CHATCELL_DEFAULTIMG EC_Image_Named(@"chatIconFasongtupianPlaceholder")
#define EC_CHATCELL_IMAGE_V 140.0f

@interface ECChatImageCell ()
@property (nonatomic, strong) UIButton *gifBtn;
@end

@implementation ECChatImageCell

#pragma mark - UI创建
- (void)layoutSubviews {
    [super layoutSubviews];
    self.displayImgV.frame = self.bgContentView.bounds;
    self.gifBtn.center = (CGPoint){
        self.bgContentView.ec_width/2,
        self.bgContentView.ec_height/2
    };
}

- (void)updateChildUI {
    [super updateChildUI];
    [self.bgContentView addSubview:self.gifBtn];
    self.displayImgV.layer.mask = self.bgContenImgV.layer;
    [self handleBaseImage];
}

#pragma mark - 处理image的方法
- (UIImage *)handleBaseImage {
    
    __block UIImage *sourceImage = nil;
    if ([self.message.messageBody isKindOfClass:[ECImageMessageBody class]]) {
        sourceImage = EC_CHATCELL_DEFAULTIMG;
        ECImageMessageBody *imgBody = (ECImageMessageBody *)self.message.messageBody;
        NSString *localPath = imgBody.isHD?imgBody.HDLocalPath:imgBody.localPath;
        if (localPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:localPath] && ((imgBody.mediaDownloadStatus==ECMediaDownloadSuccessed && !imgBody.isHD) || self.message.messageState != ECMessageState_Receive)) {
            if ([imgBody.localPath.pathExtension.lowercaseString isEqualToString:@"gif"]) {
                sourceImage = [YLGIFImage imageWithData:[NSData dataWithContentsOfFile:localPath]];
            } else {
                sourceImage = [UIImage imageWithContentsOfFile:localPath];
            }
        } else if (self.message.messageState == ECMessageState_Receive && imgBody.thumbnailRemotePath.length>0) {
            
            [self.displayImgV sd_setImageWithURL:[NSURL URLWithString:imgBody.thumbnailRemotePath]
                                placeholderImage:EC_CHATCELL_DEFAULTIMG options:SDWebImageRetryFailed completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                    if (image==nil) return;
                                    sourceImage = image;
                                    [[ECChatCellUtil sharedInstanced] ec_scalImageSizeWithMessage:self.message img:sourceImage completion:^(UIImage *dstImg, CGSize size) {
                                        self.displayImgV.image = dstImg;
                                        self.bgContentView.bounds = (CGRect){CGPointZero,size};
                                        self.displayImgV.frame = self.bgContentView.bounds;
                                    }];
                                }];
        }
        if (([imgBody.localPath.pathExtension.lowercaseString isEqualToString:@"gif"] || [[imgBody.thumbnailLocalPath.pathExtension.lowercaseString componentsSeparatedByString:@"_"][0] isEqualToString:@"gif"]) && sourceImage.images.count <1) {
            _gifBtn.hidden = NO;
        } else {
            _gifBtn.hidden = YES;
        }
    }
    if (sourceImage)
        [[ECChatCellUtil sharedInstanced] ec_scalImageSizeWithMessage:self.message img:sourceImage completion:^(UIImage *dstImg, CGSize size) {
            self.displayImgV.image = dstImg;
            self.bgContentView.bounds = (CGRect){CGPointZero,size};
            self.displayImgV.frame = self.bgContentView.bounds;
        }];
    return sourceImage;
}

#pragma mark - 懒加载
- (UIButton *)gifBtn {
    if (!_gifBtn) {
        _gifBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _gifBtn.userInteractionEnabled = NO;
        [_gifBtn setImage:EC_Image_Named(@"chat_play_gif") forState:UIControlStateNormal];
        [_gifBtn sizeToFit];
        _gifBtn.hidden = YES;
    }
    return _gifBtn;
}
@end
