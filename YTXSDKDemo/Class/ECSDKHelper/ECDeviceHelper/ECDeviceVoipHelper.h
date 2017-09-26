//
//  ECDeviceVoipHelper.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/22.
//
//

#import <Foundation/Foundation.h>

@interface ECDeviceVoipHelper : NSObject

+ (instancetype)sharedInstanced;


@property (nonatomic, strong) NSArray *cameraInfoArray;
@property (nonatomic, assign) NSInteger curResolutionIndex;

- (NSInteger)selectCamera:(NSInteger)cameraIndex;

//编解码设置
- (void)SetSDKCodecType:(ECCodec)type andEnable:(BOOL)enable;
- (BOOL)GetSDKIsEnableCodecType:(ECCodec)type;
- (void)SetLasterSaveCodec;
@end
