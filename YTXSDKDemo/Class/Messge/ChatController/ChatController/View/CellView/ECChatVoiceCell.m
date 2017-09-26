//
//  ECChatVoiceCell.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/5.
//

#import "ECChatVoiceCell.h"
#import "ECChatCellMacros.h"

#define EC_CHATCELL_VOICE_V 43.0f
#define EC_CHATCELL_VOICE_PLAYIMG_MARGIN 12.0f

#define EC_CHATCELL_VOICE_DEFAULTIMG1 EC_Image_Named(@"ec_chat_fanyuyin2")
#define EC_CHATCELL_VOICE_DEFAULTIMG2 EC_Image_Named(@"ec_chat_yuyin2")

#define EC_CHATCELL_VOICE_DURATION_BASE_W 80.0f
#define EC_CHATCELL_VOICE_DURATION_ROTE_W 8.0f

@interface ECChatVoiceCell ()
@property (nonatomic, strong) UIImageView *voicePlayImgV;
@property (nonatomic, strong) UILabel *durationL;
@end

@implementation ECChatVoiceCell

#pragma mark - UI创建
- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = self.voicePlayImgV.image.size;
    CGFloat voiceImg_x = EC_CHATCELL_VOICE_PLAYIMG_MARGIN;
    if (self.message.messageState != ECMessageState_Receive) {
        voiceImg_x = self.bgContentView.ec_width - size.width - EC_CHATCELL_VOICE_PLAYIMG_MARGIN;
    }
    self.voicePlayImgV.frame = (CGRect){
        voiceImg_x,
        (self.bgContentView.ec_height - size.height) / 2,
        size
    };
    CGFloat durationL_x = CGRectGetMaxX(self.voicePlayImgV.frame);
    CGFloat durationL_w = self.bgContentView.ec_width - 9.5 - durationL_x;
    if (self.message.messageState != ECMessageState_Receive) {
        durationL_x = 0;
        durationL_w = self.bgContentView.ec_width - self.voicePlayImgV.ec_width - 9.5;
    }
    self.durationL.frame = (CGRect){
        durationL_x,
        CGRectGetMinY(self.voicePlayImgV.frame),
        durationL_w,
        CGRectGetHeight(self.voicePlayImgV.frame)
    };
}

- (void)updateChildUI {
    [super updateChildUI];
    if ([self.message.messageBody isKindOfClass:[ECVoiceMessageBody class]]) {
        ECVoiceMessageBody *body = (ECVoiceMessageBody *)self.message.messageBody;
        if ([[NSFileManager defaultManager] fileExistsAtPath:body.localPath] && (body.mediaDownloadStatus==ECMediaDownloadSuccessed || self.message.messageState != ECMessageState_Receive)) {
            unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:body.localPath error:nil] fileSize];
            body.duration = (int)(fileSize/650);
            if (body.duration == 0) {
                body.duration = 1;
            }
            self.durationL.hidden = NO;
            self.durationL.text = [NSString stringWithFormat:@"%d″",(int)body.duration];
        } else {
            body.duration = 0;
            self.durationL.hidden = YES;
        }

        [self.bgContentView addSubview:self.voicePlayImgV];
        [self.bgContentView addSubview:self.durationL];
        if (self.message.messageState == ECMessageState_Receive) {
            self.durationL.textAlignment = NSTextAlignmentLeft;
            _voicePlayImgV.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"ec_chat_fanyuyin2"], [UIImage imageNamed:@"ec_chat_fanyuyin1"], EC_CHATCELL_VOICE_DEFAULTIMG1,[UIImage imageNamed:@"ec_chat_fanyuyin1"], nil];

        } else {
            self.durationL.textAlignment = NSTextAlignmentRight;
            _voicePlayImgV.image = EC_CHATCELL_VOICE_DEFAULTIMG2;
            _voicePlayImgV.animationImages = [NSArray arrayWithObjects:EC_CHATCELL_VOICE_DEFAULTIMG2, [UIImage imageNamed:@"ec_chat_yuyin1"], EC_CHATCELL_VOICE_DEFAULTIMG2,[UIImage imageNamed:@"ec_chat_yuyin1"], nil];
        }
        [self playVoice];
    }
}

- (void)playVoice {
    NSNumber *isplay = objc_getAssociatedObject(self.message, EC_KVoiceIsPlayKey);
    if (isplay && isplay.boolValue) {
        [self.voicePlayImgV startAnimating];
    } else {
        [self.voicePlayImgV stopAnimating];
    }
}

- (CGFloat)getWidthWithTime:(NSInteger)time {
    CGFloat width = 160.0f;
    if (time <= 0)
        width = 120.0f;
    else if (time <= 2)
        width = EC_CHATCELL_VOICE_DURATION_BASE_W;
    else if (time < 10)
        width = (EC_CHATCELL_VOICE_DURATION_BASE_W + EC_CHATCELL_VOICE_DURATION_ROTE_W * (time - 2));
    else if (time < 60)
        width = (EC_CHATCELL_VOICE_DURATION_BASE_W + EC_CHATCELL_VOICE_DURATION_ROTE_W * (7 + time / 10));
    return width;
}

#pragma mark - 懒加载
- (UIImageView *)voicePlayImgV {
    if (!_voicePlayImgV) {
        _voicePlayImgV = [[UIImageView alloc] initWithImage:EC_CHATCELL_VOICE_DEFAULTIMG1];
        _voicePlayImgV.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"ec_chat_fanyuyin2"], [UIImage imageNamed:@"ec_chat_fanyuyin1"], EC_CHATCELL_VOICE_DEFAULTIMG1,[UIImage imageNamed:@"ec_chat_fanyuyin1"], nil];
        _voicePlayImgV.animationDuration = 1;
    }
    return _voicePlayImgV;
}

- (UILabel *)durationL {
    if (!_durationL) {
        _durationL = [[UILabel alloc] init];
        _durationL.font = EC_Font_System(16);
        _durationL.text = [NSString stringWithFormat:@"%d″",(int)10];
    }
    return _durationL;
}
@end
