//
//  ECChatClickCellTool+Text.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/11.
//

#import "ECChatClickCellTool+Text.h"
#import "ECWebBaseController.h"
#import <objc/runtime.h>

@implementation ECChatClickCellTool (Text)

const char ec_chat_text_phone;
- (void)ec_Click_ChatTextCell:(NSString *)clickedString {

    NSString *urlStr = clickedString;
    if ([ECCommonTool verifyMobilePhone:clickedString]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",urlStr]];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"是否拨打此手机号", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"否", nil) otherButtonTitles:NSLocalizedString(@"拨打", nil), nil];
            [alter show];
            objc_setAssociatedObject(alter, &ec_chat_text_phone, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    } else {
        ECWebBaseController *webBrowserVC = [[ECWebBaseController alloc] initWithUrlStr:urlStr andType:ECWebBaseController_Type_ShareLink completion:^(id responseObject) {
            if (![responseObject isKindOfClass:[NSDictionary class]])
                return ;
            NSDictionary *dict = (NSDictionary *)responseObject;
            NSString *localPath = dict[@"localpath"];
            ECPreviewMessageBody *msgBody = [[ECPreviewMessageBody alloc] initWithFile:localPath displayName:localPath.lastPathComponent];
            msgBody.url = dict[@"url"];
            msgBody.title = dict[@"title"];
            msgBody.remotePath = dict[@"remotePath"];
            msgBody.desc = dict[@"content"];
            ECMessage *message = [[ECMessage alloc] initWithReceiver:self.message.sessionId body:msgBody];
            [[ECDeviceHelper sharedInstanced] ec_sendMessage:message];
        }];
        id vc = [AppDelegate sharedInstanced].window.rootViewController.childViewControllers[0];
        if ([vc isKindOfClass:[UINavigationController class]]) {
            [(UINavigationController *)vc pushViewController:webBrowserVC animated:YES];
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSURL *url = objc_getAssociatedObject(alertView, &ec_chat_text_phone);
        [[UIApplication sharedApplication] openURL:url];
    }
}
@end
