//
//  ECChatMoreItemView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/2.
//
//

#import "ECChatMoreItemView.h"

@interface ECChatMoreItemView()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ECChatMoreItemView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self buildUI];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    [self.button addTarget:target action:action forControlEvents:controlEvents];
}

- (void)setType:(ECChatMoreItemViewType)type{
    _type = type;
    NSString *title = @"";
    NSString *imageName = @"";
    switch (type) {
        case ECChatMoreViewItemType_Photo:
            title = NSLocalizedString(@"相册",nil);
            imageName = @"chatIconXiangceNormal";
            break;
        case ECChatMoreViewItemType_Camera:
            title = NSLocalizedString(@"拍摄",nil);
            imageName = @"chatIconPaisheNormal";
            break;
        case ECChatMoreViewItemType_Video:
            title = NSLocalizedString(@"短视频",nil);
            imageName = @"chatIconDuanshipinNormal";
            break;
        case ECChatMoreViewItemType_Location:
            title = NSLocalizedString(@"定位",nil);
            imageName = @"chatIconDingweiNormal";
            break;
        case ECChatMoreViewItemType_RedPackage:
            title = NSLocalizedString(@"红包",nil);
            imageName = @"chatIconHongbaoNormal";
            break;
        case ECChatMoreViewItemType_ReadBurn:
            title = NSLocalizedString(@"阅后即焚",nil);
            imageName = @"chatIconFenshaoNormal";
            break;
        case ECChatMoreViewItemType_ChatVoice:
            title = NSLocalizedString(@"语音聊天",nil);
            imageName = @"chatIconYuyinliaotianNormal";
            break;
        case ECChatMoreViewItemType_ChatVideo:
            title = NSLocalizedString(@"视频聊天",nil);
            imageName = @"chatIconShipintonghuaNormal";
            break;
        default:
            break;
    }
    [self.button setImage:EC_Image_Named(imageName) forState:UIControlStateNormal];
    self.titleLabel.text = title;
}

#pragma mark - UI创建
- (void)buildUI{
    [self addSubview:self.button];
    [self addSubview:self.titleLabel];
    EC_WS(self)
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(53);
        make.centerX.equalTo(weakSelf);
        make.top.equalTo(weakSelf).offset(17);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.top.equalTo(weakSelf.button.mas_bottom).offset(10);
    }];
}

- (UIButton *) button{
    if (_button == nil) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_button addTarget:self action:@selector(moreItemAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (UILabel *) titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = EC_Font_System(12);
        _titleLabel.textColor = EC_Color_Black;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
@end
