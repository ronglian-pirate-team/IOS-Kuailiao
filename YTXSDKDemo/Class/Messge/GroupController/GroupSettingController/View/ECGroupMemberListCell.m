//
//  ECGroupMemberListCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/9/4.
//
//

#import "ECGroupMemberListCell.h"

@interface ECGroupMemberListCell()

@property (nonatomic, strong) UILabel *memberRoleLabel;

@end

@implementation ECGroupMemberListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self buildUI];
    }
    return self;
}

- (void)setGroupMember:(ECGroupMember *)groupMember{
    _groupMember = groupMember;
    if(groupMember.role == ECMemberRole_Creator){
        self.memberRoleLabel.hidden = NO;
        self.memberRoleLabel.backgroundColor = [UIColor colorWithHex:0xffd045];
        self.memberRoleLabel.text = NSLocalizedString(@"群主", nil);
    }else if (groupMember.role == ECMemberRole_Admin){
        self.memberRoleLabel.hidden = NO;
        self.memberRoleLabel.backgroundColor = [UIColor colorWithHex:0x6cd9a3];
        self.memberRoleLabel.text = NSLocalizedString(@"管理员", nil);
    }else{
        self.memberRoleLabel.hidden = YES;
    }
    self.textLabel.text = (groupMember.display && groupMember.display.length > 0) ? groupMember.display : groupMember.memberId;
    self.imageView.image = [UIImage ec_circleImageWithColor:EC_Color_App_Main withSize:CGSizeMake(60, 60) withName:self.textLabel.text];
    self.detailTextLabel.text = groupMember.memberId;
}

- (void)buildUI{
    [self.contentView addSubview:self.memberRoleLabel];
    EC_WS(self)
    [self.memberRoleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf);
        make.right.equalTo(weakSelf).offset(-30);
        make.width.offset(44);
        make.height.offset(18);
    }];
}

- (UILabel *)memberRoleLabel{
    if(!_memberRoleLabel){
        _memberRoleLabel = [[UILabel alloc] init];
        _memberRoleLabel.textColor = EC_Color_White;
        _memberRoleLabel.font = EC_Font_System(12);
        _memberRoleLabel.textAlignment = NSTextAlignmentCenter;
        _memberRoleLabel.ec_radius = 2;
    }
    return _memberRoleLabel;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 20;
    self.imageView.frame = CGRectMake(12, 7, 40, 40);
    self.imageView.center = CGPointMake(self.imageView.center.x, self.contentView.center.y);
    self.textLabel.ec_x = 64;
    self.detailTextLabel.ec_x = self.textLabel.ec_x;
    self.separatorInset = UIEdgeInsetsMake(0, 64, 0, 0);
}

@end
