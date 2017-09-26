//
//  ECChatClickCellTool+BQMM.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/29.
//
//

#import "ECChatClickCellTool+BQMM.h"
#import <BQMM/BQMM.h>
#import "ECMessage+BQMMMessage.h"

@implementation ECChatClickCellTool (BQMM)

- (void)ec_Click_ChatBQMMCell {
    
    if (self.message.emojiCode) {
        UIViewController *vc = [[MMEmotionCentre defaultCentre] controllerForEmotionCode:self.message.emojiCode];
        [AppDelegate sharedInstanced].rootNav.navigationBar.tintColor = [UIColor whiteColor];
        [[AppDelegate sharedInstanced].rootNav pushViewController:vc animated:YES];
    }
}

@end
