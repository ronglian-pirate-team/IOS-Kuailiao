//
//  ECChatClickCellTool+Redpacket.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/11.
//

#import "ECChatClickCellTool+Redpacket.h"
#import "ECMessage+RedpacketMessage.h"
#import "RedpacketViewControl.h"
#import "AppDelegate+RedpacketConfig.h"

@implementation ECChatClickCellTool (Redpacket)

- (void)ec_Click_ChatRedpacketCell {
    if(RedpacketMessageTypeRedpacket == self.message.rpModel.messageType) {
        
        self.message.rpModel.redpacketSender.userNickname = self.message.from;//根据需求显示，拆红包界面的发送者用户名
        self.message.rpModel.redpacketSender.userAvatar  = nil;          //根据需求显示，拆红包界面的发送整的用户头像
        self.message.rpModel.redpacketSender.userId = self.message.from;
        
        RedpacketViewControl *redpacketViewControl = [AppDelegate sharedInstanced].redpacketViewControl;
        
        if ([[[self.message redPacketDic] valueForKey:RedpacketKeyRedapcketToAnyone] isEqualToString:@"member"]) {
            [[ECDevice sharedInstance] getOtherPersonInfoWith:self.message.rpModel.toRedpacketReceiver.userId completion:^(ECError *error, ECPersonInfo *person) {
                
                self.message.rpModel.toRedpacketReceiver.userNickname = person.nickName; //根据需求显示，拆红包界面的定向接收者用户名
                self.message.rpModel.toRedpacketReceiver.userAvatar  = nil;              //根据需求显示，拆红包界面的定向接收者用户头像
                
                [redpacketViewControl redpacketCellTouchedWithMessageModel:self.message.rpModel];
                
            }];
        } else {
            [redpacketViewControl redpacketCellTouchedWithMessageModel:self.message.rpModel];
        }
    }
}
@end
