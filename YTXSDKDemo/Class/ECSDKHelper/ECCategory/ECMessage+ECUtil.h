//
//  ECMessage+ECUtil.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/5.
//

#import "ECMessage.h"
typedef enum : NSUInteger {
    EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_FIREMESSAGE = 10001,
    EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_SIGHTVIDEO,
    EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_BQMM,
    EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_Redpacket,
    EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_RedpacketTakenTip,
    
} EC_Demo_CAHT_MESSAGE_CUSTOMTYPE;


#define EC_CHAT_fireMessage @"fireMessage"
#define EC_CHAT_SendSightvideo @"sightvideo"

@interface ECMessage (ECUtil)

+ (NSInteger)ExtendTypeOfTextMessage:(ECMessage *)message;

+ (BOOL)validSendMessage:(ECMessage *)message;

@end
