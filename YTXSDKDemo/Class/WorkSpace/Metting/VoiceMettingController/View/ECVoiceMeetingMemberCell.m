//
//  ECVoiceMeetingMemberCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/17.
//
//

#import "ECVoiceMeetingMemberCell.h"

@interface ECVoiceMeetingMemberCell()

@property (nonatomic, strong) UIImageView *operationImage;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *joinStatusLabel;
@property (nonatomic, strong) UIImageView *videoPublishImage;

@end

@implementation ECVoiceMeetingMemberCell

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self buildUI];
    }
    return self;
}

- (void)setVideoMember:(ECMultiVideoMeetingMember *)videoMember{
    _videoMember = videoMember;
    self.titleLabel.text = videoMember.voipAccount.account;
    self.nameLabel.hidden = NO;
    self.operationImage.image = EC_Image_Named(@"yuyinliaotianIconJingyinNormal");
    EC_Demo_AppLog(@"speak listen = %@", videoMember.speakListen);
    if(videoMember.speakListen == nil || !videoMember.speakListen || videoMember.speakListen.length <= 1)
        videoMember.speakListen = @"11";
    if([videoMember.speakListen substringWithRange:NSMakeRange(1, 1)].integerValue == 0){
        self.operationImage.hidden = NO;
        [self.contentView bringSubviewToFront:self.operationImage];
    }else{
        self.operationImage.hidden = YES;
    }
    ECFriend *f = [[ECDBManager sharedInstanced].friendMgr queryFriend:videoMember.voipAccount.account];
//    self.operationImage.hidden = NO;
//    self.nameLabel.hidden = YES;
//    self.titleLabel.text = voiceMember.account.account;
    if(f && f != nil){
//        [self.operationImage sd_setImageWithURL:[NSURL URLWithString:f.avatar]];
//        self.titleLabel.text = f.displayName;
        self.nameLabel.text = f.displayName.length > 2 ? [f.displayName substringToIndex:2] : f.displayName;
    }else{
//        self.operationImage.image = [UIImage circleImageWithColor:[UIColor colorWithHex:0xa0ceff] withSize:CGSizeMake(60, 60) withName:voiceMember.account.account];
        self.nameLabel.text = videoMember.voipAccount.account.length > 2 ? [videoMember.voipAccount.account substringToIndex:2] : videoMember.voipAccount.account;
    }
    EC_Demo_AppLog(@"video states = %ld", videoMember.videoState);
    self.videoPublishImage.hidden = (videoMember.videoState == 2);
}

- (void)setVoiceMember:(ECMultiVoiceMeetingMember *)voiceMember{
    _voiceMember = voiceMember;
    self.titleLabel.text = voiceMember.account.account;
    self.nameLabel.hidden = NO;
    self.operationImage.image = EC_Image_Named(@"yuyinliaotianIconJingyinNormal");
    if(voiceMember.speakListen == nil || !voiceMember.speakListen || voiceMember.speakListen.length == 0)
        voiceMember.speakListen = @"11";
    if(voiceMember.speakListen.length == 2 && [voiceMember.speakListen substringWithRange:NSMakeRange(1, 1)].integerValue == 0){
        self.operationImage.hidden = NO;
        [self.contentView bringSubviewToFront:self.operationImage];
    }else{
        self.operationImage.hidden = YES;
    }
    ECFriend *f = [[ECDBManager sharedInstanced].friendMgr queryFriend:voiceMember.account.account];
//    self.operationImage.hidden = NO;
//    self.nameLabel.hidden = YES;
//    self.titleLabel.text = voiceMember.account.account;
    if(f && f != nil){
//        [self.operationImage sd_setImageWithURL:[NSURL URLWithString:f.avatar]];
//        self.titleLabel.text = f.displayName;
        self.nameLabel.text = f.displayName.length > 2 ? [f.displayName substringToIndex:2] : f.displayName;
    }else{
//        self.operationImage.image = [UIImage circleImageWithColor:[UIColor colorWithHex:0xa0ceff] withSize:CGSizeMake(60, 60) withName:voiceMember.account.account];
        self.nameLabel.text = voiceMember.account.account.length > 2 ? [voiceMember.account.account substringToIndex:2] : voiceMember.account.account;
    }
}

- (void)setInterphoneMember:(ECInterphoneMeetingMember *)interphoneMember{
    _interphoneMember = interphoneMember;
    ECFriend *f = [[ECDBManager sharedInstanced].friendMgr queryFriend:interphoneMember.number];
    self.operationImage.hidden = YES;
    self.nameLabel.hidden = NO;
    self.titleLabel.text = interphoneMember.number;
    if(f && f != nil){
//        [self.operationImage sd_setImageWithURL:[NSURL URLWithString:f.avatar]];
//        self.titleLabel.text = f.displayName;
        self.nameLabel.text = f.displayName.length > 2 ? [f.displayName substringToIndex:2] : f.displayName;
    }else{
//        self.operationImage.image = [UIImage circleImageWithColor:[UIColor colorWithHex:0xa0ceff] withSize:CGSizeMake(60, 60) withName:interphoneMember.number];
        self.nameLabel.text = interphoneMember.number.length > 2 ? [interphoneMember.number substringToIndex:2] : interphoneMember.number;
    }
    self.joinStatusLabel.hidden = NO;
    if(interphoneMember.isOnline){
        self.joinStatusLabel.backgroundColor = [UIColor colorWithHex:0x84fab0];
    }else
        self.joinStatusLabel.backgroundColor = [UIColor colorWithHex:0xb4b4b4];
}

- (void)setOperationInfo:(NSDictionary *)operationInfo{
    _operationInfo = operationInfo;
    self.nameLabel.hidden = YES;
    self.titleLabel.text = operationInfo[@"title"];
    self.operationImage.image = EC_Image_Named(operationInfo[@"image"]);
    self.operationImage.hidden = NO;
    self.videoPublishImage.hidden = YES;
}

#pragma mark - UI创建
- (void)buildUI{
    [self.contentView addSubview:self.operationImage];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.joinStatusLabel];
    [self.contentView addSubview:self.videoPublishImage];
    EC_WS(self)
    [self.operationImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(60);
        make.centerX.equalTo(weakSelf);
        make.top.equalTo(weakSelf);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(60);
        make.centerX.equalTo(weakSelf);
        make.top.equalTo(weakSelf);        
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.top.equalTo(weakSelf.operationImage.mas_bottom);
        make.bottom.equalTo(weakSelf.contentView);
    }];
    [self.joinStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.operationImage.mas_right).offset(-5);
        make.bottom.equalTo(weakSelf.operationImage.mas_bottom).offset(-5);
        make.width.height.offset(10);
    }];
    [self.videoPublishImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.operationImage.mas_right);
        make.bottom.equalTo(weakSelf.operationImage.mas_bottom);
        make.width.height.offset(20);
    }];
    self.nameLabel.ec_radius = 30;
}

- (UIImageView *)operationImage{
    if(!_operationImage){
        _operationImage = [[UIImageView alloc] init];
        _operationImage.layer.masksToBounds = YES;
        _operationImage.layer.cornerRadius = 30;
    }
    return _operationImage;
}

- (UILabel *)nameLabel{
    if(!_nameLabel){
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = EC_Font_System(17);
        _nameLabel.textColor = EC_Color_White;
        _nameLabel.backgroundColor = [UIColor colorWithHex:0xa0ceff];
        _nameLabel.text = @"邀请";
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}


- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = EC_Font_System(11);
        _titleLabel.textColor = [UIColor colorWithHex:0x666666];
        _titleLabel.text = @"邀请";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleLabel adjustsFontSizeToFitWidth];
    }
    return _titleLabel;
}

- (UIImageView *)videoPublishImage{
    if(!_videoPublishImage){
        _videoPublishImage = [[UIImageView alloc] init];
        _videoPublishImage.image = EC_Image_Named(@"opencamera");
        _videoPublishImage.hidden = YES;
    }
    return _videoPublishImage;
}

- (UILabel *)joinStatusLabel{
    if(!_joinStatusLabel){
        _joinStatusLabel = [[UILabel alloc] init];
        _joinStatusLabel.hidden = YES;
        _joinStatusLabel.ec_radius = 5;
    }
    return _joinStatusLabel;
}

@end
