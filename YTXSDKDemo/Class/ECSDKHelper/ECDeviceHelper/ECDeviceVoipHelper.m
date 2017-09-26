//
//  ECCameraConfig.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/22.
//
//

#import "ECDeviceVoipHelper.h"
#import "CameraDeviceInfo.h"

#define EC_UserDefault_CurResolution   @"EC_UserDefault_CurResolution"

@implementation ECDeviceVoipHelper

+ (instancetype)sharedInstanced {
    static ECDeviceVoipHelper* cameraConfig;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        cameraConfig = [[[self class] alloc] init];
    });
    return cameraConfig;
}

- (instancetype)init{
    if(self = [super init]){
        self.cameraInfoArray = [[ECDevice sharedInstance].VoIPManager getCameraInfo];
    }
    return self;
}

- (NSInteger)selectCamera:(NSInteger)cameraIndex{
    if (cameraIndex >= self.cameraInfoArray.count) {
        return -1;
    }
    NSInteger capabilityIndex = 1;//self.curResolutionIndex;
    CameraDeviceInfo *camera = [self.cameraInfoArray objectAtIndex:cameraIndex];
    if (capabilityIndex >= camera.capabilityArray.count) {
        capabilityIndex = 0;
    }
    CameraCapabilityInfo *capability = [camera.capabilityArray objectAtIndex:capabilityIndex];
    return [[ECDevice sharedInstance].VoIPManager selectCamera:cameraIndex capability:capabilityIndex fps:capability.maxfps rotate:Rotate_Auto];
}

#pragma mark - 属性设置
- (void)setCurResolutionIndex:(NSInteger)curResolution {
    [[NSUserDefaults standardUserDefaults] setObject:@(curResolution) forKey:EC_UserDefault_CurResolution];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)curResolutionIndex {
    NSNumber* nsResolution = [[NSUserDefaults standardUserDefaults] valueForKey:EC_UserDefault_CurResolution];
    if (nsResolution==nil) {
        return 1;
    }
    return nsResolution.integerValue;
}

//编解码设置
- (void)SetSDKCodecType:(ECCodec)type andEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setObject:@(enable) forKey:[NSString stringWithFormat:@"codec_enable_%ld",type]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[ECDevice sharedInstance].VoIPManager setCodecEnabledWithCodec:type andEnabled:enable];
}

-(BOOL)GetSDKIsEnableCodecType:(ECCodec)type {
    NSNumber* nsEnable = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"codec_enable_%ld",type]];
    if (nsEnable==nil) {
        return [[ECDevice sharedInstance].VoIPManager getCondecEnabelWithCodec:type];
    }
    return nsEnable.boolValue;
}

- (void)SetLasterSaveCodec {
    for (NSInteger index = Codec_iLBC; index<=Codec_OPUS8; index++) {
        NSNumber* nsEnable = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"codec_enable_%ld",index]];
        if (nsEnable) {
            [[ECDevice sharedInstance].VoIPManager setCodecEnabledWithCodec:index andEnabled:nsEnable.boolValue];
        }
    }
}
@end
