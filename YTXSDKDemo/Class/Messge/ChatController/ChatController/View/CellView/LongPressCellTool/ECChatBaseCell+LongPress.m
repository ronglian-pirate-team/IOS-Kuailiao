//
//  ECChatBaseCell+LongPress.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/10.
//

#import "ECChatBaseCell+LongPress.h"
#import <ShareSDK/ShareSDK.h>
#import "ECChatCellMacros.h"
#import "ECChatCellUtil.h"
#import "ECChatBlockTool.h"
#import "ECTransmitMessageController.h"

@implementation ECChatBaseCell (LongPress)
- (void)showMenuViewController:(UIView *)showInView message:(ECMessage*)message {
    if (_menuController == nil)
        _menuController = [UIMenuController sharedMenuController];
    if (_copyMenuItem == nil)
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuAction:)];
    if (_deleteMenuItem == nil)
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMenuAction:)];
    if (_transmitMenuItem == nil)
        _transmitMenuItem = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(transmitAction:)];
    if (_shareMenuItem == nil)
        _shareMenuItem = [[UIMenuItem alloc] initWithTitle:@"分享" action:@selector(shareAction:)];
    if (_revokeMenuItem == nil)
        _revokeMenuItem = [[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(revokeAction:)];
    MessageBodyType messageType = message.messageBody.messageBodyType;
    if (messageType == MessageBodyType_Text) {
        [_menuController setMenuItems:@[_copyMenuItem,_deleteMenuItem,_transmitMenuItem]];
        
    } else if (messageType== MessageBodyType_Image || messageType==MessageBodyType_Preview) {
        // 检测是否安装了微信
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
            [_menuController setMenuItems:@[_deleteMenuItem, _transmitMenuItem, _shareMenuItem]];
        } else {
            [_menuController setMenuItems:@[_deleteMenuItem, _transmitMenuItem]];
        }
        
    } else {
        [_menuController setMenuItems:@[_deleteMenuItem, _transmitMenuItem]];
    }
    
    NSTimeInterval tmp = [[NSDate date] timeIntervalSince1970]*1000;
    NSInteger count = tmp - message.timestamp.longLongValue;
    if (message.messageState == ECMessageState_SendSuccess && count<= [ECDeviceDelegateConfigCenter sharedInstanced].chat_RevokeMessageTime && ![message.from isEqualToString:message.to]) {
        NSMutableArray *arr = [_menuController.menuItems mutableCopy];
        [arr addObject:_revokeMenuItem];
        _menuController.menuItems = arr;
    }
    
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

- (void)copyMenuAction:(UIMenuController *)menuVC {
    EC_Demo_AppLog(@"%s",__func__);
    if ([self.message.messageBody isKindOfClass:[ECTextMessageBody class]]) {
        ECTextMessageBody *textBody = (ECTextMessageBody *)self.message.messageBody;
        [UIPasteboard generalPasteboard].string = textBody.text;
    }
}

- (void)deleteMenuAction:(UIMenuController *)menuVC {
    EC_Demo_AppLog(@"%s",__func__);
    ECMessage *message = self.message;
    [[ECChatCellUtil sharedInstanced] ec_stopVoiceWithMsg:message];
    if ([ECChatBlockTool sharedInstanced].ec_deleteCellBlock)
        [ECChatBlockTool sharedInstanced].ec_deleteCellBlock(message);
}

- (void)transmitAction:(UIMenuController *)menuVC {
    EC_Demo_AppLog(@"%s",__func__);
    ECTransmitMessageController *vc = [[ECTransmitMessageController alloc] initWithMessage:self.message];
    [[AppDelegate sharedInstanced].rootNav pushViewController:vc animated:YES];
}

- (void)shareAction:(UIMenuController *)menuVC {
    EC_Demo_AppLog(@"%s",__func__);
    ECMessage *message = self.message;
    if (message.messageState==ECMessageState_SendFail) {
        return;
    }
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *text = @"";
    NSString *title = @"";
    NSString *url = @"";
    UIImage *thumbImage = [[UIImage alloc] init];
    UIImage *img = [[UIImage alloc] init];
    switch (message.messageBody.messageBodyType) {
        case MessageBodyType_Image: {
            ECImageMessageBody *imageBody = (ECImageMessageBody*)message.messageBody;
            img = [UIImage imageWithContentsOfFile:imageBody.localPath];
            [parameters SSDKSetupShareParamsByText:nil images:img url:[NSURL URLWithString:imageBody.remotePath] title:nil type:SSDKContentTypeImage];
        }
            break;
        case MessageBodyType_Preview: {
            ECPreviewMessageBody *previewBody = (ECPreviewMessageBody*)message.messageBody;
            text = previewBody.desc;
            title = previewBody.title;
            url = previewBody.url;
            thumbImage = [UIImage imageWithContentsOfFile:previewBody.thumbnailLocalPath];
            img = [UIImage imageWithContentsOfFile:previewBody.localPath];
            [parameters SSDKSetupShareParamsByText:text images:thumbImage?:img url:[NSURL URLWithString:url] title:title type:SSDKContentTypeAuto];
        }
            break;
        default:
            break;
    }
    
    [ShareSDK share:SSDKPlatformSubTypeWechatSession parameters:parameters onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        switch (state) {
            case SSDKResponseStateSuccess:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
                break;
            }
            case SSDKResponseStateFail:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败" message:[NSString stringWithFormat:@"%@",error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                break;
            }
            default:
                break;
        }
    }];
}

- (void)revokeAction:(UIMenuController *)menuVC {
    EC_Demo_AppLog(@"%s",__func__);
    ECMessage *message = self.message;
    [[ECChatCellUtil sharedInstanced] ec_stopVoiceWithMsg:message];
    [[ECDevice sharedInstance].messageManager revokeMessage:message completion:^(ECError *error, ECMessage *message) {
        EC_Demo_AppLog(@"%@",[NSString stringWithFormat:@"错误码:%d",(int)error.errorCode]);
        if (error.errorCode == ECErrorType_NoError) {
    ECMessage *amessage = [ECRevokeMessageBody sendDefaultRevokeMessage:message];
    if ([ECChatBlockTool sharedInstanced].ec_replaceSourceMsgBlock)
        [ECChatBlockTool sharedInstanced].ec_replaceSourceMsgBlock(amessage);
        } else {
            [MBProgressHUD ec_ShowHUD_AutoHidden:[AppDelegate sharedInstanced].window.rootViewController.view withMessage:NSLocalizedString(@"撤回消息失败", nil)];
        }
    }];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (
        action == @selector(copyMenuAction:) ||
        action == @selector(deleteMenuAction:) ||
        action == @selector(transmitAction:) ||
        action == @selector(shareAction:) ||
        action == @selector(revokeAction:)
        ) {
        return YES;
    }
    return NO;
}

#pragma mark - 重新发送
const char ec_chat_resendKey;

- (void)resendMessage {
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"是否重发消息", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"重发", nil), nil];
    [alter show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        ECMessage *message = [[ECDeviceHelper sharedInstanced] ec_resendMessage:self.message];
        if ([ECChatBlockTool sharedInstanced].ec_resendCellBlock)
            [ECChatBlockTool sharedInstanced].ec_resendCellBlock(self, message);
    }}
@end
