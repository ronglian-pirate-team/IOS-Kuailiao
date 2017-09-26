//
//  ECChatCallTextCell.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/10.
//

#import "ECChatCallTextCell.h"

@implementation ECChatCallTextCell
- (void)updateChildUI {
    [super updateChildUI];
    
    if ([self.message.messageBody isKindOfClass:[ECCallMessageBody class]]) {
        ECCallMessageBody *body = (ECCallMessageBody *)self.message.messageBody;
        self.self.contentL.text = body.callText;
    }
}

@end
