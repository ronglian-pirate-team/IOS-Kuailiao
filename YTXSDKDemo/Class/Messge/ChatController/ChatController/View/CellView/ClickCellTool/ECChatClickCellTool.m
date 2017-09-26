//
//  ECChatClickCellTool.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/7.
//

#import "ECChatClickCellTool.h"
#import "ECMessageDB.h"
#import "ECChatClickCellTool+Image.h"
#import "ECChatClickCellTool+Voice.h"
#import "ECChatClickCellTool+Video.h"
#import "ECChatClickCellTool+Redpacket.h"
#import "ECChatClickCellTool+Preview.h"
#import "ECChatClickCellTool+OffCallText.h"
#import "ECChatClickCellTool+Location.h"
#import "ECChatClickCellTool+BQMM.h"

#import "ECMessage+ECUtil.h"
#import "ECChatBlockTool.h"

#import "ECFriendInfoDetailVC.h"

@interface ECChatClickCellTool ()
@end

@implementation ECChatClickCellTool
+ (instancetype)sharedInstanced {
    static ECChatClickCellTool *cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cls = [[[self class] alloc] init];
    });
    return cls;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.photos = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 点击头像
- (void)ec_Click_ChatCelltapPortraitEventWithMessage:(ECMessage *)message {
    ECFriendInfoDetailVC *detailVC = [[ECFriendInfoDetailVC alloc] init];
    ECFriend *friend = [[ECFriend alloc] init];
    friend.useracc = [ECMessage validSendMessage:message]?[ECAppInfo sharedInstanced].userName:message.from;
    detailVC.friendInfo = friend;
    detailVC.isFriendInfo = [[ECDBManager sharedInstanced].friendMgr queryFriend:friend.useracc] ? YES : NO;
    detailVC.hidesBottomBarWhenPushed = YES;
    [[AppDelegate sharedInstanced].rootNav pushViewController:detailVC animated:YES];
}

#pragma mark - 点击了已读列表
- (void)ec_Click_ChatCelltapReadLEventWithMessage:(ECMessage *)message {
    UIViewController *vc = [[NSClassFromString(@"ECReadMessageController") alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [[AppDelegate sharedInstanced].rootNav ec_pushViewController:vc animated:YES data:message];
}
#pragma mark - 点击cell
- (void)ec_Click_ChatCellEventWithMessage:(ECMessage *)message {
    self.message = message;
    NSInteger fileType = [ECMessage ExtendTypeOfTextMessage:message];
    
    if (fileType == MessageBodyType_Voice ||  fileType == MessageBodyType_File || fileType == MessageBodyType_Image || fileType == MessageBodyType_Video || fileType == EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_SIGHTVIDEO) {
        ECFileMessageBody *mediaBody = (ECFileMessageBody *)message.messageBody;
        if (mediaBody.mediaDownloadStatus == ECMediaDownloading) {
            return;
        }
        if (message.messageState == ECMessageState_Receive && mediaBody.remotePath.length>0 && (mediaBody.mediaDownloadStatus != ECMediaDownloadSuccessed || (fileType== MessageBodyType_Image && [(ECImageMessageBody *)mediaBody HDDownloadStatus] != ECMediaDownloadSuccessed))) {
            
            [MBProgressHUD ec_ShowHUD:[AppDelegate sharedInstanced].window.rootViewController.view withMessage:NSLocalizedString(@"正在获取文件", nil)];
            EC_WS(self);
            [[ECDeviceHelper sharedInstanced] ec_downloadMediaMessage:message andCompletion:^(ECError *error, ECMessage *message) {
                
                EC_SS(weakSelf);
                [MBProgressHUD hideHUDForView:[AppDelegate sharedInstanced].window.rootViewController.view animated:YES];
                if (error.errorCode == ECErrorType_NoError) {
                    [strongSelf fileCellBubbleViewTap:message andFileType:fileType];
                } else {
                    [MBProgressHUD ec_ShowHUD_AutoHidden:[AppDelegate sharedInstanced].window.rootViewController.view withMessage:NSLocalizedString(@"获取文件失败", nil)];
                }
            }];
        } else if (mediaBody.localPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath]) {
            [self fileCellBubbleViewTap:message andFileType:fileType];
        }
    } else {
        [self fileCellBubbleViewTap:message andFileType:fileType];
    }
}

- (void)fileCellBubbleViewTap:(ECMessage *)message andFileType:(NSInteger)fileType {
    if (fileType == MessageBodyType_Image || fileType == MessageBodyType_Voice || fileType == MessageBodyType_Video || fileType == EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_SIGHTVIDEO) {
        if ([ECChatBlockTool sharedInstanced].ec_reloadSingleCellBlock)
            [ECChatBlockTool sharedInstanced].ec_reloadSingleCellBlock(message);
    }
    if (fileType == MessageBodyType_Image || fileType == EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_FIREMESSAGE) {
        [self ec_Click_ChatImageCell];
    } else if (fileType == MessageBodyType_Voice) {
        [self ec_Click_ChatVoiceCell];
    } else if (fileType == MessageBodyType_Video || fileType == EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_SIGHTVIDEO) {
        [self ec_Click_ChatVideoCell];
    } else if (fileType == EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_Redpacket) {
        [self ec_Click_ChatRedpacketCell];
    } else if (fileType == MessageBodyType_Preview) {
        [self ec_Click_ChatPreviewCell];
    } else if (fileType == MessageBodyType_Call) {
        [self ec_Click_ChatOffCallTextCell];
    } else if (fileType == MessageBodyType_Location) {
        [self ec_Click_ChatLocationCell];
    } else if (fileType == EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_BQMM) {
        [self ec_Click_ChatBQMMCell];
    }
}

@end
