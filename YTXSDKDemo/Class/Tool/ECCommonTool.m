//
//  ECCommonTool.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/22.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "ECCommonTool.h"
#import "AppDelegate.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AVFoundation/AVFoundation.h>
#import "ECMainTabbarVC.h"

#define EC_DefaultThumImageHigth 90.0f
#define EC_DefaultPressImageHigth 960.0f

@implementation ECCommonTool

+ (BOOL)verifyMobilePhone:(NSString*)phone {
    BOOL isMobilePhone = NO;
    phone = [phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    isMobilePhone = phone.length==11?YES:NO;
    NSString *regex = @"1[0-9]{10}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    isMobilePhone = [predicate evaluateWithObject:phone];
    return isMobilePhone;
}

+ (void)toast:(NSString*)message {
    [self toast:message duration:2.0f];
}

+ (void)toast:(NSString*)message duration:(CGFloat)duration{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[AppDelegate sharedInstanced].window animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.margin = 10.0f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:duration];
}

+ (NSURL *)convertToMp4:(NSURL *)movUrl {
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    if ([compatiblePresets containsObject:AVAssetExportPreset640x480]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset
                                                                               presetName:AVAssetExportPreset640x480];
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyyMMddHHmmssSSS"];
        NSString* fileName = [NSString stringWithFormat:@"%@.mp4", [formater stringFromDate:[NSDate date]]];
        NSString* path = [NSString stringWithFormat:@"file:///private%@",[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName]];
        mp4Url = [NSURL URLWithString:path];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            wait = nil;
        }
    }
    return mp4Url;
}

+ (NSString *)saveGifToDocument:(NSURL *)srcUrl{
    ALAssetsLibrary* assetLibrary = [[ALAssetsLibrary alloc] init];
    __block NSString* filePath = @"";
    dispatch_semaphore_t wait = dispatch_semaphore_create(0);
    [assetLibrary assetForURL:srcUrl resultBlock:^(ALAsset *asset) {
        if (asset != nil) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *imageBuffer = (Byte*)malloc((unsigned long)rep.size);
            NSUInteger bufferSize = [rep getBytes:imageBuffer fromOffset:0.0 length:(unsigned long)rep.size error:nil];
            NSData *imageData = [NSData dataWithBytesNoCopy:imageBuffer length:bufferSize freeWhenDone:YES];
            NSDateFormatter* formater = [[NSDateFormatter alloc] init];
            [formater setDateFormat:@"yyyyMMddHHmmssSSS"];
            NSString* fileName =[NSString stringWithFormat:@"%@.gif", [formater stringFromDate:[NSDate date]]];
            filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
            [imageData writeToFile:filePath atomically:YES];
        } else {
        }
        dispatch_semaphore_signal(wait);
    } failureBlock:^(NSError *error) {
        dispatch_semaphore_signal(wait);
    }];
    dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
    return filePath;
}

+ (NSString *)saveToDocument:(UIImage*)image isHD:(BOOL)isHD {
    UIImage* fixImage = [UIImage ec_fixOrientation:image];
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString* fileName =[NSString stringWithFormat:@"%@.jpg", [formater stringFromDate:[NSDate date]]];
    NSString* filePath=[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    NSData *imageData = nil;
    if (!isHD) {
        //图片按0.5的质量压缩－》转换为NSData
        CGSize pressSize = CGSizeMake((EC_DefaultPressImageHigth/fixImage.size.height) * fixImage.size.width, EC_DefaultPressImageHigth);
        UIImage * pressImage = [UIImage ec_compressImage:fixImage withSize:pressSize];
        imageData = UIImageJPEGRepresentation(pressImage, 0.5);
    } else {
        imageData = UIImagePNGRepresentation(fixImage);
    }
    [imageData writeToFile:filePath atomically:YES];
    CGSize thumsize = CGSizeMake((EC_DefaultThumImageHigth/fixImage.size.height) * fixImage.size.width, EC_DefaultThumImageHigth);
    UIImage * thumImage = [UIImage ec_compressImage:fixImage withSize:thumsize];
    NSData * photo = UIImageJPEGRepresentation(thumImage, 0.5);
    NSString * thumfilePath = [NSString stringWithFormat:@"%@.jpg_thum", filePath];
    [photo writeToFile:thumfilePath atomically:YES];
    return filePath;
}


+ (NSString *)validateNullStr:(NSString *)originalStr{
    if(!originalStr || [originalStr isKindOfClass:[NSNull class]] || [originalStr isKindOfClass:[NSNull class]] || [[originalStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 || originalStr == nil)
        return @"";
    return originalStr;
}

+ (NSString *)userAvatar:(NSString *)userId {
    ECFriend *friend = [[ECDBManager sharedInstanced].friendMgr queryFriend:userId];
    if(friend && EC_ValidateNullStr(friend.avatar))
        return friend.avatar;
    NSString *cachePath = @"avatar";
    if(friend.remarkName && friend.remarkName != nil && friend.remarkName.length > 0){
        UIImage *img = [UIImage ec_circleImageWithColor:EC_Color_App_Main withSize:CGSizeMake(40, 40) withName:friend.remarkName];
        NSString *path = [cachePath stringByAppendingFormat:@"/%@/%@/image.data", [NSString MD5:userId], [NSString MD5:friend.remarkName]];
        [[SDImageCache sharedImageCache] storeImage:img forKey:path completion:nil];
        return path;
    }
    if(friend.nickName && friend.nickName != nil && friend.nickName.length > 0){
        UIImage *img = [UIImage ec_circleImageWithColor:EC_Color_App_Main withSize:CGSizeMake(40, 40) withName:friend.nickName];
        NSString *path = [cachePath stringByAppendingFormat:@"/%@/%@/image.data", [NSString MD5:userId], [NSString MD5:friend.nickName]];
        [[SDImageCache sharedImageCache] storeImage:img forKey:path completion:nil];
        return path;
    }
    if(userId && userId != nil && userId.length > 0){
        UIImage *img = [UIImage ec_circleImageWithColor:EC_Color_App_Main withSize:CGSizeMake(40, 40) withName:userId];
        NSString *path = [cachePath stringByAppendingFormat:@"/%@/%@/image.data", [NSString MD5:userId], [NSString MD5:userId]];
        [[SDImageCache sharedImageCache] storeImage:img forKey:path completion:nil];
        return path;
    }
    return @"";
}

@end
