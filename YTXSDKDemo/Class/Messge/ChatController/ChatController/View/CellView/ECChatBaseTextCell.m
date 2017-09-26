//
//  ECChatBaseTextCell.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/11.
//

#import "ECChatBaseTextCell.h"
#import "ECChatClickCellTool+Text.h"

#define EC_CHAT_TEXTCELL_FONT 16.0f
#define EC_CHAT_TEXTCELL_H_MARGIN 43.0f
#define EC_CHAT_TEXTCELL_H_LEFT 24.0f
#define EC_CHAT_TEXTCELL_H_RIGHT 19.0f
#define EC_CHAT_TEXTCELL_H_TOPMARGIN 12.5f

@interface ECChatBaseTextCell ()
@end

@implementation ECChatBaseTextCell
#pragma mark - UI创建
- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentL.frame = (CGRect){
        EC_CHAT_TEXTCELL_H_LEFT,
        EC_CHAT_TEXTCELL_H_TOPMARGIN,
        self.bgContentView.ec_width - EC_CHAT_TEXTCELL_H_LEFT - EC_CHAT_TEXTCELL_H_RIGHT,
        self.bgContentView.ec_height - EC_CHAT_TEXTCELL_H_TOPMARGIN * 2
    };
}

- (void)updateChildUI {
    [super updateChildUI];
    [self.bgContentView addSubview:self.contentL];
}

#pragma mark - 懒加载
- (UILabel *)contentL {
    if (!_contentL) {
        _contentL = [[XXLinkLabel alloc] init];
        _contentL.numberOfLines = 0;
        _contentL.lineBreakMode = NSLineBreakByCharWrapping;
        _contentL.font = EC_Font_System(EC_CHAT_TEXTCELL_FONT);
        _contentL.linkTextColor = EC_Color_ChatLinkOrPhoneMessageView_Bg;
        _contentL.regularType = XXLinkLabelRegularTypeUrl;
        _contentL.regularLinkClickBlock = ^(NSString *clickedString) {
            EC_Demo_AppLog(@"----block点击了文字----\n%@",clickedString);
            [[ECChatClickCellTool sharedInstanced] ec_Click_ChatTextCell:clickedString];
        };
    }
    return _contentL;
}
@end
