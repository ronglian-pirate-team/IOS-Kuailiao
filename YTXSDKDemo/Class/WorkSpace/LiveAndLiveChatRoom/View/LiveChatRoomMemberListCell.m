//
//  LiveChatRoomMemberListCell.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/25.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "LiveChatRoomMemberListCell.h"
#import "UIImageView+WebCache.h"

@interface LiveChatRoomMemberListCell ()

@end

@implementation LiveChatRoomMemberListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imgV.layer.cornerRadius = 20.0f;
    self.imgV.layer.masksToBounds = YES;
    self.imgV.userInteractionEnabled = YES;
}

- (void)setMember:(ECLiveChatRoomMember *)member {
    _member = member;
    NSInteger row = arc4random() % 8 +1;
    NSString *imgStr = [NSString stringWithFormat:@"def_usericon%d",(int)row];
    self.imgV.image = [UIImage imageNamed:imgStr];
    if (member.infoExt.length>0) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[member.infoExt dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        NSString *urlstr = dict[@"livechatroom_pimg"];
        NSURL *url = [NSURL URLWithString:urlstr];
        [self.imgV sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"chatui_head_bg"] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!image) {
                image = [UIImage imageNamed:imgStr];
            }
            self.imgV.image = image;
        }];
    }
}
@end
