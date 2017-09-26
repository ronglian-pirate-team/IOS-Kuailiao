//
//  ECRemarkSetVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/23.
//
//

#import "ECNickNameSetVC.h"

#define EC_Name_Length 15

@interface ECNickNameSetVC ()<ECBaseContollerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@end

@implementation ECNickNameSetVC

- (void)viewDidLoad {
    self.baseDelegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:UITextFieldTextDidChangeNotification object:self.textField];
    [super viewDidLoad];
}

- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString *__autoreleasing *)str{
    *str = NSLocalizedString(@"保存", nil);
    return ^id{
        if(!self.textField.text || self.textField.text.length == 0){
            [ECCommonTool toast:NSLocalizedString(@"昵称未输入", nil)];
            return nil;
        }
        ECPersonInfo *person = [[ECPersonInfo alloc] init];
        person.nickName = self.textField.text;
        person.sex = [ECDevicePersonInfo sharedInstanced].sex;
        person.birth = [ECDevicePersonInfo sharedInstanced].birth;
        person.sign = [ECDevicePersonInfo sharedInstanced].sign;
        EC_WS(self)
        [[ECDevice sharedInstance] setPersonInfo:person completion:^(ECError *error, ECPersonInfo *person) {
            if (error.errorCode == ECErrorType_NoError) {
                [ECDevicePersonInfo sharedInstanced].nickName = weakSelf.textField.text;
                [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_UpdateSelfInfo object:nil];
                [ECDevicePersonInfo sharedInstanced].dataVersion = person.version;
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } else {
                NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
                [ECCommonTool toast:detail];
            }
        }];
        return nil;
    };
}

- (void)textFieldEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if (!position){
        if (toBeString.length > EC_Name_Length){
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:EC_Name_Length];
            if (rangeIndex.length == 1){
                textField.text = [toBeString substringToIndex:EC_Name_Length];
            }else{
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, EC_Name_Length)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
}

#pragma mark - UI 创建
- (void)buildUI{
    [super buildUI];
    self.title = NSLocalizedString(@"昵称", nil);
    [self.view addSubview:self.textField];
}

- (UITextField *)textField{
    if(!_textField){
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 80, EC_kScreenW, 50)];
        _textField.clearButtonMode  = UITextFieldViewModeWhileEditing;
        _textField.borderStyle = UITextBorderStyleLine;
        _textField.background = [UIImage ec_imageWithColor:EC_Color_White];
        _textField.placeholder = @"昵称";
        _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 1)];
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.font = EC_Font_System(15);
        _textField.delegate = self;
        _textField.text = [ECDevicePersonInfo sharedInstanced].nickName;
    }
    return _textField;
}

@end
