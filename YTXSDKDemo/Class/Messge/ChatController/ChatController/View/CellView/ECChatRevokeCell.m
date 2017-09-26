//
//  ECChatRevokeCell.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/23.
//

#import "ECChatRevokeCell.h"
#import "ECRevokeMessageBody.h"

#define EC_CHAT_REVOKECELL_TOPMARGIN 5.0f
#define EC_CHAT_REVOKECELL_HORMARGIN 10.0f

#define EC_CHAT_TEXTCELL_BubbleMaxSize CGSizeMake([UIScreen mainScreen].bounds.size.width-100.0f, 10000.0f)

@interface ECChatRevokeCell ()
@property(strong, nonatomic) UILabel *tipMessageLabel;
@end

@implementation ECChatRevokeCell

#pragma mark - UI创建
- (void)layoutSubviews {
    [super layoutSubviews];
    self.tipMessageLabel.frame = (CGRect) {
        EC_CHAT_REVOKECELL_HORMARGIN,
        EC_CHAT_REVOKECELL_TOPMARGIN,
        self.message.cellWidth - EC_CHAT_REVOKECELL_HORMARGIN * 2,
        self.message.cellHeight - EC_CHAT_REVOKECELL_TOPMARGIN * 2 - EC_CHAT_CELL_V_OtherCell
    };
}

- (void)updateChildUI {
    [super updateChildUI];
    [self.bgContentView addSubview:self.tipMessageLabel];
    self.bgContentView.userInteractionEnabled = NO;
    self.bgContentView.backgroundColor = [UIColor colorWithRed:0xdd * 1.0f / 255.0f
                                                         green:0xdd * 1.0f / 255.0f
                                                          blue:0xdd * 1.0f / 255.0f
                                                         alpha:1.0f];
    self.bgContentView.layer.cornerRadius = 4.0f;
    self.bgContentView.layer.masksToBounds = YES;
    if ([self.message.messageBody isKindOfClass:[ECRevokeMessageBody class]]) {
        ECRevokeMessageBody *revokeBody = (ECRevokeMessageBody *)self.message.messageBody;
        self.tipMessageLabel.text = revokeBody.text;
    }
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
@end
