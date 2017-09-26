//
//  ECLiveChatRoomCell.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/18.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ECLiveChatRoomCell.h"
@interface LiveChatRoomAuthorityView : UIView
@property (nonatomic, strong) UILabel *textL;
@end

@implementation LiveChatRoomAuthorityView
- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor greenColor];
        [self addSubview:self.textL];
        self.layer.cornerRadius = 3;
        self.layer.masksToBounds = YES;
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self.textL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (UILabel *)textL {
    if (!_textL) {
        _textL = [[UILabel alloc] init];
        _textL.font = [UIFont systemFontOfSize:13.0f];
        _textL.textColor = [UIColor whiteColor];
        _textL.textAlignment = NSTextAlignmentCenter;
    }
    return _textL;
}
@end

@interface ECLiveChatRoomCell ()
@property (nonatomic, strong) UILabel *nickL;
@property (nonatomic, strong) UILabel *contentL;
@property (nonatomic, strong) LiveChatRoomAuthorityView *authV;
@end

@implementation ECLiveChatRoomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    [self.contentView addSubview:self.authV];
    [self.contentView addSubview:self.nickL];
    [self.contentView addSubview:self.contentL];
    self.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.34f];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSString *nickName = self.nickL.text;
    if(nickName.length > 6)
        nickName = [nickName substringToIndex:6];
    CGSize size = [nickName sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]}];
    self.authV.frame = CGRectMake(2, 5, 40, 20);
    self.nickL.frame = CGRectMake(CGRectGetMaxX(self.authV.frame), 5, size.width+15, 20);
    self.contentL.frame = CGRectMake(CGRectGetMaxX(self.nickL.frame), 0, self.frame.size.width-CGRectGetMaxX(self.nickL.frame), self.frame.size.height);
    CGPoint authP = self.authV.center;
    authP.y = self.nickL.center.y;
    self.authV.center = authP;
    if ([self.nickL.text isEqualToString:@"系统通知:"]) {
        self.contentL.textColor = [UIColor colorWithHex:0x658f00 alpha:1.0];
    } else {
        self.contentL.textColor = [UIColor whiteColor];
    }
}

- (void)bindData:(ECMessage *)msg {
    self.nickL.text = [NSString stringWithFormat:@"%@:",msg.senderName.length==0?msg.from:msg.senderName];
    ECTextMessageBody *body = (ECTextMessageBody *)msg.messageBody;
    self.contentL.text = body.text;
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_ec_livechat_nickcolor",self.nickL.text]];
    NSArray *array = @[@"",@"0x658f00",@"0x632e9e",@"0x003670",@"0x126663"];
    if (count<=0) {
        count = arc4random() % array.count;
        count = count==0?1:count;
        [[NSUserDefaults standardUserDefaults] setInteger:count forKey:[NSString stringWithFormat:@"%@_ec_livechat_nickcolor",self.nickL.text]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    UIColor *color = [UIColor colorWithHex:[array[count] intValue] alpha:1.0];
    _nickL.textColor = color;
}

#pragma mark - 懒加载

-(LiveChatRoomAuthorityView *)authV {
    if (!_authV) {
        _authV = [[LiveChatRoomAuthorityView alloc] init];
        _authV.textL.text = @"LV2";
    }
    return _authV;
}

- (UILabel *)nickL {
    if (!_nickL) {
        _nickL = [[UILabel alloc] init];
    }
    return _nickL;
}

- (UILabel *)contentL {
    if (!_contentL) {
        _contentL = [[UILabel alloc] init];
        _contentL.numberOfLines = 0;
        _contentL.textColor = [UIColor whiteColor];
    }
    return _contentL;
}

@end


