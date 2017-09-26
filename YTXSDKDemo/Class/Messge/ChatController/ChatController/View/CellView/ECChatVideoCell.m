//
//  ECChatVideoCell.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/5.
//

#import "ECChatVideoCell.h"
#import "UIImage+ECUtil.h"
#import "ECChatVideoCell+SightVideo.h"
#import "ECChatCellUtil.h"

#define EC_CHATCELL_VIDEO_V 182.0f
#define EC_CHATCELL_VIDEO_H 108.0f
#define EC_CHATCELL_VIDEO_TIME_MARGIN 5.0f
#define EC_CHATCELL_VIDEO_TIME_H 60.0f
#define EC_CHATCELL_VIDEO_TIME_V 15.0f

#define EC_CHATCELL_VIDEO_DEFAULTIMG EC_Image_Named(@"chatIconFasongtupianPlaceholder")

@interface ECChatVideoCell ()
@property (nonatomic, strong) UIImageView *displayImgV;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UILabel *videoTimeL;
@end

@implementation ECChatVideoCell

#pragma mark - UI创建
- (void)layoutSubviews {
    [super layoutSubviews];
    self.displayImgV.frame = self.bgContentView.bounds;
    self.videoView.frame = self.displayImgV.bounds;
    self.playBtn.center = (CGPoint){
        self.bgContentView.ec_width/2,
        self.bgContentView.ec_height/2
    };
    CGFloat videoTime_x = [ECMessage validSendMessage:self.message]?EC_CHATCELL_VIDEO_TIME_MARGIN:EC_CHATCELL_VIDEO_TIME_MARGIN + EC_CHAT_BGCONTENT_ANGLE_W;
    self.videoTimeL.frame = (CGRect){
        videoTime_x,
        self.bgContentView.ec_height - EC_CHATCELL_VIDEO_TIME_MARGIN - EC_CHATCELL_VIDEO_TIME_V,
        EC_CHATCELL_VIDEO_TIME_H,
        EC_CHATCELL_VIDEO_TIME_V
    };
}

- (void)updateChildUI {
    [super updateChildUI];
    
    [self.bgContentView addSubview:self.displayImgV];
    [self.displayImgV addSubview:self.videoView];
    [self.bgContentView addSubview:self.playBtn];
    [self.bgContentView addSubview:self.videoTimeL];
    
    __block UIImage *sourceImage = EC_CHATCELL_VIDEO_DEFAULTIMG;
    if ([self.message.messageBody isKindOfClass:[ECVideoMessageBody class]]) {
        ECVideoMessageBody *videoBody = (ECVideoMessageBody *)self.message.messageBody;
        if (videoBody.fileLength)
            self.videoTimeL.text = [NSString stringWithFormat:@"%.1fM",(float)(videoBody.fileLength/1024)/1024];
        
        if (videoBody.localPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:videoBody.localPath] && (videoBody.mediaDownloadStatus==ECMediaDownloadSuccessed || self.message.messageState != ECMessageState_Receive)) {
            sourceImage = [UIImage ec_GetVideoImage:videoBody.localPath];
            if (sourceImage==nil) return;
        } else if (self.message.messageState == ECMessageState_Receive && videoBody.thumbnailRemotePath.length>0) {
            
            [self.displayImgV sd_setImageWithURL:[NSURL URLWithString:videoBody.thumbnailRemotePath]
                                placeholderImage:EC_CHATCELL_VIDEO_DEFAULTIMG completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                    if (image==nil) return;
                                    sourceImage = image;
                                    [[ECChatCellUtil sharedInstanced] ec_scalImageSizeWithMessage:self.message img:sourceImage completion:^(UIImage *dstImg, CGSize size) {
                                        self.displayImgV.image = dstImg;
                                        self.displayImgV.frame = (CGRect){CGPointZero,size};
                                        _displayImgV.layer.mask = self.bgContenImgV.layer;
                                    }];
                                }];
        }
        [[ECChatCellUtil sharedInstanced] ec_scalImageSizeWithMessage:self.message img:sourceImage completion:^(UIImage *dstImg, CGSize size) {
            self.displayImgV.image = dstImg;
            self.displayImgV.frame = (CGRect){CGPointZero,size};
            _displayImgV.layer.mask = self.bgContenImgV.layer;
        }];
    }
}

#pragma mark - 懒加载
- (UIImageView *)displayImgV {
    if (!_displayImgV) {
        _displayImgV = [[UIImageView alloc] init];
        _displayImgV.contentMode = UIViewContentModeScaleAspectFill;
        _displayImgV.layer.mask = self.bgContenImgV.layer;
    }
    return _displayImgV;
}

- (UIView *)videoView {
    if (!_videoView) {
        _videoView = [[UIView alloc] init];
        _videoView.transform = CGAffineTransformMakeRotation(M_PI_2);
        _videoView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _videoView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:EC_Image_Named(@"message_chatIconDuanshipinNormal") forState:UIControlStateNormal];
        _playBtn.userInteractionEnabled = NO;
        [_playBtn sizeToFit];
    }
    return _playBtn;
}

- (UILabel *)videoTimeL {
    if (!_videoTimeL) {
        _videoTimeL = [[UILabel alloc] init];
        _videoTimeL.textColor = EC_Color_White;
        _videoTimeL.font = EC_Font_System(12.0f);
    }
    return _videoTimeL;
}
@end
