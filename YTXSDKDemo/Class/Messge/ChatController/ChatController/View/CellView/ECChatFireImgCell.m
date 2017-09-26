//
//  ECChatFireImgCell.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/22.
//

#import "ECChatFireImgCell.h"
#import "ECChatCellUtil.h"

#define EC_CHATCELL_FIRE_TIME 10

#define EC_CHAT_FIREIMG_CELL_MARGIN 22.9f
#define EC_CHAT_FIREIMG_CELL_DURATION_W 30.0f
#define EC_CHAT_FIREIMG_CELL_DURATION_H 15.0f

@interface ECChatFireImgCell ()
@property (nonatomic, strong) UILabel *durationL;
@end

@implementation ECChatFireImgCell
{
    NSTimer *_timer;
    CGFloat _duration;
}

- (void)updateDurationL:(NSTimer *)timer {
    _duration --;
    _durationL.text = [NSString stringWithFormat:@"%d″",(int)_duration];
    if (_duration <= 0)
        [self ec_stopTimer];
}

- (void)ec_startTimer {
    if (!_timer) {
        _duration = EC_CHATCELL_FIRE_TIME;
        _timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:1 target:self selector:@selector(updateDurationL:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        [_timer fireDate];
    }
}

- (void)ec_stopTimer {
    [_timer invalidate];
    _timer = nil;
    self.message.isReadFireMessage = NO;
    [[ECDeviceHelper sharedInstanced] ec_deleteMessage:self.message];
}
#pragma mark - UI创建
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat duration_x = self.displayImgV.ec_width - EC_CHAT_FIREIMG_CELL_MARGIN - EC_CHAT_FIREIMG_CELL_DURATION_W;
    CGFloat duration_y = 9.5f;
    if (self.message.messageState != ECMessageState_Receive) {
        duration_x = CGRectGetMinX(self.bgContentView.frame) - EC_CHAT_FIREIMG_CELL_MARGIN - EC_CHAT_FIREIMG_CELL_DURATION_W;
        duration_y = CGRectGetMinY(self.bgContentView.frame) + EC_CHAT_FIREIMG_CELL_MARGIN;
    }
    if (self.message.isReadFireMessage && self.message.messageState == ECMessageState_Receive) {
        duration_x = CGRectGetMaxX(self.bgContentView.frame) + EC_CHAT_FIREIMG_CELL_MARGIN;
        duration_y = CGRectGetMinY(self.bgContentView.frame) + EC_CHAT_FIREIMG_CELL_MARGIN;
    }
    self.durationL.frame = (CGRect) {
        duration_x,
        duration_y,
        EC_CHAT_FIREIMG_CELL_DURATION_W,
        EC_CHAT_FIREIMG_CELL_DURATION_H
    };
}

- (void)updateChildUI {
    [super updateChildUI];
    if (self.message.isReadFireMessage) {
        [self.contentView addSubview:self.durationL];
        if (self.message.isRead)
            [self ec_startTimer];
    }
    UIImage *img = self.displayImgV.image;
    if (self.message.isReadFireMessage && self.message.messageState == ECMessageState_Receive) {
        img = EC_Image_Named(@"chat_snapchat_unread");
    }
    [[ECChatCellUtil sharedInstanced] ec_scalImageSizeWithMessage:self.message img:img completion:^(UIImage *dstImg, CGSize size) {
        self.displayImgV.image = dstImg;
        self.bgContentView.bounds = (CGRect){CGPointZero,size};
        self.displayImgV.frame = self.bgContentView.bounds;
    }];
}

#pragma mark - 懒加载
- (UILabel *)durationL {
    if (!_durationL) {
        _durationL = [[UILabel alloc] init];
        _durationL.textAlignment = NSTextAlignmentCenter;
        _durationL.textColor = EC_Color_ChatFireImgDurationText;
        _durationL.font = EC_Font_System(17.0f);
        _durationL.text = [NSString stringWithFormat:@"%d″",(int)EC_CHATCELL_FIRE_TIME];
    }
    return _durationL;
}
@end
