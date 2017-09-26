//
//  ECRemarkSetVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/23.
//
//

#import "ECGroupNameUpdateVC.h"
#import "ECDemoGroupManage.h"

@interface ECGroupNameUpdateVC ()<ECBaseContollerDelegate>
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) ECGroup *group;
@end

@implementation ECGroupNameUpdateVC

- (void)viewDidLoad {
    self.baseDelegate = self;
    [super viewDidLoad];
}

- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString *__autoreleasing *)str{
    *str = NSLocalizedString(@"保存", nil);
    return ^id{
        if(!self.textField.text || self.textField.text.length == 0){
            [ECCommonTool toast:NSLocalizedString(@"名称未输入", nil)];
            return nil;
        }
        self.group.name = self.textField.text;
        EC_Demo_AppLog(@"%@==%@", self.group.province, self.group.city);
        EC_ShowHUD(@"")
        [[ECDevice sharedInstance].messageManager modifyGroup:self.group completion:^(ECError *error, ECGroup *group) {
            EC_HideHUD;
            if(error.errorCode != ECErrorType_NoError){
                [ECCommonTool toast:error.errorDescription ? error.errorDescription : @""];
            } else{
                [ECDemoGroupManage sharedInstanced].group.name = group.name;
                if(self.baseOneObjectCompletion)
                    self.baseOneObjectCompletion(group.name);
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        return nil;
    };
}

#pragma mark - UI 创建
- (void)buildUI{
    [super buildUI];
    self.group = [[ECDBManager sharedInstanced].groupInfoMgr selectGroupOfGroupId:[ECDemoGroupManage sharedInstanced].group.groupId];
    NSString *changeTitle = self.group.isDiscuss?NSLocalizedString(@"讨论组",nil):NSLocalizedString(@"群组",nil);
    self.title = [NSString stringWithFormat:@"%@%@",changeTitle,NSLocalizedString(@"名称",nil)];
    [self.view addSubview:self.textField];
}

- (UITextField *)textField{
    if(!_textField){
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, EC_kScreenW, 50)];
        _textField.clearButtonMode  = UITextFieldViewModeWhileEditing;
        _textField.borderStyle = UITextBorderStyleLine;
        _textField.background = [UIImage ec_imageWithColor:EC_Color_White];
        _textField.placeholder = @"群组名称";
        _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.font = EC_Font_System(15);
        _textField.text = [ECDemoGroupManage sharedInstanced].group.name;
    }
    return _textField;
}

@end
