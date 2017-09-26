//
//  ECGroupDeclaredCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/27.
//
//

#import "ECGroupDeclaredCell.h"

@interface ECGroupDeclaredCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation ECGroupDeclaredCell

- (instancetype)initDeclared:(NSString *)groupDeclared reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]){
        _groupDeclared = groupDeclared;
        [self buildUI];
    }
    return self;
}

#pragma mark - 创建UI
- (void)buildUI{
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if(!_groupDeclared || _groupDeclared.length == 0)
        self.detailTextLabel.text = @"选填";
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.text = @"群组公告";
    self.textLabel.text = @"公告";
    self.textLabel.hidden = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:titleLabel];
    UILabel *groupDeclaredLabel = [[UILabel alloc] init];
    groupDeclaredLabel.textColor = EC_Color_Sec_Text;
    groupDeclaredLabel.font = EC_Font_System(16);
    groupDeclaredLabel.numberOfLines = 0;
    groupDeclaredLabel.text = _groupDeclared;
    [self.contentView addSubview:groupDeclaredLabel];
    EC_WS(self)
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.textLabel).offset(0);
        make.top.equalTo(weakSelf.contentView).offset(14);
        make.width.offset(200);
    }];
    [groupDeclaredLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView).offset(15);
        make.right.equalTo(weakSelf.contentView);
        make.top.equalTo(titleLabel.mas_bottom).offset(10);
        make.bottom.equalTo(weakSelf.contentView).offset(-10);
    }];
}

- (void)setIsDiscuss:(BOOL)isDiscuss {
    _isDiscuss = isDiscuss;
    _titleLabel.text = isDiscuss?@"讨论组公告":@"群组公告";
}
@end
