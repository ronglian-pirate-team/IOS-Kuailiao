//
//  ECGroupMemberCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/28.
//
//

#import "ECGroupMemberCell.h"

@interface ECGroupMemberCell()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *headImage;

@end

@implementation ECGroupMemberCell

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self buildUI];
    }
    return self;
}

- (void)setImageName:(NSString *)imageName{
    _imageName = imageName;
    self.headImage.image = EC_Image_Named(imageName);
    _nameLabel.hidden = YES;
    _headImage.hidden = NO;
}

- (void)setGroupMember:(ECGroupMember *)groupMember{
    if(![groupMember isKindOfClass:[ECGroupMember class]]){
        _nameLabel.hidden = YES;
        _headImage.hidden = YES;
        return;
    }
    _groupMember = groupMember;
    _nameLabel.text = groupMember.display.length>0?groupMember.display:groupMember.memberId;
    _nameLabel.hidden = NO;
    _headImage.hidden = YES;
}

- (void)defaultCell {
    self.imageName = @"headerMan";
}

- (void)buildUI{
    UIImageView *headImage = [[UIImageView alloc] init];
    [self.contentView addSubview:headImage];
    self.headImage = headImage;
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.backgroundColor = EC_Color_ChatSendView_Bg;
    nameLabel.ec_radius = self.ec_width / 2;
    nameLabel.textColor = EC_Color_White;
    nameLabel.font = EC_Font_System(13);
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    EC_WS(self)
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
    [headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
}

@end
