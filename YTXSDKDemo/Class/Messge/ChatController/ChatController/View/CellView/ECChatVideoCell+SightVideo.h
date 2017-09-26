//
//  ECChatVideoCell+SightVideo.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/20.
//

#import "ECChatVideoCell.h"
#import "PKLayerVideoDecoder.h"

@interface ECChatVideoCell (SightVideo)<PKVideoDecoderDelegate>

@property (nonatomic, strong) PKLayerVideoDecoder *videoDecoder;

- (void)ec_playSightVideo;
- (void)ec_stopSightVideo;
@end
