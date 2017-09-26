//
//  ECChatBaseCell+LongPress.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/10.
//

#import "ECChatBaseCell.h"

@interface ECChatBaseCell (LongPress)<UIAlertViewDelegate>

- (void)showMenuViewController:(UIView *)showInView message:(ECMessage*)message;

- (void)resendMessage;
@end
