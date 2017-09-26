//
//  ECNoticeController.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/28.
//
//

#import "ECNoticeController.h"
#import "ECUserCell.h"
#import "ECUserCell.h"
#import "ECContactCell.h"
#import "ECGroupNoticeCell.h"

@interface ECNoticeController ()<UITableViewDelegate, UITableViewDataSource,ECBaseContollerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ECNoticeController

/**
 邀请加入
ECGroupMessageType_Invite,
 申请加入
ECGroupMessageType_Propose,
 */

#pragma amrk - UITableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ECBaseNoticeMsg *msg = self.baseDataArray[indexPath.row];
    UITableViewCell *cell = nil;
    if (msg.baseType == ECBaseNoticeMsg_Type_Group) {
        ECGroupNoticeMessage *message = (ECGroupNoticeMessage *)msg;
        if(message.messageType == ECGroupMessageType_Dissmiss || message.messageType == ECGroupMessageType_Join || message.messageType == ECGroupMessageType_Quit || message.messageType == ECGroupMessageType_RemoveMember || message.messageType == ECGroupMessageType_ReplyInvite || message.messageType == ECGroupMessageType_ReplyJoin || message.messageType == ECGroupMessageType_ModifyGroup || message.messageType == ECGroupMessageType_ChangeAdmin || message.messageType == ECGroupMessageType_ChangeMemberRole || message.messageType == ECGroupMessageType_ModifyGroupMember || message.messageType == ECGroupMessageType_InviteJoin){
            cell = [tableView dequeueReusableCellWithIdentifier:@"ECNotice_Cell"];
            if(cell == nil){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ECNotice_Cell"];
                cell.textLabel.font = EC_Font_System(16);
                cell.textLabel.textColor = [UIColor colorWithHex:0x333333];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.imageView.image = EC_Image_Named(@"addressbookIconQunzu");
            cell.textLabel.text = [ECSession noticeConvertToSession:msg].text;
        }else if(message.messageType == ECGroupMessageType_Invite || message.messageType == ECGroupMessageType_Propose){
            cell = [tableView dequeueReusableCellWithIdentifier:@"EC_GroupNotice_Cell"];
            if (cell==nil) {
                cell = [[ECGroupNoticeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"EC_GroupNotice_Cell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [(ECGroupNoticeCell *)cell setGroupNoticeMessage:message];
        }
    } else if (msg.baseType == ECBaseNoticeMsg_Type_Friend) {
        ECFriendNoticeMsg *message = (ECFriendNoticeMsg *)msg;
        if (message.type == ECFriendNoticeMsg_Type_BecomeFriend || message.type == ECFriendNoticeMsg_Type_DeleteFriend || message.type == ECFriendNoticeMsg_Type_RejectFriend || message.type == ECFriendNoticeMsg_Type_AgreeFriend) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ECFriendNotice_Cell"];
            if(cell == nil){
                cell = [[ECContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ECFriendNotice_Cell"];
                cell.textLabel.font = EC_Font_System(16);
                cell.textLabel.textColor = [UIColor colorWithHex:0x333333];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [[SDImageCache sharedImageCache] removeImageForKey:message.avatarUrl fromDisk:NO withCompletion:nil];
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:message.avatarUrl] placeholderImage:EC_Image_Named(@"messageIconHeader") completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            }];
        } else if (message.type == ECFriendNoticeMsg_Type_AddFriend) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ECFriendNoticeOperation_Cell"];
            if (cell==nil) {
                cell = [[ECUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ECFriendNoticeOperation_Cell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [(ECUserCell *)cell setFriendNoticeMessage:message];
        }
        cell.textLabel.text = [ECSession noticeConvertToSession:msg].text;
    }
    cell.textLabel.numberOfLines = 0;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.baseDataArray.count;
}

#pragma mark - ECBaseContollerDelegate
- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString *__autoreleasing *)str {
    *str = NSLocalizedString(@"清除记录", nil);
    EC_WS(self);
    return ^id{
        [ECAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"是否确认删除记录", nil) cancelTitle:NSLocalizedString(@"取消", nil) DestructiveTitle:@[NSLocalizedString(@"删除记录", nil)] DefautTitleArray:nil showInView:weakSelf handler:^(UIAlertAction *action) {
            if ([action.title isEqualToString:NSLocalizedString(@"删除记录", nil)]) {
                EC_ShowHUD(NSLocalizedString(@"清除中...", nil));
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.baseDataArray removeAllObjects];
                    [weakSelf.tableView reloadData];
                    [[ECDBManager sharedInstanced].dbMgrUtil deleteAllMessageSaveSessionOfSessionId:[ECAppInfo sharedInstanced].sessionMgr.session.sessionId];
                    EC_HideHUD;
                });
            }
        }];
        return nil;
    };
}

- (void)addNoiceMsg:(NSNotification *)note {
    if ([note.object isKindOfClass:[ECBaseNoticeMsg class]]) {
        ECBaseNoticeMsg *msg = (ECBaseNoticeMsg *)note.object;
        [self.baseDataArray insertObject:msg atIndex:0];
        [self.tableView reloadData];
    }
}
#pragma mark - UI创建
- (void)buildUI{
    self.baseDelegate = self;
    self.title = NSLocalizedString(@"系统通知", nil);
    [self.view addSubview:self.tableView];
    EC_WS(self)
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
    [[ECDBManagerUtil sharedInstanced] selectNoticeCompletion:^(NSArray *array) {
        self.baseDataArray = [NSMutableArray arrayWithArray:array];
        [self.tableView reloadData];
    }];
    [super buildUI];
}

- (void)ec_addNotify {
    [ECDeviceDelegateConfigCenter sharedInstanced].isConversation = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNoiceMsg:) name:EC_KNOTIFICATION_ReceivedGroupNoticeMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNoiceMsg:) name:EC_KNOTIFICATION_onReceiveFriendNotiMsg object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [ECDeviceDelegateConfigCenter sharedInstanced].isConversation = NO;
}

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.estimatedRowHeight = 70;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[ECGroupNoticeCell class] forCellReuseIdentifier:@"EC_GroupNotice_Cell"];
    }
    return _tableView;
}

@end
