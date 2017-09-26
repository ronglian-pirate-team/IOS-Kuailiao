//
//  ECInputToolView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/2.
//
//

#import "ECInputToolView.h"
#import "HPGrowingTextView.h"
#import "ECMainTabbarVC.h"

#define EC_TOOLVIEE_SAPCE 9
#define EC_ToolBtn_SIZE 28
#define EC_BTN_MARGN ((50 - 28) / 2)
#define EC_ToolText_H 33
#define EC_TEXT_MARGN_TOP ((50 - 33) / 2)
#define EC_TEXT_MARGN_LEFT (EC_ToolBtn_SIZE + EC_TOOLVIEE_SAPCE * 2)
#define EC_TEXT_W (EC_kScreenW - EC_ToolBtn_SIZE * 3 - EC_TOOLVIEE_SAPCE * 5)

@interface ECInputToolView()<HPGrowingTextViewDelegate>

@property (nonatomic, strong) UIButton *voiceButton;//语音
@property (nonatomic, strong) UIButton *faceButton;//表情
@property (nonatomic, strong) UIButton *moreButton;//更多 +

@property (nonatomic, copy) NSString *deleteAtStr;
@property (nonatomic, strong) NSMutableArray *atMemberArray;

@end

@implementation ECInputToolView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        char myBuffer[4] = {'\xe2','\x80','\x85',0};
        _deleteAtStr = [NSString stringWithCString:myBuffer encoding:NSUTF8StringEncoding];
        _atMemberArray = [NSMutableArray array];
        [self buildUI];
        self.backgroundColor = EC_Color_White;
    }
    return self;
}

- (void)setStatus:(ECInputToolStatus)status{
    ECInputToolStatus fromeStatus = _status;
    _status = status;
    [[ECDeviceHelper sharedInstanced]  ec_sendUserState:status == ECInputToolStatus_TextEditing ? ECUserInputState_White : ECUserInputState_None to:self.receiver];
    if(status != ECInputToolStatus_Face && status != ECInputToolStatus_TextEditing)
        [self.inputTextView resignFirstResponder];
    else
        [self.inputTextView becomeFirstResponder];
    if([self.delegate respondsToSelector:@selector(inputViewStatusChange:fromeStatus:)]){
        [self.delegate inputViewStatusChange:status fromeStatus:fromeStatus];
    }
    switch (status) {
        case ECInputToolStatus_Normal:
            break;
        case ECInputToolStatus_TextEditing:
        case ECInputToolStatus_More:
            [_voiceButton setImage:EC_Image_Named(@"chatIconYuyinNormal") forState:UIControlStateNormal];
            [_faceButton setImage:EC_Image_Named(@"chatIconBiaoqingNormal") forState:UIControlStateNormal];
            break;
        case ECInputToolStatus_Voice:
            [_voiceButton setImage:EC_Image_Named(@"chatIconUnInputNormal") forState:UIControlStateNormal];
            [_faceButton setImage:EC_Image_Named(@"chatIconBiaoqingNormal") forState:UIControlStateNormal];
            break;
        case ECInputToolStatus_Face:
            [_voiceButton setImage:EC_Image_Named(@"chatIconYuyinNormal") forState:UIControlStateNormal];
            [_faceButton setImage:EC_Image_Named(@"chatIconUnInputNormal") forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

#pragma mark - 按钮事件 录音、表情、更多
- (void)voiceBtnAction{
    self.status = (self.status != ECInputToolStatus_Voice ? ECInputToolStatus_Voice : ECInputToolStatus_TextEditing);
}

- (void)faceBtnAction{
    self.status = (self.status != ECInputToolStatus_Face ? ECInputToolStatus_Face : ECInputToolStatus_TextEditing);
}

- (void)moreBtnAction{
    self.status = (self.status != ECInputToolStatus_More ? ECInputToolStatus_More : ECInputToolStatus_TextEditing);
}

#pragma mark - HPGrowingTextView delegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    self.frame = CGRectMake(self.ec_x,  0, self.ec_width, height + 16);
    if([self.delegate respondsToSelector:@selector(inputToolView:willChangeHeight:)])
        [self.delegate inputToolView:growingTextView willChangeHeight:height+16];
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){
        NSMutableCharacterSet *set = [NSMutableCharacterSet whitespaceCharacterSet];
        [set removeCharactersInString:_deleteAtStr];
        NSString * textString = [growingTextView.text stringByTrimmingCharactersInSet:set];
        if(textString.length == 0){
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"不能发送空白消息", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:growingTextView.text];
        [[ECDeviceHelper sharedInstanced] ec_sendMessage:messageBody to:self.receiver withUserData:nil atArray:self.atMemberArray];
        growingTextView.text = @"";
        return NO;
    }
    if ([self.receiver hasPrefix:@"g"] && [text isEqualToString:@"@"]) {
        if([[AppDelegate sharedInstanced].window.rootViewController isKindOfClass:[UITabBarController class]]){
            ECMainTabbarVC *tabbarVC = (ECMainTabbarVC *)[AppDelegate sharedInstanced].window.rootViewController;
            UINavigationController *nv = tabbarVC.selectedViewController;
            if(![nv.visibleViewController isKindOfClass:[NSClassFromString(@"ECGroupMemberListVC") class]]){
                UIViewController *membersListVC = [[NSClassFromString(@"ECGroupMemberListVC") alloc] initWithBaeOneObjectCompletion:^(ECGroupMember *member) {
                    NSString *name = @"";
                    if (member.display){
                        name = member.display;
                    }else if (member.memberId){
                        name = member.memberId;
                    }
                    [_atMemberArray addObject:member.memberId];
                    growingTextView.text = [growingTextView.text stringByAppendingString:[name stringByAppendingString:self.deleteAtStr]];
                }];
                [nv ec_pushViewController:membersListVC animated:YES data:self.receiver];
            }
        }
    }
    NSString *frontStr = [growingTextView.text substringToIndex:range.location+range.length];
    if ([self.receiver hasPrefix:@"g"] && [frontStr hasSuffix:_deleteAtStr] && [text isEqualToString:@""]) {
        NSArray *array = [frontStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:_deleteAtStr]];
        if (array.count>0 && _atMemberArray.count!=0) {
            [_atMemberArray removeObjectAtIndex:array.count - 2];
        }
        NSRange startRange = [growingTextView.text rangeOfString:@"@" options:NSBackwardsSearch range:NSMakeRange(0, range.location)];
        if (startRange.length==0) {
            return YES;
        }
        growingTextView.text = [growingTextView.text stringByReplacingCharactersInRange:NSMakeRange(startRange.location, range.location-startRange.location+range.length) withString:@""];
        return NO;
    }
    return YES;
}

#pragma mark - 创建UI
- (void)buildUI{
    self.backgroundColor = [UIColor redColor];
    [self addSubview:self.voiceButton];
    [self addSubview:self.faceButton];
    [self addSubview:self.moreButton];
//    [self addSubview:self.textView];
    [self addSubview:self.inputTextView];
    EC_WS(self)
    [@[self.faceButton, self.moreButton] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(EC_ToolBtn_SIZE);
        make.bottom.equalTo(weakSelf).offset(-10);
    }];
    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(EC_ToolBtn_SIZE + 2);
        make.left.equalTo(weakSelf).offset(EC_TOOLVIEE_SAPCE);
        make.bottom.equalTo(weakSelf).offset(-10);
    }];
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf).offset(-EC_TOOLVIEE_SAPCE);
    }];
    [self.faceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.moreButton.mas_left).offset(-EC_TOOLVIEE_SAPCE);
    }];
}

- (UIButton *)voiceButton{
    if(!_voiceButton){
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_voiceButton setImage:EC_Image_Named(@"chatIconYuyinNormal") forState:UIControlStateNormal];
        [_voiceButton addTarget:self action:@selector(voiceBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}

- (HPGrowingTextView *)inputTextView{
    if(!_inputTextView){
        _inputTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(EC_TEXT_MARGN_LEFT, EC_TEXT_MARGN_TOP, EC_TEXT_W, EC_ToolText_H)];
        _inputTextView.backgroundColor = EC_Color_ChatInputView_Bg;
        _inputTextView.ec_radius = 5.0f;
        _inputTextView.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
        _inputTextView.minNumberOfLines = 1;
        _inputTextView.maxNumberOfLines = 4;
        _inputTextView.returnKeyType = UIReturnKeySend;
        _inputTextView.font = [UIFont systemFontOfSize:15.0f];
        _inputTextView.delegate = self;
        _inputTextView.placeholder = @"添加文本";
        _inputTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _inputTextView;
}

- (UIButton *)faceButton{
    if(!_faceButton){
        _faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_faceButton setImage:EC_Image_Named(@"chatIconBiaoqingNormal") forState:UIControlStateNormal];
        [_faceButton addTarget:self action:@selector(faceBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceButton;
}

- (UIButton *)moreButton{
    if(!_moreButton){
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreButton setImage:EC_Image_Named(@"chatIconGengduoNormal") forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(moreBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

@end
