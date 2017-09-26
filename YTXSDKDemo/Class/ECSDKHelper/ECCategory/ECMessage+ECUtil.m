//
//  ECMessage+ECUtil.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/5.
//

#import "ECMessage+ECUtil.h"
#import "ECMessage+RedpacketMessage.h"

#define txt_msgType @"txt_msgType"

@implementation ECMessage (ECUtil)

+ (NSInteger)ExtendTypeOfTextMessage:(ECMessage *)message {
    if (message.messageBody.messageBodyType == MessageBodyType_Text) {
        
        if (message.userData) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[message.userData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            if (dict && dict[txt_msgType]) {
                return EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_BQMM;
            }  else if ([message isRedpacket]) {
                if (![message isRedpacketOpenMessage]) {
                    return EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_Redpacket;
                } else {
                    return EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_RedpacketTakenTip;
                }
            }
        }
    } else if (message.messageBody.messageBodyType == MessageBodyType_Image) {
        if ([message.userData isEqualToString:EC_CHAT_fireMessage])
            return EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_FIREMESSAGE;
    } else if (message.messageBody.messageBodyType == MessageBodyType_Video) {
        if ([message.userData isEqualToString:EC_CHAT_SendSightvideo])
            return EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_SIGHTVIDEO;
    }
    return message.messageBody.messageBodyType;
}

+ (BOOL)validSendMessage:(ECMessage *)message {
    BOOL isSender = [message.from isEqualToString:[ECDevicePersonInfo sharedInstanced].userName];
    return isSender;
}
@end
