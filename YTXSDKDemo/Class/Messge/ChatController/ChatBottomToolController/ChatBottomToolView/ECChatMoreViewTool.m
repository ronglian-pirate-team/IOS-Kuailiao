//
//  ECChatMoreViewTool.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/8.
//
//

#import "ECChatMoreViewTool.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import "ECMainTabbarVC.h"
#import "PKRecordShortVideoViewController.h"
#import "ECRecordShortVideoVC.h"
#import "ECLocationVC.h"
#import "RedpacketViewControl.h"
#import "ECMessage+RedpacketMessage.h"
#import "ECCallVoiceView.h"
#import "ECCallVideoView.h"
#import "AppDelegate+RedpacketConfig.h"
#import "ECMessage+ECUtil.h"


@interface ECChatMoreViewTool()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, ECRecordShortVideoDelegate, RedpacketViewControlDelegate, UIActionSheetDelegate>

@end

@implementation ECChatMoreViewTool

+ (instancetype)sharedInstanced {
    static ECChatMoreViewTool *tool;
    static dispatch_once_t devicedelegatehelperonce;
    dispatch_once(&devicedelegatehelperonce, ^{
        tool = [[[self class] alloc] init];
    });
    return tool;
}

- (UIViewController *)currentVC{
    return [AppDelegate sharedInstanced].currentVC;
}

- (void)sendMessageTakePicture{
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypeCamera)]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"设备不支持摄像头" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alterView show];
    }
    imagePicker.mediaTypes = (self.isReadDeleteMessage ? @[(NSString *)kUTTypeImage] : @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie]);
    imagePicker.videoMaximumDuration = 30.0f;
    if([self currentVC]){
        [[self currentVC] presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)sendMessageSelectImages{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
    imagePickerVc.navigationBar.barTintColor = EC_Color_App_Main;
    imagePickerVc.isSelectOriginalPhoto = NO;
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingGif = YES;
    imagePickerVc.allowPickingVideo = !self.isReadDeleteMessage;
    imagePickerVc.sortAscendingByModificationDate = YES;
    imagePickerVc.alwaysEnableDoneBtn = YES;
    imagePickerVc.doneBtnTitleStr = NSLocalizedString(@"发送", nil);
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        NSString *userData = (self.isReadDeleteMessage ? EC_CHAT_fireMessage : nil);
        if (isSelectOriginalPhoto) {
            for (id asset in [assets copy]) {
                [[TZImageManager manager] getOriginalPhotoWithAsset:asset completion:^(UIImage *photo, NSDictionary *info) {
                    NSString *imagePath = [ECCommonTool saveToDocument:photo isHD:YES];
                    ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:imagePath displayName:imagePath.lastPathComponent];
                    mediaBody.isHD = YES;
                    mediaBody.HDLocalPath = imagePath;
                    ECMessage *message = [[ECMessage alloc] initWithReceiver:self.receiver body:mediaBody];
                    message.isReadFireMessage = self.isReadDeleteMessage;
                    message.userData = userData;
                    [[ECDeviceHelper sharedInstanced] ec_sendMessage:message];
                }];
            }
        } else {
            for (UIImage *img in [photos copy]) {
                NSString *imagePath = [ECCommonTool saveToDocument:img isHD:NO];
                ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:imagePath displayName:imagePath.lastPathComponent];
                ECMessage *message = [[ECMessage alloc] initWithReceiver:self.receiver body:mediaBody];
                message.isReadFireMessage = self.isReadDeleteMessage;
                message.userData = userData;
                [[ECDeviceHelper sharedInstanced] ec_sendMessage:message];
            }
        }
    }];
    if([self currentVC]){
        [[self currentVC] presentViewController:imagePickerVc animated:YES completion:nil];
    }
}

- (void)sendMessageTakeVideo{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *fileName = [NSProcessInfo processInfo].globallyUniqueString;
    NSString *path = [paths[0] stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:@"mp4"]];
    ECRecordShortVideoVC *viewController = [[ECRecordShortVideoVC alloc] initWithOutputFilePath:path outputSize:CGSizeMake(EC_kScreenW, EC_kScreenH) themeColor:[UIColor colorWithRed:0/255.0 green:153/255.0 blue:255/255.0 alpha:1]];
    viewController.delegate = self;
    if([self currentVC]){
        [[self currentVC] presentViewController:viewController animated:YES completion:nil];
    }
}

- (void)sendMessageSelectLocation{
    EC_WS(self)
    UIViewController *locationVC = [[NSClassFromString(@"ECLocationVC") alloc] initWithBaeTwoObjectCompletion:^(MKMapItem *mapItem, UIImage *shotImg) {
        ECLocationMessageBody *messageBody = [[ECLocationMessageBody alloc] initWithCoordinate:mapItem.placemark.coordinate andTitle:mapItem.name];
        ECMessage *message = [[ECMessage alloc] initWithReceiver:weakSelf.receiver body:messageBody];
        message.shotImg = shotImg;
        message = [[ECDeviceHelper sharedInstanced] ec_sendMessage:message];
        message.shotImg = shotImg;
    }];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:locationVC];
    if([self currentVC])
        [[self currentVC] presentViewController:nc animated:YES completion:nil];
}

- (void)sendMessageRedpacket{
    [[AppDelegate sharedInstanced] sendRedpacketMessage];
}

- (void)sendMessageReadFire{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"阅后即焚", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"拍照", nil), NSLocalizedString(@"从相册选取", nil), nil];
    [sheet showInView:[AppDelegate sharedInstanced].window];
}

- (void)takeCallVoice{
    if([ECDeviceDelegateHelper sharedInstanced].isCallBusy){
        [ECCommonTool toast:@"通话中，请稍后"];
        return;
    }
    ECCallVoiceView *callView = [[ECCallVoiceView alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, EC_kScreenH)];
    callView.callNumber = self.receiver;
    [callView show];
}

- (void)takeCallVideo{
    if([ECDeviceDelegateHelper sharedInstanced].isCallBusy){
        [ECCommonTool toast:@"通话中，请稍后"];
        return;
    }
    ECCallVideoView *callView = [[ECCallVideoView alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, EC_kScreenH)];
    callView.callNumber = self.receiver;
    [callView show];
}

#pragma mark - PKRecordShortVideoViewController delegate
- (void)didFinishRecordingToOutputFilePath:(NSString *)outputFilePath {
    ECVideoMessageBody *mediaBody = [[ECVideoMessageBody alloc] initWithFile:outputFilePath displayName:outputFilePath.lastPathComponent];
    [[ECDeviceHelper sharedInstanced] ec_sendMessage:mediaBody to:self.receiver withUserData:EC_CHAT_SendSightvideo];
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        [self sendMessageTakePicture];
    }else if (buttonIndex == 1){
        [self sendMessageSelectImages];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        [picker dismissViewControllerAnimated:YES completion:nil];
        NSURL *mp4 = [ECCommonTool convertToMp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        NSString *mp4Path = [mp4 relativePath];
        ECVideoMessageBody *mediaBody = [[ECVideoMessageBody alloc] initWithFile:mp4Path displayName:mp4Path.lastPathComponent];
        [[ECDeviceHelper sharedInstanced] ec_sendMessage:mediaBody to:self.receiver];
    } else {
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        [picker dismissViewControllerAnimated:YES completion:nil];
        NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
        NSString* ext = imageURL.pathExtension.lowercaseString;
        NSString *userData = (self.isReadDeleteMessage ? EC_CHAT_fireMessage : nil);
        if ([ext isEqualToString:@"gif"]) {
            NSString *filePath = [ECCommonTool saveGifToDocument:imageURL];
            ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:filePath displayName:filePath.lastPathComponent];
            [[ECDeviceHelper sharedInstanced] ec_sendMessage:mediaBody to:self.receiver withUserData:userData];
        } else {
            NSString *imagePath = [ECCommonTool saveToDocument:orgImage isHD:NO];
            ECImageMessageBody *mediaBody = [[ECImageMessageBody alloc] initWithFile:imagePath displayName:imagePath.lastPathComponent];
            [[ECDeviceHelper sharedInstanced] ec_sendMessage:mediaBody to:self.receiver withUserData:userData];
        }
    }
}

@end
