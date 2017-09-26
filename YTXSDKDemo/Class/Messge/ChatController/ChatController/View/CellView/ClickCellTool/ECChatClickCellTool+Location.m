//
//  ECChatClickCellTool+Location.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/21.
//

#import "ECChatClickCellTool+Location.h"
#import "ECLocationPoint.h"

@implementation ECChatClickCellTool (Location)

- (void)ec_Click_ChatLocationCell {
    if (self.message.messageBody.messageBodyType != MessageBodyType_Location)
        return;
    ECLocationMessageBody *localBody = (ECLocationMessageBody *)self.message.messageBody;
    ECLocationPoint *point = [[ECLocationPoint alloc] initWithCoordinate:localBody.coordinate andTitle:localBody.title];
    UIViewController *localVC = [[NSClassFromString(@"ECLocationVC") alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:localVC];
    if([AppDelegate sharedInstanced].currentVC)
        [[AppDelegate sharedInstanced].currentVC ec_presentViewController:nc animated:YES completion:nil data:point];
}
@end
