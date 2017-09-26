//
//  ECChatRedpacketCell.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/11.
//

#import "ECChatRedpacketCell.h"
#import "RedpacketOpenConst.h"
#import "ECMessage+RedpacketMessage.h"


#define EC_CHAT_REDPACKETCELL_H 245.5
#define EC_CHAT_REDPACKETCELL_V 95.0f

#define Redpacket_Message_Font_Size 14
#define Redpacket_SubMessage_Font_Size 12
#define Redpacket_SubMessage_Text NSLocalizedString(@"查看红包", @"查看红包")
#define Redpacket_Label_Padding 2

#define REDPACKET_BUNDLE(name) @"RedpacketCellResource.bundle/" name

@interface ECChatRedpacketCell ()
@property (nonatomic, strong) UIImageView *displayImgV;
@property(strong, nonatomic) UILabel *greetingLabel;
@property(strong, nonatomic) UILabel *subLabel; // 显示 "查看红包"
@property(strong, nonatomic) UILabel *orgLabel;
@property(strong, nonatomic) UIImageView *iconView;
@property(strong, nonatomic) UILabel *orgTypeLabel;
@end

@implementation ECChatRedpacketCell
#pragma mark - UI创建
- (void)layoutSubviews {
    [super layoutSubviews];
    self.displayImgV.frame = self.bgContentView.bounds;
}

- (void)updateChildUI {
    [super updateChildUI];
    [self.bgContentView addSubview:self.displayImgV];
    [self.bgContentView addSubview:self.greetingLabel];
    [self.bgContentView addSubview:self.subLabel];
    [self.bgContentView addSubview:self.orgLabel];
    [self.bgContentView addSubview:self.orgTypeLabel];
    [self.bgContentView addSubview:self.iconView];
    self.displayImgV.layer.mask = self.bgContenImgV.layer;

    RedpacketMessageModel *redpacketMessage = [self.message rpModel];
    self.greetingLabel.text = redpacketMessage.redpacket.redpacketGreeting;
    if ([[[self.message redPacketDic] valueForKey:RedpacketKeyRedapcketToAnyone] isEqualToString:@"member"])
        self.orgTypeLabel.text = @"专属红包";
    else
        self.orgTypeLabel.text = @"";
    self.greetingLabel.frame = CGRectMake(48, 19, 137, 15);
    CGRect frame = self.greetingLabel.frame;
    frame.origin.y = 41;
    self.subLabel.frame = frame;
    frame = CGRectMake(13, 76, 150, 12);
    CGRect rt = self.orgTypeLabel.frame;
    rt.origin = CGPointMake(145, 75);
    if (self.message.messageState != ECMessageState_Receive) {
        rt.origin = CGPointMake(141, 75);
    }
    rt.size = CGSizeMake(51, 14);
    self.orgTypeLabel.frame = rt;
}

#pragma mark - 懒加载
#pragma mark - 懒加载
- (UIImageView *)displayImgV {
    if (!_displayImgV) {
        _displayImgV = [[UIImageView alloc] init];
        _displayImgV.image = EC_Image_Named(@"zhanshihongbao");;
        _displayImgV.userInteractionEnabled = YES;
        _displayImgV.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _displayImgV;
}

- (UILabel *)greetingLabel {
    if (!_greetingLabel) {
        _greetingLabel = [[UILabel alloc] init];
        _greetingLabel.font = [UIFont systemFontOfSize:Redpacket_Message_Font_Size];
        _greetingLabel.textColor = [UIColor whiteColor];
        [_greetingLabel setLineBreakMode:NSLineBreakByCharWrapping];
    }
    return _greetingLabel;
}

- (UILabel *)subLabel {
    if (!_subLabel) {
        _subLabel = [[UILabel alloc] init];
        _subLabel.text = Redpacket_SubMessage_Text;
        _subLabel.font = [UIFont systemFontOfSize:Redpacket_SubMessage_Font_Size];
        _subLabel.textColor = [UIColor whiteColor];
        [_subLabel setLineBreakMode:NSLineBreakByCharWrapping];
    }
    return _subLabel;
}

- (UILabel *)orgLabel {
    if (!_orgLabel) {
        _orgLabel = [[UILabel alloc] init];
        _orgLabel.text = Redpacket_SubMessage_Text;
        _orgLabel.font = [UIFont systemFontOfSize:Redpacket_SubMessage_Font_Size];
        _orgLabel.textColor = EC_Color_Sec_Text;
        [_orgLabel setLineBreakMode:NSLineBreakByCharWrapping];
        _orgLabel.text = NSLocalizedString(@"容联云红包", nil);
        _orgLabel.frame = CGRectMake(13, 76, 150, 12);
    }
    return _orgLabel;
}

- (UILabel *)orgTypeLabel {
    if (!_orgTypeLabel) {
        _orgTypeLabel = [[UILabel alloc] init];
        _orgTypeLabel.textColor = [UIColor colorWithHex:0xf14e46];
        _orgTypeLabel.font = EC_Font_System(12.0f);
    }
    return _orgTypeLabel;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithImage:EC_Image_Named(@"smallhongbao")];
        _iconView.frame = CGRectMake(13, 19, 26, 34);
    }
    return _iconView;
}
@end
