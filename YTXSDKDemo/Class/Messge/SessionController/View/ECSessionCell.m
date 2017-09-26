//
//  ECSessionCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/25.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "ECSessionCell.h"
#import "NSString+ECUnitl.h"

@interface ECSessionCell()

@property (nonatomic, weak) UIImageView *portraitImg;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UIButton *unReadCountLabel;
@property (nonatomic, strong) UILabel *expandL;
@property (nonatomic, strong) UIView *changeView;
@property (nonatomic, strong) UIImageView *disturbImgV;
@property (nonatomic, strong) UIImageView *pushImgV;
@end

@implementation ECSessionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self buildUI];
        self.separatorInset = UIEdgeInsetsMake(0, 72, 0, -72);
    }
    return self;
}

- (void)setSession:(ECSession *)session{
    _session = session;
    if (session.isGroup) {
        BOOL isNoDisturb = [ECSession queryNoDisturbOptionOfSessionid:session.sessionId];
        session.isNoDisturb = isNoDisturb;
        _unReadCountLabel.hidden = isNoDisturb || session.unreadCount == 0;
        _pushImgV.hidden = !isNoDisturb;
        _disturbImgV.hidden = !isNoDisturb;
    } else {
        _unReadCountLabel.hidden = (session.unreadCount <= 0);
        _pushImgV.hidden = YES;
        _disturbImgV.hidden = YES;
    }
    
    NSString *unreadStr = [NSString stringWithFormat:@"%d", (int)session.unreadCount];
    if (session.unreadCount >99)
        unreadStr = [NSString stringWithFormat:@"99+"];
    [_unReadCountLabel setTitle:unreadStr forState:UIControlStateNormal];
    _nameLabel.text = session.sessionName;
    _contentLabel.text = session.text;
    _timeLabel.text = [NSString dateTime:session.dateTime];
    self.backgroundColor = session.isTop?[UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1]:[UIColor clearColor];
    NSString *imgStr = @"messageIconHeader";
    if (_session.type == EC_Session_Type_Group) {
        imgStr = @"messageIconQunzu";
    } else if (_session.type == EC_Session_Type_Discuss) {
        imgStr = @"messageIconTaolun";
    } else if (_session.type == EC_Session_Type_System) {
        imgStr = @"messageIconTongzhi";
    }
    self.portraitImg.image = EC_Image_Named(imgStr);
    if(_session.type == EC_Session_Type_One){
        [self.portraitImg sd_setImageWithURL:[NSURL URLWithString:_session.avatar] placeholderImage:EC_Image_Named(imgStr)];
    }
    [_expandL sizeToFit];
    CGFloat width = _expandL.ec_width;
    [_expandL mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.offset(session.isAt?width:0);
    }];
    _expandL.hidden = !session.isAt;
}

- (void)buildUI{
    UIImageView *portraitImg = [[UIImageView alloc] init];
    portraitImg.image = EC_Image_Named(@"messageIconHeader");
    [self.contentView addSubview:portraitImg];
    self.portraitImg = portraitImg;
    
    _expandL = [[UILabel alloc] init];
    _expandL.textColor = [UIColor redColor];
    _expandL.text = @"[有人@我]";
    _expandL.backgroundColor = [UIColor clearColor];
    _expandL.font = [UIFont systemFontOfSize:13.0f];
    _expandL.textAlignment = NSTextAlignmentCenter;
    _expandL.hidden = YES;
    [_expandL sizeToFit];
    [self.contentView addSubview:_expandL];
    
    _disturbImgV = [[UIImageView alloc] initWithImage:EC_Image_Named(@"UN_ReadMsg")];
    [_disturbImgV sizeToFit];
    _disturbImgV.hidden = YES;
    [self.contentView addSubview:_disturbImgV];

    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = NSLocalizedString(@"云通讯讨论组",nil);
    nameLabel.textColor = EC_Color_Main_Text;
    nameLabel.font = EC_Font_System(16);
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.text = NSLocalizedString(@"查看明细",nil);
    contentLabel.textColor = EC_Color_Sec_Text;
    contentLabel.font = EC_Font_System(13);
    [self.contentView addSubview:contentLabel];
    self.contentLabel = contentLabel;
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textColor = EC_Color_Sec_Text;
    timeLabel.font = EC_Font_System(12);
    timeLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    _changeView = [[UIView alloc] init];
    [self.contentView addSubview:_changeView];
    
    UIButton *unReadCountLabel = [UIButton buttonWithType:UIButtonTypeCustom];//[[UILabel alloc] init];
    [unReadCountLabel setTitleColor:EC_Color_White forState:UIControlStateNormal];
    [unReadCountLabel setTitle:@"1" forState:UIControlStateNormal];
    unReadCountLabel.titleLabel.font = EC_Font_System(10);
    [unReadCountLabel setBackgroundImage:EC_Image_Named(@"messageIconHuibiao") forState:UIControlStateNormal];
    [self.changeView addSubview:unReadCountLabel];
    self.unReadCountLabel = unReadCountLabel;
    
    _pushImgV = [[UIImageView alloc] initWithImage:EC_Image_Named(@"chat_group_notpush")];
    _pushImgV.hidden = YES;
    [self.changeView addSubview:_pushImgV];

    EC_WS(self)
    [portraitImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView).offset(12);
        make.top.equalTo(weakSelf.contentView).offset(8);
        make.width.height.offset(49);
    }];
    portraitImg.ec_radius = 49.0 / 2;
    [_disturbImgV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(portraitImg.mas_right).offset(-10.0f);
        make.centerY.equalTo(portraitImg.mas_top).offset(5.0f);
    }];
    
    NSArray *expandArray = [NSArray arrayWithObjects:nameLabel, _expandL, nil];
    [expandArray mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:12 leadSpacing:15 tailSpacing:12];
    NSArray *array = [NSArray arrayWithObjects:nameLabel, contentLabel, nil];
    [array mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:12 leadSpacing:15 tailSpacing:12];
    [expandArray mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(portraitImg.mas_right).offset(11);
    }];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.contentView).offset(-12);
        make.top.equalTo(nameLabel.mas_top);
    }];
    [_changeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.contentView).offset(-12);
        make.top.equalTo(timeLabel.mas_bottom).offset(12);
        make.width.height.offset(15);
    }];
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.changeView.mas_left).offset(-10);
        make.left.equalTo(weakSelf.expandL.mas_right).offset(0);
    }];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(timeLabel.mas_left).offset(-10);
    }];
    
    [unReadCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.changeView);
    }];
    [_pushImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.changeView);
    }];

}

@end
