//
//  ECChatClickCellTool+Video.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/8.
//

#import "ECChatClickCellTool+Video.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@implementation ECChatClickCellTool (Video)

- (void)ec_Click_ChatVideoCell {
    ECVideoMessageBody *mediaBody = (ECVideoMessageBody*)self.message.messageBody;
    
    AVPlayerViewController *avPlayerVC = [[AVPlayerViewController alloc] init];
    avPlayerVC.player = [AVPlayer playerWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://localhost%@", mediaBody.localPath]]];
    [avPlayerVC.player play];
    [[AppDelegate sharedInstanced].window.rootViewController.childViewControllers[0] presentViewController:avPlayerVC animated:NO completion:nil];
}
@end
