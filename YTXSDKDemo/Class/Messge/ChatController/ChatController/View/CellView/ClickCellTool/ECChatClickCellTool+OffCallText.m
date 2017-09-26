//
//  ECChatClickCellTool+OffCallText.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/21.
//

#import "ECChatClickCellTool+OffCallText.h"
#import "ECCallVoiceView.h"

@implementation ECChatClickCellTool (OffCallText)

- (void)ec_Click_ChatOffCallTextCell {
    if (self.message.messageBody.messageBodyType == MessageBodyType_Call)
        return;
    ECCallVoiceView *callView = [[ECCallVoiceView alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, EC_kScreenH)];
    callView.callNumber = self.message.from;
    [callView show];
}
@end
