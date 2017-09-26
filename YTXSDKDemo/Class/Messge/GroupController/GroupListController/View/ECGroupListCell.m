//
//  ECGroupListCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/1.
//
//

#import "ECGroupListCell.h"

@interface ECGroupListCell()

@property (nonatomic, weak) UIImageView *portraitImg;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *idLabel;

@end

@implementation ECGroupListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.separatorInset = UIEdgeInsetsMake(0, 72, 0, -72);
        [self buildUI];
    }
    return self;
}
- (void)setGroup:(ECGroup *)group{
    _group = group;
    self.nameLabel.text = group.name;
    self.idLabel.text = [@"群组" stringByAppendingString:group.groupId];
    self.portraitImg.image = EC_Image_Named(group.isDiscuss ? @"addressbookIconTaolunzu" : @"addressbookIconQunzu");
}

- (void)buildUI{
    UIImageView *portraitImg = [[UIImageView alloc] init];
    portraitImg.image = EC_Image_Named(@"messageIconHeader");
    [self.contentView addSubview:portraitImg];
    self.portraitImg = portraitImg;
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = NSLocalizedString(@"云通讯讨论组",nil);
    nameLabel.textColor = EC_Color_Main_Text;
    nameLabel.font = EC_Font_System(16);
    [self.contentView addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    UILabel *idLabel = [[UILabel alloc] init];
    idLabel.text = NSLocalizedString(@"群组id", @"群组id");
    idLabel.textColor = EC_Color_Sec_Text;
    idLabel.font = EC_Font_System(13);
    [self.contentView addSubview:idLabel];
    self.idLabel = idLabel;
    EC_WS(self)
    [portraitImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.contentView).offset(12);
        make.top.equalTo(weakSelf.contentView).offset(8);
        make.width.height.offset(49);
    }];
    NSArray *array = [NSArray arrayWithObjects:nameLabel, idLabel, nil];
    [array mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:12 leadSpacing:15 tailSpacing:12];
    [array mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(portraitImg.mas_right).offset(11);
    }];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.contentView).offset(-15);
    }];

}

@end
