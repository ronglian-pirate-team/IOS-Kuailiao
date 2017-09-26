//
//  ECChatTextCell.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/4.
//

#import "ECChatTextCell.h"

@interface ECChatTextCell ()
@end

@implementation ECChatTextCell

- (void)updateChildUI {
    [super updateChildUI];
    
    if ([self.message.messageBody isKindOfClass:[ECTextMessageBody class]]) {
        ECTextMessageBody *body = (ECTextMessageBody *)self.message.messageBody;
        self.contentL.text = body.text;
    }
}

@end
