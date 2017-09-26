//
//  ECDemoLoginController.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/25.
//

#import "ECDemoLoginController.h"
#import "ECFriendManager.h"

#define EC_LOGIN_HEADBG_V 206.0f
#define EC_LOGIN_TEXTF_ACCOUNT_TOP 33.5f
#define EC_REGISTER_TEXTF_Margin 15.0f
#define EC_LOGIN_TEXTF_H 50.0f

@interface ECDemoLoginController ()
@property (nonatomic, strong) UIImageView *headBg;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UITextField *accountF;
@property (nonatomic, strong) UIButton *loginBtn;
@end

@implementation ECDemoLoginController

#pragma mark - 按钮事件
- (void)clickLoginBtn:(UIButton *)sender {
    
    NSString *userName = [_accountF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (userName.length == 0) {
        EC_AlterShow(NSLocalizedString(@"提示", nil),NSLocalizedString(@"账号为空", nil),NSLocalizedString(@"确定", nil))
        return;}
    
    [self.view endEditing:YES];
    [ECDevicePersonInfo sharedInstanced].userName = userName;
    [MBProgressHUD ec_ShowHUD:self.view withMessage:NSLocalizedString(@"正在登录...", nil)];
    [ECDevicePersonInfo sharedInstanced].userPassword = @"传入密码";
    EC_WS(self);
 
    [[ECDeviceHelper sharedInstanced] ec_loginECSdk:^(ECError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [[ECFriendManager sharedInstanced] fetchUserVerifyCompletion:nil];
        if (error.errorCode != ECErrorType_NoError) {
            [ECCommonTool toast:NSLocalizedString(@"登录失败", nil)];
            [ECDevicePersonInfo sharedInstanced].userPassword = nil;
        }
    }];
    
}
#pragma mark - UI创建
- (void)buildUI {
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    self.view.backgroundColor = EC_Color_VCbg;
    [self.view addSubview:self.headBg];
    [self.view addSubview:self.bottomView];
    [super buildUI];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma nark - 懒加载
- (UIImageView *)headBg {
    if (!_headBg) {
        _headBg = [[UIImageView alloc] init];
        _headBg.userInteractionEnabled = YES;
        _headBg.image = EC_Image_Named(@"wangjimima_backImage");
        _headBg.frame = (CGRect) {
            CGPointZero,
            self.view.ec_width,
            EC_LOGIN_HEADBG_V
        };
    }
    return _headBg;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.frame = (CGRect){
            0,
            CGRectGetMaxY(_headBg.frame),
            self.view.ec_width,
            self.view.ec_height - EC_LOGIN_HEADBG_V
        };
        [_bottomView addSubview:self.accountF];
        [_bottomView addSubview:self.loginBtn];
    }
    return _bottomView;
}

#pragma mark - 懒加载
- (UITextField *)accountF {
    if (!_accountF) {
        _accountF = [[UITextField alloc] init];
        _accountF.keyboardType = UIKeyboardTypeNumberPad;
        _accountF.text = [ECAppInfo sharedInstanced].userName;
        _accountF.placeholder = NSLocalizedString(@"请输入账号", nil);
        _accountF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _accountF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:_accountF.placeholder attributes:@{NSFontAttributeName:EC_Font_System(13.0f)}];
        _accountF.frame = (CGRect) {
            EC_REGISTER_TEXTF_Margin,
            EC_LOGIN_TEXTF_ACCOUNT_TOP,
            self.view.ec_width - EC_REGISTER_TEXTF_Margin * 2,
            EC_LOGIN_TEXTF_H
        };
    }
    return _accountF;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setTitle:NSLocalizedString(@"登录", nil) forState:UIControlStateNormal];
        [_loginBtn setTitle:NSLocalizedString(@"登录", nil) forState:UIControlStateHighlighted];
        [_loginBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
        [_loginBtn setTitleColor:EC_Color_White forState:UIControlStateHighlighted];
        _loginBtn.titleLabel.font = EC_Font_System(20.0f);
        [_loginBtn setBackgroundColor:EC_Color_Login_LoginBtn_BgHight];
        [_loginBtn addTarget:self action:@selector(clickLoginBtn:) forControlEvents:UIControlEventTouchUpInside];
        _loginBtn.layer.cornerRadius = 5.0f;
        _loginBtn.layer.masksToBounds = YES;
        _loginBtn.frame = (CGRect) {
            CGRectGetMinX(_accountF.frame),
            CGRectGetMaxY(_accountF.frame) + 25.0f,
            _accountF.ec_width,
            44.0f
        };
    }
    return _loginBtn;
}
@end
