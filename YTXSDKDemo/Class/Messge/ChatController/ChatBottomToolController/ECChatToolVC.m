//
//  ECChatToolVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/2.
//
//

#import "ECChatToolVC.h"
#import "ECInputToolView.h"
#import "ECChatVoiceView.h"
#import <BQMM/BQMM.h>
#import <BQMM/MMTextParser.h>
#import "ECMessage+BQMMMessage.h"

#define EC_Voice_View_H 214

@implementation ECChatVCModel

@end

@interface ECChatToolVC ()<ECInputToolViewDelegate, ECChatMoreViewDelegate, MMEmotionCentreDelegate>{
    CGFloat EC_MoreView_H;
}

@property (nonatomic, strong) ECInputToolView *inputView;
@property (nonatomic, strong) ECChatMoreView *chatMoreView;
@property (nonatomic, strong) ECChatVoiceView *voiceView;
@property (nonatomic, assign) CGFloat keyBoardH;

@end

@implementation ECChatToolVC

- (instancetype)initWithModel:(ECChatVCModel *)model{
    if(self = [super init]){
        self.chatVCModel = model;
        if([self.chatVCModel.receiver hasPrefix:@"g"])
            EC_MoreView_H = 108;
        else
            EC_MoreView_H = 214;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    self.view.backgroundColor = EC_Color_White;
}

#pragma mark - ECInputToolView delegate
- (void)inputViewStatusChange:(ECInputToolStatus)status fromeStatus:(ECInputToolStatus)fromStatus{
    if(status == ECInputToolStatus_Normal){
        self.view.frame = CGRectMake(0, EC_kScreenH - self.inputView.ec_height, EC_kScreenW, self.inputView.ec_height);
        self.chatMoreView.ec_y = self.inputView.ec_height;
    }else if(status == ECInputToolStatus_TextEditing){
        if(fromStatus == ECInputToolStatus_Face)
            [[MMEmotionCentre defaultCentre] switchToDefaultKeyboard];
    }else if (status == ECInputToolStatus_More){
        if(!_chatMoreView)
            [self.view addSubview:self.chatMoreView];
        if(_voiceView)
            [UIView animateWithDuration:0.3 animations:^{
                _voiceView.ec_y = self.inputView.ec_height + EC_MoreView_H;
            }];
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, EC_kScreenH - self.inputView.ec_height - EC_MoreView_H, EC_kScreenW, self.inputView.ec_height + EC_MoreView_H);
            self.chatMoreView.ec_y = self.inputView.ec_height;
        }];
    }else if (status == ECInputToolStatus_Voice){
        if(!_voiceView)
            [self.view addSubview:self.voiceView];
        if(_chatMoreView)
            [UIView animateWithDuration:0.3 animations:^{
                _chatMoreView.ec_y = self.inputView.ec_height + EC_Voice_View_H;
            }];
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, EC_kScreenH - self.inputView.ec_height - EC_Voice_View_H, EC_kScreenW, self.inputView.ec_height + EC_Voice_View_H);
            self.voiceView.ec_y = self.inputView.ec_height;
        }];
    }else if (status == ECInputToolStatus_Face){
        if (!self.inputView.isFirstResponder) {
            [self.inputView becomeFirstResponder];
        }
        [MMEmotionCentre defaultCentre].delegate = self; //设置BQMM键盘delegate
        [[MMEmotionCentre defaultCentre] attachEmotionKeyboardToInput:self.inputView.inputTextView.internalTextView];
    }
    [self changeTableViewFrame];
}

- (void)inputToolView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height{
    self.view.frame = CGRectMake(0, EC_kScreenH - height - self.keyBoardH, EC_kScreenW, height);
    [self changeTableViewFrame];
}

#pragma mark - BQMM 表情代理
- (void)didSendWithInput:(UIResponder<UITextInput> *)input {
    ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:self.inputView.inputTextView.text];
    [[ECDeviceHelper sharedInstanced] ec_sendMessage:messageBody to:self.chatVCModel.receiver];
    self.inputView.inputTextView.text = @"";
}

- (void)didSelectEmoji:(MMEmoji *)emoji {
    [self sendEmoji:emoji];
}

- (void)didSelectTipEmoji:(MMEmoji *)emoji {
    [self sendEmoji:emoji];
    self.inputView.inputTextView.text = @"";
}

- (void)sendEmoji:(MMEmoji *)emoji{
    NSString *textString = [NSString stringWithFormat:@"[%@]",emoji.emojiName];
    NSDictionary *emojiDict = @{txt_msgType:@"facetype",faceEmojiArray:@[@[emoji.emojiCode,[NSString stringWithFormat:@"%d",[MMTextParser emojiTypeWithEmoji:emoji]]]]};
    NSData *emojiData = [NSJSONSerialization dataWithJSONObject:emojiDict options:NSJSONWritingPrettyPrinted error:nil];
    ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:textString];
    [[ECDeviceHelper sharedInstanced] ec_sendMessage:messageBody to:self.chatVCModel.receiver withUserData:[[NSString alloc] initWithData:emojiData encoding:NSUTF8StringEncoding]];
}

#pragma mark - 键盘监听事件
- (void) keyboardWillShow : (NSNotification*)notification{
    [self.view bringSubviewToFront:self.inputView];
    [[ECDeviceHelper sharedInstanced] ec_sendUserState:ECUserInputState_White to:self.chatVCModel.receiver];
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.view.frame = CGRectMake(0, EC_kScreenH - self.inputView.ec_height - keyboardFrame.size.height, EC_kScreenW, self.inputView.ec_height + EC_MoreView_H);
    [self changeTableViewFrame];
    self.keyBoardH = keyboardFrame.size.height;
}

- (void)keyboardWillHidden:(NSNotification *)notification{
    self.inputView.status = ECInputToolStatus_Normal;
}

#pragma mark - 退出键盘
- (void)scrollViewWillBeginDragging:(UIGestureRecognizer *)gesture {
    [UIView animateWithDuration:0.25 delay:0.0f options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.inputView.status = ECInputToolStatus_Normal;
        [self.inputView.inputTextView resignFirstResponder];
    } completion:nil];
}

- (void)changeTableViewFrame {
    CGRect frame = self.chatVCModel.tableView.frame;
    frame.size.height = self.view.ec_y;
    self.chatVCModel.tableView.frame = frame;
}
#pragma mark - UI创建
- (void)buildUI{
    [self.view addSubview:self.inputView];
    [self.view addSubview:self.chatMoreView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewWillBeginDragging:)];
    [self.chatVCModel.tableView addGestureRecognizer:tap];
    [super buildUI];
}

- (ECInputToolView *)inputView{
    if(!_inputView){
        _inputView = [[ECInputToolView alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, EC_InputView_H)];
        _inputView.receiver = self.chatVCModel.receiver;
        _inputView.delegate = self;
    }
    return _inputView;
}

- (ECChatMoreView *)chatMoreView{
    if(!_chatMoreView){
        _chatMoreView = [[ECChatMoreView alloc] initWithFrame:CGRectMake(0, EC_InputView_H, EC_kScreenW, EC_MoreView_H)];
        _chatMoreView.receiver = self.chatVCModel.receiver;
        _chatMoreView.type = [self.chatVCModel.receiver hasPrefix:@"g"] ? ECChatMoreViewType_Group : ECChatMoreViewType_Personal;
        _chatMoreView.delegate = self;
    }
    return _chatMoreView;
}

- (ECChatVoiceView *)voiceView{
    if(!_voiceView){
        _voiceView = [[ECChatVoiceView alloc] initWithFrame:CGRectMake(0, EC_InputView_H, EC_kScreenW, EC_Voice_View_H)];
        _voiceView.receiver = self.chatVCModel.receiver;
    }
    return _voiceView;
}

@end
