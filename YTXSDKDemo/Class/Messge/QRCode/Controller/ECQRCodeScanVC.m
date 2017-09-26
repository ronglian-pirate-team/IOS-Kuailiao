//
//  ECQRCodeScanVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/1.
//
//

#import "ECQRCodeScanVC.h"
#import "ECQRCodeScanView.h"
#import <AVFoundation/AVFoundation.h>
#import "ECScanJoinGroupVC.h"
#import "ECScanResultVC.h"

@interface ECQRCodeScanVC ()<AVCaptureMetadataOutputObjectsDelegate,ECBaseContollerDelegate>

@property (nonatomic, strong) ECQRCodeScanView *scanningView;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation ECQRCodeScanVC
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupScanningQRCode];
}
#pragma mark - 二维码扫描
//启动摄像头，二维码扫描
- (void)setupScanningQRCode {
    // 1、获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 2、创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    // 3、创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // 4、设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 设置扫描范围(每一个取值0～1，以屏幕右上角为坐标原点)
    // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）
    output.rectOfInterest = CGRectMake(0.1, 0.2, 0.7, 0.6);
    // 5、初始化链接对象（会话对象）
    self.session = [[AVCaptureSession alloc] init];
    // 高质量采集率
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    // 5.1 添加会话输入
    [self.session addInput:input];
    // 5.2 添加会话输出
    [self.session addOutput:output];
    // 6、设置输出数据类型，需要将元数据输出添加到会话后，才能指定元数据类型，否则会报错
    // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    // 7、实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.view.layer.bounds;
    // 8、将图层插入当前视图
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    // 9、启动会话
    [self.session startRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // 0、扫描成功之后的提示音
//    [self playSoundEffect:@"QRCode_scan.caf"];
    // 1、如果扫描完成，停止会话
    [self.session stopRunning];
    // 2、删除预览图层
    [self.previewLayer removeFromSuperlayer];
    // 3、设置界面显示扫描结果
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSDictionary* jsonObject = [NSJSONSerialization JSONObjectWithData:[obj.stringValue dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        if (jsonObject && jsonObject[@"url"] && jsonObject[@"data"]) {
            if ([jsonObject[@"url"] isEqualToString:@"joinGroup"]) {
                NSDictionary* datajsonObject = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithBase64EncodedString:jsonObject[@"data"] options:0] options:NSJSONReadingMutableLeaves error:nil];
                if (datajsonObject) {
                    ECScanJoinGroupVC *joinGroupVC = [[ECScanJoinGroupVC alloc] init];
                    joinGroupVC.dataDic = datajsonObject;
                    [self.navigationController pushViewController:joinGroupVC animated:YES];
                }
            }
        }else{
            ECScanResultVC *resultVC = [[ECScanResultVC alloc] init];
            resultVC.scanResultStr = obj.stringValue;
            [self.navigationController pushViewController:resultVC animated:YES];
        }
    }
}

#pragma mark - 二维码扫描成功播放音效
- (void)playSoundEffect:(NSString *)name{
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    AudioServicesPlaySystemSound(soundID);
}

#pragma mark - 创建UI

- (void)buildUI{
    self.baseDelegate = self;
    self.title = NSLocalizedString(@"扫一扫", nil);
    self.scanningView = [[ECQRCodeScanView alloc] initWithFrame:self.view.bounds superViewLayer:self.view.layer];
    [self.view addSubview:self.scanningView];
    [super buildUI];
}

#pragma mark - ECBaseContollerDelegate
- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configLeftBtnItemWithStr:(NSString *__autoreleasing *)str {
    *str = NSLocalizedString(@"取消", nil);
    return ^id{
        [self.navigationController popViewControllerAnimated:YES];
        return nil;
    };
}
@end
