//
//  ECGroupNotice.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/26.
//
//

#import "ECSignSetVC.h"

#define EC_Max_Txt_Length 30

@interface ECSignSetVC ()<UITextViewDelegate,ECBaseContollerDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *numberLabel;

@end

@implementation ECSignSetVC

- (void)viewDidLoad {
    self.baseDelegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:UITextViewTextDidChangeNotification object:self.textView];
    [super viewDidLoad];
}

#pragma mark - ECBaseContollerDelegate
- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString *__autoreleasing *)str {
    *str = NSLocalizedString(@"保存", nil);
    return ^id {
        if(!self.textView.text || self.textView.text.length == 0){
            [ECCommonTool toast:NSLocalizedString(@"签名未输入", nil)];
            return nil;
        }
        ECPersonInfo *person = [[ECPersonInfo alloc] init];
        person.nickName = [ECDevicePersonInfo sharedInstanced].nickName;
        person.sex = [ECDevicePersonInfo sharedInstanced].sex;
        person.birth = [ECDevicePersonInfo sharedInstanced].birth;
        person.sign = self.textView.text;
        EC_WS(self)
        [[ECDevice sharedInstance] setPersonInfo:person completion:^(ECError *error, ECPersonInfo *person) {
            if (error.errorCode == ECErrorType_NoError) {
                [ECDevicePersonInfo sharedInstanced].sign = weakSelf.textView.text;
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

#pragma mark - 类私有方法

#pragma mark - UITextView delegate
- (void)textViewEditChanged:(NSNotification *)obj{
    UITextView *textView = (UITextView *)obj.object;
    NSString *toBeString = textView.text;
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    if (!position){
        if (toBeString.length > EC_Max_Txt_Length){
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:EC_Max_Txt_Length];
            if (rangeIndex.length == 1){
                textView.text = [toBeString substringToIndex:EC_Max_Txt_Length];
            }else{
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, EC_Max_Txt_Length)];
                textView.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
    self.numberLabel.text = [NSString stringWithFormat:@"%ld/%d", textView.text.length,EC_Max_Txt_Length];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if([textView.text isEqualToString:NSLocalizedString(@"最多可输入30个字符",nil)])
        textView.text = @"";
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if(textView.text.length == 0){
        textView.text = NSLocalizedString(@"最多可输入30个字符", nil);
    }else{
    }
}
#pragma mark - 创建UI
- (void)buildUI{
    self.title = @"签名";
    [super buildUI];
    [self.view addSubview:self.textView];
    [self.view addSubview:self.numberLabel];
    if([ECDevicePersonInfo sharedInstanced].sign && [ECDevicePersonInfo sharedInstanced].sign.length > 0)
        _numberLabel.text = [NSString stringWithFormat:@"%ld/%d", [ECDevicePersonInfo sharedInstanced].sign.length, EC_Max_Txt_Length];
    EC_WS(self)
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.view).offset(-12);
        make.bottom.equalTo(weakSelf.textView).offset(0);
        make.width.offset(100);
        make.height.offset(20);
    }];
}

- (UITextView *)textView{
    if(!_textView){
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 16, EC_kScreenW, EC_kScreenW * 0.6)];
        _textView.delegate = self;
        _textView.textColor = EC_Color_Sec_Text;
        _textView.font = EC_Font_System(14);
        _textView.backgroundColor = EC_Color_White;
        _textView.text = NSLocalizedString(@"最多可输入30个字符",nil);
        if([ECDevicePersonInfo sharedInstanced].sign && [ECDevicePersonInfo sharedInstanced].sign.length > 0)
            _textView.text = [ECDevicePersonInfo sharedInstanced].sign;
    }
    return _textView;
}

- (UILabel *)numberLabel{
    if(!_numberLabel){
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.font = EC_Font_System(10);
        _numberLabel.textAlignment = NSTextAlignmentRight;
        _numberLabel.textColor = EC_Color_Sec_Text;
        _numberLabel.text = @"0/30";
    }
    return _numberLabel;
}

@end
