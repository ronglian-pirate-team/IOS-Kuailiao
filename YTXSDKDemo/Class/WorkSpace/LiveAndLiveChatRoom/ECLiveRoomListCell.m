//
//  ECLiveRoomListCell.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/6/22.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ECLiveRoomListCell.h"
#import "UIImageView+WebCache.h"

@interface ECLiveRoomListCell ()
@property (strong, nonatomic) IBOutlet UIImageView *avaImg;
@property (strong, nonatomic) IBOutlet UILabel *roomName;
@property (strong, nonatomic) IBOutlet UILabel *roomL;
@property (strong, nonatomic) IBOutlet UIImageView *bigImgV;

@end

@implementation ECLiveRoomListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configWithModel:(ECLiveChatRoomListModel *)model {
    if (model) {
        self.roomName.text = model.name.length>0?model.name:@"房间昵称为空";
        self.roomL.text = model.roomId;
        [self.bigImgV sd_setImageWithURL:[NSURL URLWithString:model.portrait] placeholderImage:[UIImage imageNamed:@"liveroom_list_big"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                self.bigImgV.image = image;
            }
        }];
    }
}
@end
