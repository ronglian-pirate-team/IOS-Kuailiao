//
//  ECChatClickCellTool+Preview.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/14.
//

#import "ECChatClickCellTool+Preview.h"
#import "ECWebBaseController.h"

@implementation ECChatClickCellTool (Preview)

- (void)ec_Click_ChatPreviewCell {
    if (self.message.messageBody.messageBodyType != MessageBodyType_Preview)
        return;

    ECPreviewMessageBody *body = (ECPreviewMessageBody*)self.message.messageBody;
    ECWebBaseController *webBrowserVC = [[ECWebBaseController alloc] initWithUrlStr:body.url andType:ECWebBaseController_Type_ShareLink completion:^(id responseObject) {
        ECMessage *message = [[ECMessage alloc] initWithReceiver:self.message.sessionId body:body];
        [[ECDeviceHelper sharedInstanced] ec_sendMessage:message];
    }];
    [[AppDelegate sharedInstanced].rootNav pushViewController:webBrowserVC animated:YES];
}
@end
