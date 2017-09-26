//
//  ECDeviceDelegateHelper+LiveChatRoom.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/1.
//
//

#import "ECDeviceDelegateHelper+LiveChatRoom.h"
#import "LiveChatRoomBaseModel.h"

@implementation ECDeviceDelegateHelper (LiveChatRoom)

- (void)onReceiveLiveChatRoomMessage:(ECMessage *)message {
    if (message.from.length==0) {
        return;
    }
    if (message.timestamp) {
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
        message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_onLiveChatRoomMesssageChanged object:message];
}

- (void)onReceiveLiveChatRoomNoticeMessage:(ECLiveChatRoomNoticeMessage *)msg {
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    msg.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    
    NSString *content = nil;
    NSString *nick = msg.userName.length>0?msg.userName:msg.userId;
    ECLiveChatRoomInfo *roomInfo = [LiveChatRoomBaseModel sharedInstanced].roomInfo;
    ECLiveChatRoomMember *member = [[ECLiveChatRoomMember alloc] init];
    member.roomId = msg.roomId;
    member.useId = msg.userId;
    member.type = msg.role;
    member.nickName = msg.userName;
    switch (msg.type) {
        case ECLiveChatRoomNoticeType_Join: {
            roomInfo.onlineCount +=1;
            content = [NSString stringWithFormat:@"%@%@",nick,@"加入聊天室"];
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_onReceivedLiveChatRoomNotice object:@{@"type":@(msg.type),@"member":member}];
        }
            break;
        case ECLiveChatRoomNoticeType_ModifyRoomInfo:
            content = [NSString stringWithFormat:@"%@",@"聊天室信息修改"];
            break;
        case ECLiveChatRoomNoticeType_SetMemberRole: {
            content = [NSString stringWithFormat:@"%@变更为%@",nick,msg.role==2?@"管理员":@"成员"];
            [LiveChatRoomBaseModel sharedInstanced].type = msg.role;
        }
            break;
        case ECLiveChatRoomNoticeType_KickMember: {
            if (roomInfo.onlineCount>1) {
                roomInfo.onlineCount-=1;
            }
            content = [NSString stringWithFormat:@"%@%@",nick,@"被踢出聊天室"];
        }
            break;
        case ECLiveChatRoomNoticeType_Eixt: {
            if (roomInfo.onlineCount>1) {
                roomInfo.onlineCount-=1;
            }
            content = [NSString stringWithFormat:@"%@%@",nick,@"退出聊天室"];
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_onReceivedLiveChatRoomNotice object:@{@"type":@(msg.type),@"member":member}];
        }
            break;
        case ECLiveChatRoomNoticeType_AllMute:
            content = [NSString stringWithFormat:@"%@",@"聊天室全员已被禁言"];
            break;
        case ECLiveChatRoomNoticeType_CancelAllMute:
            content = [NSString stringWithFormat:@"%@",@"聊天室全员解除禁言"];
            break;
        case ECLiveChatRoomNoticeType_MemberMute:
            content = [NSString stringWithFormat:@"%@%@",nick,@"已被禁言"];
            break;
        case ECLiveChatRoomNoticeType_CancelMemberMute:
            content = [NSString stringWithFormat:@"%@%@",nick,@"解除禁言"];
            break;
        case ECLiveChatRoomNoticeType_MemberBlack:{
            if (roomInfo.onlineCount>1) {
                roomInfo.onlineCount-=1;
            }
            content = [NSString stringWithFormat:@"%@%@",nick,@"已被拉黑"];
        }
            break;
        case ECLiveChatRoomNoticeType_CancelMemberBlack:
            content = [NSString stringWithFormat:@"%@%@",nick,@"取消拉黑"];
            [LiveChatRoomBaseModel sharedInstanced].cancelBlack = [msg.userId isEqualToString:[ECDevicePersonInfo sharedInstanced].userName];
            break;
        case ECLiveChatRoomNoticeType_StopLiveChatRoom:
            content = [NSString stringWithFormat:@"%@",@"聊天室已关闭"];
            break;
            
        default:
            break;
    }
    [LiveChatRoomBaseModel sharedInstanced].roomInfo = roomInfo;
    ECTextMessageBody *body = [[ECTextMessageBody alloc] initWithText:content];
    ECMessage *message = [[ECMessage alloc] initWithReceiver:msg.roomId body:body];
    message.from = @"系统消息";
    message.to = msg.roomId;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_onLiveChatRoomMesssageChanged object:message];
}
@end
