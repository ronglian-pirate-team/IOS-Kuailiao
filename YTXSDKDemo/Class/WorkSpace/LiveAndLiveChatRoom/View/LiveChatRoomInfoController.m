//
//  LiveChatRoomInfoController.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/26.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "LiveChatRoomInfoController.h"
#import "LiveChatRoomBaseModel.h"

@interface LiveChatRoomInfoController ()<UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *nickF;
@property (strong, nonatomic) IBOutlet UITextView *anounceT;
@property (strong, nonatomic) IBOutlet UISwitch *switchModel;
@end

@implementation LiveChatRoomInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.cornerRadius = 5.0f;
    self.view.layer.masksToBounds = YES;
    
    if ([LiveChatRoomBaseModel sharedInstanced].roomInfo) {
        self.nickF.text = [LiveChatRoomBaseModel sharedInstanced].roomInfo.roomName;
        self.anounceT.text = [LiveChatRoomBaseModel sharedInstanced].roomInfo.announcement;
        self.switchModel.on = [LiveChatRoomBaseModel sharedInstanced].roomInfo.isAllMuteMode;
    }
     if (![[LiveChatRoomBaseModel sharedInstanced].roomInfo.creator isEqualToString:[ECAppInfo sharedInstanced].userName]) {
         self.nickF.enabled = NO;
         self.anounceT.editable = NO;
         self.switchModel.enabled = NO;
     }
}

- (IBAction)clickedDeleteBtn:(id)sender {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (IBAction)clickedSaveBtn:(id)sender {
    NSString *nickN = [_nickF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *announce = [_anounceT.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL isAlllMode = _switchModel.on;
    
    ECModifyLiveChatRoomInfoRequest *request = [[ECModifyLiveChatRoomInfoRequest alloc] init];
    request.roomId = self.roomId;
    request.roomName = nickN;
    request.announcement = announce;
    request.isAllMuteMode = isAlllMode;
    request.roomExt = @"{\n  \"livechatroom_pimg\" : \"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1495789173924&di=4ba75c037c4c4766a08a74937ce7d6f4&imgtype=0&src=http%3A%2F%2Fscimg.jb51.net%2Ftouxiang%2F201705%2F2017050421474180.jpg\"\n}";
    
    [[ECDevice sharedInstance].liveChatRoomManager modifyLiveChatRoomInfo:request completion:^(ECError *error, ECLiveChatRoomInfo *roomInfo) {
        if (error.errorCode == ECErrorType_NoError) {
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"保存成功,是否关闭" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KNOTIFICATION_LiveChatRoomInfo" object:nil];
        }else if(error.errorCode == 620010){
            [ECCommonTool toast:@"无权限"];
        } else {
            [ECCommonTool toast:[NSString stringWithFormat:@"%ld",(long)error.errorCode]];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex != buttonIndex) {
        [self clickedDeleteBtn:nil];
    }
}
@end
