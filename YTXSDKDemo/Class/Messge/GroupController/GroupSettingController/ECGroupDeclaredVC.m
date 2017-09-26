//
//  ECGroupNotice.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/26.
//
//

#import "ECGroupDeclaredVC.h"
#import "ECDemoGroupManage.h"

@interface ECGroupDeclaredVC ()<UITextViewDelegate,ECBaseContollerDelegate>
@property (nonatomic, assign) BOOL isModify;//创建群组、修改群公告公用页面，YES 修改公告、NO 创建群
@property (nonatomic, strong) ECGroup *group;//isModify = YES时，
@property (nonatomic, strong) UITextView *textView;
@end

@implementation ECGroupDeclaredVC

#pragma mark - ECBaseContollerDelegate
- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString *__autoreleasing *)str {
    *str = NSLocalizedString(@"保存", nil);
    if(self.isModify && self.group.selfRole != ECMemberRole_Creator)
        *str = @"";
    return ^id {
        if(self.isModify && self.group.selfRole == ECMemberRole_Creator) {
            NSString *declared = ([self.textView.text isEqualToString:NSLocalizedString(@"最多可输入100个字符",nil)] ? @"" : self.textView.text);
            if (![declared isEqualToString:self.group.declared] && declared.length >0) {
                self.group.declared = declared;
                EC_ShowHUD(@"保存中...")
                [[ECDevice sharedInstance].messageManager modifyGroup:self.group completion:^(ECError *error, ECGroup *group) {
                    EC_HideHUD
                    if(error.errorCode != ECErrorType_NoError) {
                        EC_Demo_AppLog(@"修改公告:%@",error.errorDescription ? error.errorDescription : @"")
                        [ECCommonTool toast:NSLocalizedString(@"保存失败", nil) ];
                    } else {
                        [ECCommonTool toast:NSLocalizedString(@"保存成功", nil) ];
                        [ECDemoGroupManage sharedInstanced].group.declared = self.group.declared;
                        [[ECDBManager sharedInstanced].groupInfoMgr insertGroup:group];
                    }
                }];
            } else {
                [ECCommonTool toast:NSLocalizedString(@"保存成功", nil) ];
            }
        } else {
            if(self.baseOneObjectCompletion)
                self.baseOneObjectCompletion([self.textView.text isEqualToString:NSLocalizedString(@"最多可输入100个字符",nil)] ? @"" : self.textView.text);
        }
        [self.navigationController popViewControllerAnimated:YES];
        return nil;
    };
}

#pragma mark - 类私有方法

#pragma mark - UITextView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if([textView.text isEqualToString:NSLocalizedString(@"最多可输入100个字符",nil)])
        textView.text = @"";
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if(textView.text.length == 0)
        textView.text = NSLocalizedString(@"最多可输入100个字符", nil);
}
#pragma mark - 创建UI
- (void)buildUI{
    self.baseDelegate = self;
    if ([self.basePushData isKindOfClass:[NSNumber class]])
        self.isModify = [self.basePushData boolValue];
    self.group = !self.isModify?self.group:[ECDemoGroupManage sharedInstanced].group;
    self.title = NSLocalizedString(@"公告", nil) ;
    [self.view addSubview:self.textView];
    [super buildUI];
}

#pragma mark - 懒加载
- (UITextView *)textView{
    if(!_textView){
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 16, EC_kScreenW, EC_kScreenW * 0.6)];
        _textView.delegate = self;
        _textView.textColor = EC_Color_Sec_Text;
        _textView.font = EC_Font_System(14);
        _textView.backgroundColor = EC_Color_White;
        _textView.text = NSLocalizedString(@"最多可输入100个字符",nil);
        _textView.editable = !(self.isModify && self.group && self.group.selfRole != ECMemberRole_Creator);
        if(self.group)
            _textView.text= self.group.declared;
    }
    return _textView;
}

@end
