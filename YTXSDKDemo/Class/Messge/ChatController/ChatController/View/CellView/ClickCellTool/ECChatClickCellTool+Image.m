//
//  ECChatClickCellTool+Image.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/8.
//

#import "ECChatClickCellTool+Image.h"
#import "ECMessage+ECUtil.h"
#import "ECChatBlockTool.h"

@implementation ECChatClickCellTool (Image)

- (void)ec_Click_ChatImageCell {
    ECImageMessageBody *mediaBody = (ECImageMessageBody *)self.message.messageBody;
    NSString *path = mediaBody.isHD?mediaBody.HDLocalPath.lowercaseString:mediaBody.localPath.lowercaseString;
    if ([path hasSuffix:@".jpg"] || [path hasSuffix:@".png"] || [path hasSuffix:@".jpeg"] || [path hasSuffix:@"gif"] || [path hasSuffix:@"jpg_sd"]) {
        self.isOpenSavePhoto = ![self.message.userData ec_MyContainsString:EC_CHAT_fireMessage];
        NSArray *imgArray = [[ECMessageDB sharedInstanced] getImageMessageLocalPath:self.message.sessionId isHD:mediaBody.isHD];
        [self showPhotoBrowser:imgArray index:[self getImageMessageIndex:self.message imgArray:imgArray]];
    }
}

#pragma mark - 图片浏览器 Photo browser
// 返回点击图片的索引号
- (NSInteger)getImageMessageIndex:(ECMessage *)message imgArray:(NSArray *)imgArray
{
    NSInteger index = 0;
    if (message.messageBody.messageBodyType >= MessageBodyType_Voice) {
        ECImageMessageBody *mediaBody = (ECImageMessageBody *)message.messageBody;
        for (int i= 0;i<imgArray.count;i++) {
            if ([[imgArray objectAtIndex:i] isEqualToString:mediaBody.localPath])
                index = i;
        }
    }
    return index;
}

-(void)showPhotoBrowser:(NSArray*)imageArray index:(NSInteger)currentIndex {
    if (imageArray && [imageArray count] > 0) {
        NSMutableArray *photoArray = [NSMutableArray array];
        for (id object in imageArray) {
            MWPhoto *photo;
            if ([object isKindOfClass:[UIImage class]]) {
                photo = [MWPhoto photoWithImage:object];
            } else if ([object isKindOfClass:[NSURL class]]) {
                photo = [MWPhoto photoWithURL:object];
            } else if ([object isKindOfClass:[NSString class]]) {
                photo = [MWPhoto photoWithURL:[NSURL fileURLWithPath:object]];
            }
            [photoArray addObject:photo];
        }
        
        self.photos = photoArray;
    }
    
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.displayActionButton = YES;
    photoBrowser.displayNavArrows = NO;
    photoBrowser.displaySelectionButtons = NO;
    photoBrowser.alwaysShowControls = NO;
    photoBrowser.zoomPhotosToFill = YES;
    photoBrowser.enableGrid = NO;
    photoBrowser.startOnGrid = NO;
    photoBrowser.enableSwipeToDismiss = NO;
    photoBrowser.isOpen = self.isOpenSavePhoto;
    [photoBrowser setCurrentPhotoIndex:currentIndex];
    [[AppDelegate sharedInstanced].rootNav pushViewController:photoBrowser animated:YES];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return self.photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    if (index < self.photos.count) {
        return self.photos[index];
    }
    return nil;
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    EC_Demo_AppLog(@"");
    [[AppDelegate sharedInstanced].rootNav popViewControllerAnimated:YES];
    if (self.message.isReadFireMessage && self.message.messageState == ECMessageState_Receive) {
        [[ECDeviceHelper sharedInstanced] ec_readMessage:self.message];
        if ([ECChatBlockTool sharedInstanced].ec_replaceSourceMsgBlock)
            [ECChatBlockTool sharedInstanced].ec_replaceSourceMsgBlock(self.message);
    }
}
@end
