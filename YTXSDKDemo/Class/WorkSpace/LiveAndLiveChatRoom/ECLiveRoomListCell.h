//
//  ECLiveRoomListCell.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/6/22.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECLiveChatRoomListModel.h"

@interface ECLiveRoomListCell : UITableViewCell
- (void)configWithModel:(ECLiveChatRoomListModel *)model;
@end
