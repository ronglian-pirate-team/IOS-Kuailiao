//
//  ECChatRedpacketTakenTipCell.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/11.
//

#import "ECChatRedpacketTakenTipCell.h"
#import "ECMessage+RedpacketMessage.h"

#define EC_CHAT_TEXTCELL_BubbleMaxSize CGSizeMake([UIScreen mainScreen].bounds.size.width-100.0f, 10000.0f)

#define EC_CHAT_REDPACKETTAKENTIPCELL_V 30.0f
#define EC_CHAT_REDPACKETTAKENTIPCELL_H_MARGIN 40.0f

#define REDPACKET_BUNDLE(name) @"RedpacketCellResource.bundle/" name
#define BACKGROUND_LEFT_RIGHT_PADDING 10
#define ICON_LEFT_RIGHT_PADDING 5
#define ICON_TOP_PADDING 2
#define ICON_W 12.0f

@interface ECChatRedpacketTakenTipCell ()
@property(strong, nonatomic) UILabel *tipMessageLabel;
@property(strong, nonatomic) UIImageView *iconView;
@end

@implementation ECChatRedpacketTakenTipCell

#pragma mark - UI创建
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect iconFrame = self.iconView.frame;
    iconFrame.origin.x = BACKGROUND_LEFT_RIGHT_PADDING;
    iconFrame.origin.y = ICON_TOP_PADDING;
    self.iconView.frame = iconFrame;
    
    self.tipMessageLabel.frame = (CGRect) {
        CGRectGetMaxX(self.iconView.frame) + ICON_LEFT_RIGHT_PADDING,
        ICON_TOP_PADDING,
        self.message.cellWidth - CGRectGetMaxX(self.iconView.frame) - BACKGROUND_LEFT_RIGHT_PADDING - ICON_LEFT_RIGHT_PADDING,
        self.message.cellHeight - ICON_TOP_PADDING * 2 - EC_CHAT_CELL_V_OtherCell
    };
}

- (void)updateChildUI {
    [super updateChildUI];
    [self.bgContentView addSubview:self.iconView];
    [self.bgContentView addSubview:self.tipMessageLabel];
    self.bgContentView.userInteractionEnabled = NO;
    self.bgContentView.backgroundColor = [UIColor colorWithRed:0xdd * 1.0f / 255.0f
                                                         green:0xdd * 1.0f / 255.0f
                                                          blue:0xdd * 1.0f / 255.0f
                                                         alpha:1.0f];
    self.bgContentView.layer.cornerRadius = 4.0f;
    self.bgContentView.layer.masksToBounds = YES;
    self.tipMessageLabel.text = [self.message redpacketString];
}

#pragma mark - 懒加载
- (UILabel *)tipMessageLabel {
    if (!_tipMessageLabel) {
        _tipMessageLabel = [[UILabel alloc] init];
        _tipMessageLabel.font = EC_Font_System(12.0f);
        _tipMessageLabel.textColor = [UIColor colorWithRed:0x9e * 1.0f / 255.0f
                                                         green:0x9e * 1.0f / 255.0f
                                                          blue:0x9e * 1.0f / 255.0f
                                                         alpha:1.0f];
    }
    return _tipMessageLabel;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithImage:EC_Image_Named(@"xiaohongbao")];
        _iconView.frame = CGRectMake(0, 0, ICON_W, 15);
    }
    return _iconView;
}
@end
