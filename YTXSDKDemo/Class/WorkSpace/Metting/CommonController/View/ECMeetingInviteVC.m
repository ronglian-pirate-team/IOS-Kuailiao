//
//  ECMeetingInviteVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/17.
//
//

#import "ECMeetingInviteVC.h"

@interface ECMeetingInviteVC ()

@property (nonatomic, strong) UITextField *textField;

@end

@implementation ECMeetingInviteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = (self.inviteType == 1 ? NSLocalizedString(@"VoIP邀请", nil) : NSLocalizedString(@"手机号码邀请", nil));
}

- (void)inviteAction:(UIButton *)sender{
    sender.enabled = NO;
    EC_ShowHUD(@"")
    [[ECDevice sharedInstance].meetingManager inviteMembersJoinMultiMediaMeeting:self.meetingNum andIsLoandingCall:self.inviteType == 2 andMembers:@[_textField.text] andDisplayNumber:nil andSDKUserData:self.meetingName andServiceUserData:nil completion:^(ECError *error, NSString *meetingNumber) {
        sender.enabled = YES;
        EC_HideHUD
        if(error.errorCode == ECErrorType_NoError){
            [self.navigationController popViewControllerAnimated:YES];
            if(self.inviteCompletion)
                self.inviteCompletion();
        }else{
            [ECCommonTool toast:error.errorDescription];
        }
    }];
}

- (void)buildUI{
    [self.view addSubview:self.textField];
    self.view.backgroundColor = EC_Color_White;
    UIButton *inviteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    inviteBtn.frame = CGRectMake(35, CGRectGetMaxY(self.textField.frame) + 50, self.textField.ec_width, 44);
    inviteBtn.backgroundColor = [UIColor colorWithHex:0x3cbaff];
    [inviteBtn setTitle:NSLocalizedString(@"邀请", nil) forState:UIControlStateNormal];
    [inviteBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
    inviteBtn.titleLabel.font = EC_Font_System(14);
    [inviteBtn addTarget:self action:@selector(inviteAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:inviteBtn];
    inviteBtn.ec_radius = 22;
}

- (UITextField *)textField{
    if(!_textField){
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(35, 80, EC_kScreenW - 70, 44)];
        _textField.placeholder = (self.inviteType == 1 ? NSLocalizedString(@"请输入被添加人的VoIP账号", nil) : NSLocalizedString(@"请输入被添加人的手机号码", nil));
        _textField.textColor = EC_Color_Main_Text;
        _textField.font = EC_Font_System(13);
        _textField.ec_radius = 22;
        _textField.backgroundColor = [UIColor colorWithHex:0xf1f4f8];
        UIView *leftV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 22, 44)];
        _textField.leftView = leftV;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _textField;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(self.inviteCompletion)
        self.inviteCompletion();
}

@end
