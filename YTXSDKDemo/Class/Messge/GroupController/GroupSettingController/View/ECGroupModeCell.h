//
//  ECGroupModeCell.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/27.
//
//

#import <UIKit/UIKit.h>

#define ec_GroupSettingMode_Cell @"ec_GroupSettingMode_Cell"
#define ec_GroupSettingMode_Cell_CenterText @"ec_GroupSettingMode_Cell_CenterText"

#define ec_groupcreate_cell_isopen @"ec_groupcreate_cell_isopen"

#define ec_groupsetvc_cell_disclosureIndicator @"ec_groupsetvc_cell_disclosureIndicator"
#define ec_groupsetvc_cell_attact @"ec_groupsetvc_cell_attact"
#define ec_groupsetvc_cell_switch @"ec_groupsetvc_cell_switch"
#define ec_groupsetvc_cell_centerText @"ec_groupsetvc_cell_centerText"

#define ec_meetingcreate_cell_autodelete @"ec_meetingcreate_cell_autodelete"
#define ec_meetingcreate_cell_autodismiss @"ec_meetingcreate_cell_autodismiss"
#define ec_meetingcreate_cell_autojoin @"ec_meetingcreate_cell_autojoin"

#define ec_group_create_open NSLocalizedString(@"群设置为公开",nil)

#define ec_group_settoptext NSLocalizedString(@"置顶聊天",nil)
#define ec_group_noticetext NSLocalizedString(@"消息免打扰",nil)
#define ec_group_pushapnstext NSLocalizedString(@"消息推送",nil)

#define ec_group_forbidallmember NSLocalizedString(@"全员禁言",nil) // 全员禁言

#define ec_meetingl_autodelete NSLocalizedString(@"自动删除房间",nil)
#define ec_meetingl_autodismiss NSLocalizedString(@"创建人退出时自动解散",nil)
#define ec_meetingl_autojoin NSLocalizedString(@"创建后自动加入会议",nil)

@interface ECGroupModeCell : UITableViewCell

- (void)ec_configMode:(ECBaseCellModel *)cellModel;

@property (nonatomic, assign) BOOL isOpen;

@end
