//
//  ECRemarkSetVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/23.
//
//

#import "ECRemarkSetVC.h"
#import "ECFriendManager.h"

@interface ECRemarkSetVC ()<ECBaseContollerDelegate>

@property (nonatomic, strong) UITextField *textField;

@end

@implementation ECRemarkSetVC

- (void)viewDidLoad {
    self.baseDelegate = self;
    [super viewDidLoad];
}

- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString *__autoreleasing *)str{
    *str = NSLocalizedString(@"保存", nil);
    return ^id {
        if(!self.textField.text || self.textField.text.length == 0){
            [ECCommonTool toast:NSLocalizedString(@"备注未输入", nil)];
            return nil;
        }
        [[ECFriendManager sharedInstanced] remarkFriend:self.friendInfo.useracc remarkName:self.textField.text completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_UpdateFriendRemark object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        return nil;
    };
}

#pragma mark - UI 创建
- (void)buildUI{
    [super buildUI];
    self.title = NSLocalizedString(@"备注名", nil);
    [self.view addSubview:self.textField];
    EC_WS(self)
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(80);
        make.left.right.equalTo(weakSelf);
        make.height.offset(50);
    }];
}

- (UITextField *)textField{
    if(!_textField){
        _textField = [[UITextField alloc] init];
        _textField.clearButtonMode  = UITextFieldViewModeWhileEditing;
        _textField.borderStyle = UITextBorderStyleLine;
        _textField.background = [UIImage ec_imageWithColor:EC_Color_White];
        _textField.placeholder = @"备注";
        _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.font = EC_Font_System(15);
        if(self.friendInfo.remarkName && self.friendInfo.remarkName.length > 0)
            _textField.text = self.friendInfo.remarkName;
    }
    return _textField;
}

@end
