//
//  ECFriendInfoDetailHeader.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/23.
//
//

#import "ECFriendInfoDetailHeader.h"

@interface ECFriendInfoDetailHeader()

@property (nonatomic, strong) UIImageView *headImage;
@property (nonatomic, strong) UILabel *remarkLabel;
@property (nonatomic, strong) UILabel *accountLabel;
@property (nonatomic, strong) UILabel *nickNameLabel;

@end

@implementation ECFriendInfoDetailHeader

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self buildUI];
    }
    return self;
}

- (void)setFriendInfo:(ECFriend *)friendInfo{
    if(!friendInfo)
        return;
    _friendInfo = friendInfo;
    [self.headImage sd_setImageWithURL:[NSURL URLWithString:friendInfo.avatar] placeholderImage:EC_Image_Named(@"headerMan")];
    self.accountLabel.text = friendInfo.useracc;
    NSMutableAttributedString *attributeStr1 = [[NSMutableAttributedString alloc] initWithString:[friendInfo.displayName stringByAppendingString:@"     "]];
    NSDictionary *attributeDict = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16],NSFontAttributeName,
                                   [UIColor lightGrayColor],NSForegroundColorAttributeName,nil];
    [attributeStr1 addAttributes:attributeDict range:NSMakeRange(0, attributeStr1.length)];
    NSTextAttachment *attach = [[NSTextAttachment alloc] init];
    attach.image = friendInfo.sex != ECSexType_Female ? EC_Image_Named(@"man") : EC_Image_Named(@"woman");
    NSAttributedString *attributeStr2 = [NSAttributedString attributedStringWithAttachment:attach];
    [attributeStr1 insertAttributedString:attributeStr2 atIndex:attributeStr1.length];
    self.remarkLabel.attributedText = attributeStr1;
    NSString *nickName = @"";
    if(friendInfo.nickName && friendInfo.nickName.length > 0)
        nickName = friendInfo.nickName;
    if(nickName.length > 0)
        self.nickNameLabel.text = nickName;
}

#pragma mark - UI创建
- (void)buildUI{
    [self addSubview:self.headImage];
    [self addSubview:self.remarkLabel];
    [self addSubview:self.accountLabel];
    [self addSubview:self.nickNameLabel];
    EC_WS(self)
    [self.headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(28);
        make.width.height.offset(64);
        make.centerX.equalTo(weakSelf);
    }];
    [self.remarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.headImage.mas_bottom).offset(12);
        make.centerX.equalTo(weakSelf);
    }];
    [self.accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.top.equalTo(weakSelf.remarkLabel.mas_bottom).offset(11);
    }];
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.top.equalTo(weakSelf.accountLabel.mas_bottom).offset(10);
    }];
    self.headImage.ec_radius = 32;
}

- (UIImageView *)headImage{
    if(!_headImage){
        _headImage = [[UIImageView alloc] init];
        _headImage.image = EC_Image_Named(@"headerMan");
    }
    return _headImage;
}

- (UILabel *)remarkLabel{
    if(!_remarkLabel){
        _remarkLabel = [[UILabel alloc] init];
        _remarkLabel.textAlignment = NSTextAlignmentCenter;
        [_remarkLabel sizeToFit];
        _remarkLabel.font = EC_Font_System(16);
    }
    return _remarkLabel;
}

- (UILabel *)accountLabel{
    if(!_accountLabel){
        _accountLabel = [[UILabel alloc] init];
        _accountLabel.textAlignment = NSTextAlignmentCenter;
        _accountLabel.textColor = EC_Color_Sec_Text;
        [_accountLabel sizeToFit];
        _accountLabel.font = EC_Font_System(13);
    }
    return _accountLabel;
}

- (UILabel *)nickNameLabel{
    if(!_nickNameLabel){
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.textAlignment = NSTextAlignmentCenter;
        _nickNameLabel.textColor = EC_Color_Sec_Text;
        [_nickNameLabel sizeToFit];
        _nickNameLabel.font = EC_Font_System(13);
    }
    return _nickNameLabel;
}

@end
