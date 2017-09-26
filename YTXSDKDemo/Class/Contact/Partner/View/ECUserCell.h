//
//  ECUserCell.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/26.
//
//

#import <UIKit/UIKit.h>
#import "ECAddressBook.h"
#import "ECAddRequestUser.h"
#import "ECFriend.h"

typedef NS_ENUM(NSUInteger, ECUserOperationType) {
    ECUserOperationType_None,//群组邀请成员多选
    ECUserOperationType_Add,//添加好友
    ECUserOperationType_Request,//好友请求
    ECUserOperationType_Forbid,//禁言
    ECUserOperationType_AdminSet,//设置群组管理员
    ECUserOperationType_Delete,//删除会议成员
    ECUserOperationType_GroupNotice,//群组通知
    ECUserOperationType_FriendNotice,//好友通知
};
@interface ECUserCell : UITableViewCell

@property (nonatomic, assign) ECUserOperationType contactType;
@property (nonatomic, strong) ECAddressBook *addressBook;//添加好友选择联系人/创建群组邀请成员
@property (nonatomic, strong) ECAddRequestUser *addRequestUser;//好友添加请求

@property (nonatomic, strong) ECGroupMember *member;//ECGroumMemberOperation 群组操作

@property (nonatomic, strong) ECMultiVoiceMeetingMember *voiceMeetingMember;//语音群聊操作

@property (nonatomic, strong) ECFriend *friendInfo;//

@property (nonatomic, strong) ECGroupNoticeMessage *groupNoticeMessage;
@property (nonatomic, strong) ECFriendNoticeMsg *friendNoticeMessage;

@property (nonatomic, weak) UIButton *agreeBtn;

@property (nonatomic, copy) NSString *groupId;

@property (nonatomic, copy) void (^completionOperation)(ECUserCell *cell);

@end
