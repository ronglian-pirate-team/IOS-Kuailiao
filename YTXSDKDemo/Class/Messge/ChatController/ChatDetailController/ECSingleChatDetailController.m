//
//  ECSingleChatDetailController.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/11.
//

#import "ECSingleChatDetailController.h"
#import "ECGroupModeCell.h"

@interface ECSingleChatDetailController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray  *dataSource;
@end

@implementation ECSingleChatDetailController

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECBaseCellModel *model = self.dataSource[indexPath.section][indexPath.row];
    if ([model.text isEqualToString:NSLocalizedString(@"设置当前聊天背景",nil)]) {
        [self.navigationController ec_pushViewController:[[NSClassFromString(@"ECImagePickerController") alloc] init] animated:YES data:self.sessionId];
    } else if ([model.text isEqualToString:NSLocalizedString(@"清空聊天记录",nil)]) {
        EC_WS(self);
        [ECAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"是否确认删除聊天记录", nil) cancelTitle:NSLocalizedString(@"取消", nil) DestructiveTitle:@[NSLocalizedString(@"清空", nil)] DefautTitleArray:nil showInView:self handler:^(UIAlertAction *action) {
            EC_SS(weakSelf);
            if ([action.title isEqualToString:NSLocalizedString(@"清空",nil)]) {
                EC_Demo_AppLog(@"清空聊天记录");
                EC_ShowHUD(@"")
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[ECDBManager sharedInstanced].dbMgrUtil deleteAllMessageSaveSessionOfSessionId:strongSelf.sessionId];
                    EC_HideHUD;
                    [ECCommonTool toast:@"清除成功"];
                });
            }
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ECBaseCellModel *model = self.dataSource[indexPath.section][indexPath.row];
    ECGroupModeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ec_groupsetvc_cell_centerText"];
    if (!cell) {
        cell = [[ECGroupModeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ec_GroupSettingMode_Cell];
    }
    [cell ec_configMode:model];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

#pragma mark - UI创建
- (void)buildUI {
    self.sessionId = self.basePushData;
    self.title = NSLocalizedString(@"聊天详情", nil);
    [self.view addSubview:self.tableView];
    [super buildUI];
}

- (void)ec_addNotify {
    self.dataSource = [NSMutableArray arrayWithArray:@[
                                                       @[[ECBaseCellModel baseModelWithText:ec_group_settoptext detailText:nil img:nil modelType:ec_groupsetvc_cell_switch],
//                                                         [ECBaseCellModel baseModelWithText:ec_group_noticetext detailText:nil img:nil modelType:ec_groupsetvc_cell_switch]
                                                         ],
                                                       @[[ECBaseCellModel baseModelWithText:NSLocalizedString(@"设置当前聊天背景",nil) detailText:nil img:nil modelType:ec_groupsetvc_cell_disclosureIndicator]],
                                                       @[[ECBaseCellModel baseModelWithText:NSLocalizedString(@"清空聊天记录",nil) detailText:nil img:nil modelType:nil]]]
                                                       ];
}
#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 48.0f;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}
@end
