//
//  ECGroupQRCodeVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/1.
//
//

#import "ECGroupQRCodeVC.h"
#import "ECDemoGroupManage.h"

@interface ECGroupQRCodeVC ()
@property (nonatomic, strong) ECGroup  *group;
@property (nonatomic, strong) UIImageView *qrCodeImage;
@end

@implementation ECGroupQRCodeVC

#pragma mark - 群组二维码生成
- (UIImage *)createGroupImage{
    NSString *dataBase64 = [NSString stringWithFormat:@"{\"groupid\":\"%@\",\"creator\":\"%@\",\"time\":\"%@\",\"count\":%d,\"name\":\"%@\"}",self.group.groupId, [ECAppInfo sharedInstanced].userName, [NSDate ec_stringFromCurrentDateWithFormate:@"yyyy-MM-dd HH:mm:ss"], (int)self.group.memberCount, self.group.name];
    dataBase64 = [[dataBase64 dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *qrcodeString = [NSString stringWithFormat:@"{\"url\":\"joinGroup\",\"data\":\"%@\"}",dataBase64];
    return [UIImage ec_imageWithQRCodeData:qrcodeString imageWidth:200];
}

#pragma mark - 创建UI
- (void)buildUI{
    self.title = NSLocalizedString(@"二维码", nil);
    self.group = [ECDemoGroupManage sharedInstanced].group;
    [self.view addSubview:self.qrCodeImage];
    EC_WS(self)
    [self.qrCodeImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.view);
    }];
    [super buildUI];
}

- (UIImageView *)qrCodeImage{
    if(!_qrCodeImage){
        _qrCodeImage = [[UIImageView alloc] init];
        _qrCodeImage.image = [self createGroupImage];
    }
    return _qrCodeImage;
}

@end
