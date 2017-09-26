//
//  ECChatVideoCell+SightVideo.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/20.
//

#import "ECChatVideoCell+SightVideo.h"
#import <objc/runtime.h>

const char ec_chat_SightVideo;

@implementation ECChatVideoCell (SightVideo)

- (void)setVideoDecoder:(PKLayerVideoDecoder *)videoDecoder {
    objc_setAssociatedObject(self, &ec_chat_SightVideo, videoDecoder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PKLayerVideoDecoder *)videoDecoder {
    return objc_getAssociatedObject(self, &ec_chat_SightVideo);
}
#pragma mark - 视频消息自动播放
- (void)ec_playSightVideo {
    
    if (self.videoDecoder != nil) {
        [self.videoDecoder stop];
        self.videoDecoder = nil;
    }
    if (![self.message.userData isEqualToString:EC_CHAT_SendSightvideo]) {
        return;
    }
    ECVideoMessageBody *mediaBody = (ECVideoMessageBody *)self.message.messageBody;
    
    if (mediaBody.localPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:mediaBody.localPath]) {
        self.videoDecoder = [[PKLayerVideoDecoder alloc] initWithVideoPath:mediaBody.localPath size:self.bgContenImgV.bounds.size];
        self.videoDecoder.delegate = self;
        self.videoDecoder.loop = YES;
        [self.videoDecoder start];
    }
}

- (void)ec_stopSightVideo {
    if (self.videoDecoder != nil) {
        [self.videoDecoder stop];
        self.videoDecoder = nil;
    }
}

#pragma mark - PKVideoDecoderDelegate
- (void)videoDecoderDidDecodeFrame:(PKLayerVideoDecoder *)decoder pixelBuffer:(CVImageBufferRef)imageBuffer  transform:(CGAffineTransform)transform{
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
    
    
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    if (!quartzImage) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.videoView.layer.contents = (__bridge id)(quartzImage);
        CGImageRelease(quartzImage);
    });
}

-(void)videoDecoderDidFinishDecoding:(PKLayerVideoDecoder *)decoder {
    
}
@end
