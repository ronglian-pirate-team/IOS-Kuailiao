  //
//  ECInviteBottomView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/27.
//
//

#import "ECInviteBottomView.h"

@interface ECInviteBottomView()

@property (nonatomic, weak) UILabel *selectLabel;
@property (nonatomic, weak) UIButton *sureBtn;

@end

@implementation ECInviteBottomView

- (instancetype)init{
    if(self = [super init]){
        [self buildUI];
    }
    return self;
}

- (void)inviteAction{
    if(self.createGroup)
        self.createGroup();
}

- (void)setSelectCount:(NSInteger)selectCount{
    _selectCount = selectCount;
    self.selectLabel.text = [NSString stringWithFormat:@"已选择：%ld 人" , selectCount];
}

- (void)setOperationTitle:(NSString *)operationTitle{
    _operationTitle = operationTitle;
    [self.sureBtn setTitle:operationTitle forState:UIControlStateNormal];
}

#pragma mark - 创建UI
- (void)buildUI{
    self.backgroundColor = [UIColor colorWithHex:0xf8f8f8];
    UILabel *selectLabel = [[UILabel alloc] init];
    selectLabel.font = EC_Font_System(15);
    selectLabel.text = @"已选择：";
    selectLabel.textColor = [UIColor colorWithHex:0x38adff];
    [self addSubview:selectLabel];
    self.selectLabel = selectLabel;
    
    UIButton *inviteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    inviteBtn.ec_radius = 4;
    [inviteBtn setTitle:@"邀请" forState:UIControlStateNormal];
    inviteBtn.titleLabel.font = EC_Font_System(14);
    [inviteBtn setBackgroundColor:[UIColor colorWithHex:0x38adff]];
    [inviteBtn addTarget:self action:@selector(inviteAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:inviteBtn];
    self.sureBtn = inviteBtn;
    EC_WS(self)
    [selectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(15);
        make.top.equalTo(weakSelf).offset(18);
    }];
    [inviteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf).offset(-15);
        make.top.equalTo(weakSelf).offset(8);
        make.width.offset(78);
        make.height.offset(33);
    }];
}

@end
