//
//  LiveChatRoomMemberListCell.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/25.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveChatRoomMemberListCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgV;

@property (nonatomic, strong) ECLiveChatRoomMember *member;
@end
