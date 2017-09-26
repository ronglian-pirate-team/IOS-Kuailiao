//
//  ECGroupSettingVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/28.
//
//

#import "ECGroupSettingVC.h"
#import "ECGroupModeCell.h"
#import "ECDemoGroupManage+Admin.h"


@interface ECGroupSettingVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) ECMemberRole role;
@property (nonatomic, strong) NSMutableArray *members;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIViewController *topVC;
@end

@implementation ECGroupSettingVC
{
    BOOL _isDiscuss;
    NSString *_changeTitle;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECBaseCellModel *model = self.dataArray[indexPath.section][indexPath.row];
    
    if ([model.text ec_MyContainsString:NSLocalizedString(@"名称", nil)]) {
        if(self.role == ECMemberRole_Member)
            return;
        UIViewController *nameVC = [[NSClassFromString(@"ECGroupNameUpdateVC") alloc] initWithBaeOneObjectCompletion:^(id data) {
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }];
        [self.navigationController pushViewController:nameVC animated:YES];
    } else if ([model.text ec_MyContainsString:NSLocalizedString(@"二维码", nil)]) {
        [self.navigationController pushViewController:[[NSClassFromString(@"ECGroupQRCodeVC") alloc] init] animated:YES];
    } else if ([model.text ec_MyContainsString:NSLocalizedString(@"公告", nil)]) {
        [self.navigationController ec_pushViewController:[[NSClassFromString(@"ECGroupDeclaredVC") alloc] init] animated:YES data:@(YES)];
    } else if ([model.text ec_MyContainsString:NSLocalizedString(@"名片", nil)]) {
        [self.navigationController ec_pushViewController:[[NSClassFromString(@"ECGroupCardVC") alloc] init] animated:YES data:model.text];
    } else if ([model.text ec_MyContainsString:NSLocalizedString(@"禁言", nil)]) {
        [self.navigationController ec_pushViewController:[[NSClassFromString(@"ECGroupMemberSetVC") alloc] init] animated:YES data:@(1)];
    } else if ([model.text ec_MyContainsString:NSLocalizedString(@"设置管理员", nil)]) {
        [self.navigationController ec_pushViewController:[[NSClassFromString(@"ECGroupMemberSetVC") alloc] init] animated:YES data:@(2)];
    } else if ([model.text ec_MyContainsString:NSLocalizedString(@"解散", nil)]) {
        [ECAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"是否确认解散群组", nil) cancelTitle:NSLocalizedString(@"取消", nil) DestructiveTitle:@[NSLocalizedString(@"解散", nil)] DefautTitleArray:nil showInView:self handler:^(UIAlertAction *action) {
            if([action.title isEqualToString:NSLocalizedString(@"解散",nil)])
                [[ECDemoGroupManage sharedInstanced] deleteGroup:[ECDemoGroupManage sharedInstanced].group.groupId];
        }];
    } else if ([model.text ec_MyContainsString:NSLocalizedString(@"清空聊天记录", nil)]) {
        [ECAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"是否确认删除聊天记录", nil) cancelTitle:NSLocalizedString(@"取消", nil) DestructiveTitle:@[NSLocalizedString(@"清空", nil)] DefautTitleArray:nil showInView:self handler:^(UIAlertAction *action) {
            if ([action.title isEqualToString:NSLocalizedString(@"清空",nil)]) {
                EC_Demo_AppLog(@"清空聊天记录");
                EC_ShowHUD(@"")
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[ECDBManager sharedInstanced].dbMgrUtil deleteAllMessageSaveSessionOfSessionId:[ECDemoGroupManage sharedInstanced].group.groupId];
                    EC_HideHUD;
                    [ECCommonTool toast:@"清除成功"];
                });
            }
        }];
    } else if ([model.text ec_MyContainsString:NSLocalizedString(@"退出", nil)]) {
        if (!_isDiscuss && self.role == ECMemberRole_Creator && [ECDemoGroupManage sharedInstanced].adminMembers.count==0) {
            [ECAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"您是该群群主，该群未指定管理员，是否指定管理员后退出",nil) cancelTitle:NSLocalizedString(@"确定", nil) DestructiveTitle:nil DefautTitleArray:nil showInView:self handler:nil];
        } else {
            
            [ECAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"是否确认退出", nil),_changeTitle] cancelTitle:NSLocalizedString(@"取消", nil) DestructiveTitle:@[NSLocalizedString(@"退出", nil)] DefautTitleArray:nil showInView:self handler:^(UIAlertAction *action) {
                if ([action.title isEqualToString:NSLocalizedString(@"退出",nil)]) {
                    [[ECDemoGroupManage sharedInstanced] exitGroup:[ECDemoGroupManage sharedInstanced].group.groupId];
                }
            }];
        }
    } else if ([model.text ec_MyContainsString:NSLocalizedString(@"转让", nil)]) {
        [self.navigationController ec_pushViewController:[[NSClassFromString(@"ECGroupMemberListSetVC") alloc] init] animated:YES data:@(2)];
    } else if ([model.text isEqualToString:NSLocalizedString(@"设置当前聊天背景",nil)]) {
        [self.navigationController ec_pushViewController:[[NSClassFromString(@"ECImagePickerController") alloc] init] animated:YES data:[ECDemoGroupManage sharedInstanced].group.groupId];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ECBaseCellModel *model = self.dataArray[indexPath.section][indexPath.row];
    ECGroupModeCell *cell = nil;
    if(![model.modelType isEqualToString:ec_groupsetvc_cell_centerText])
        cell = [tableView dequeueReusableCellWithIdentifier:ec_GroupSettingMode_Cell];
    else
        cell = [tableView dequeueReusableCellWithIdentifier:ec_GroupSettingMode_Cell_CenterText];
    if (!cell) {
        cell = [[ECGroupModeCell alloc] initWithStyle:[model.modelType isEqualToString:ec_groupsetvc_cell_centerText]?UITableViewCellStyleDefault:UITableViewCellStyleValue1 reuseIdentifier:[model.modelType isEqualToString:ec_groupsetvc_cell_centerText]?ec_GroupSettingMode_Cell_CenterText:ec_GroupSettingMode_Cell];
    }
    [cell ec_configMode:model];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

#pragma mark - UI创建
- (void)buildUI {
    _isDiscuss = [ECDemoGroupManage sharedInstanced].group.isDiscuss;
    _changeTitle = _isDiscuss?NSLocalizedString(@"讨论组",nil):NSLocalizedString(@"群组",nil);
    self.title = [NSString stringWithFormat:@"%@%@",_changeTitle,NSLocalizedString(@"设置",nil)];
    self.role = [ECDemoGroupManage sharedInstanced].group.selfRole;
    [self.view addSubview:self.tableView];
    [super buildUI];
}

- (void)ec_addNotify {
    [self handleModel];
    EC_WS(self)
    [[ECDemoGroupManage sharedInstanced] queryGroup:nil];
    [[NSNotificationCenter defaultCenter] addObserverForName:EC_DEMO_KNotice_ReloadGroupSetTable object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_ReloadGroupMember object:nil];
        [weakSelf handleModel];
        weakSelf.role = [ECDemoGroupManage sharedInstanced].group.selfRole;
        [weakSelf.tableView reloadData];
    }];
    _topVC = [[NSClassFromString(@"ECGroupSettingTopVC") alloc] init];
    _tableView.tableHeaderView = _topVC.view;
    [self addChildViewController:_topVC];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _tableView.tableHeaderView = nil;
    [_topVC removeFromParentViewController];
}

- (void)handleModel {
    NSMutableArray *array1 = [NSMutableArray arrayWithArray:@[
                                                              [ECBaseCellModel baseModelWithText:[NSString stringWithFormat:@"%@%@",_changeTitle,NSLocalizedString(@"名称",nil)] detailText:[ECDemoGroupManage sharedInstanced].group.name img:nil modelType:ec_groupsetvc_cell_disclosureIndicator],
                                                              [ECBaseCellModel baseModelWithText:[NSString stringWithFormat:@"%@%@",_changeTitle,NSLocalizedString(@"二维码",nil)] detailText:nil img:nil modelType:ec_groupsetvc_cell_attact],
                                                              [ECBaseCellModel baseModelWithText:[NSString stringWithFormat:@"%@%@",_changeTitle,NSLocalizedString(@"公告",nil)] detailText:nil img:nil modelType:ec_groupsetvc_cell_disclosureIndicator],
                                                              [ECBaseCellModel baseModelWithText:[NSString stringWithFormat:@"%@%@",_changeTitle,NSLocalizedString(@"名片",nil)] detailText:nil img:nil modelType:ec_groupsetvc_cell_disclosureIndicator]]];
    (_isDiscuss || self.role ==ECMemberRole_Member)?:[array1 addObject:
                                                      [ECBaseCellModel baseModelWithText:[NSString stringWithFormat:@"设置%@%@",[_changeTitle substringToIndex:_changeTitle.length-1],NSLocalizedString(@"禁言",nil)] detailText:nil img:nil modelType:ec_groupsetvc_cell_disclosureIndicator]];
    (self.role == ECMemberRole_Member || _isDiscuss)?:[array1 addObject:
                                       [ECBaseCellModel baseModelWithText:NSLocalizedString(@"设置管理员",nil) detailText:nil img:nil modelType:ec_groupsetvc_cell_disclosureIndicator]];
    
    NSMutableArray *array2 = [NSMutableArray array];
    (_isDiscuss || self.role != ECMemberRole_Creator)?:[array2 addObjectsFromArray:@[
                                                                                     [ECBaseCellModel baseModelWithText:[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"转让",nil),_changeTitle] detailText:nil img:nil modelType:nil],
                                                                                     [ECBaseCellModel baseModelWithText:[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"解散",nil),_changeTitle] detailText:nil img:nil modelType:nil],
                                                                                     ]];
    self.dataArray = [NSMutableArray arrayWithArray:@[
                                                      array1,
                                                      @[[ECBaseCellModel baseModelWithText:ec_group_settoptext detailText:nil img:nil modelType:ec_groupsetvc_cell_switch],
                                                          [ECBaseCellModel baseModelWithText:ec_group_noticetext detailText:nil img:nil modelType:ec_groupsetvc_cell_switch],
                                                        [ECBaseCellModel baseModelWithText:ec_group_pushapnstext detailText:nil img:nil modelType:ec_groupsetvc_cell_switch]],
                                                      array2,
                                                      @[[ECBaseCellModel baseModelWithText:NSLocalizedString(@"设置当前聊天背景",nil) detailText:nil img:nil modelType:ec_groupsetvc_cell_disclosureIndicator]],
                                                      @[[ECBaseCellModel baseModelWithText:NSLocalizedString(@"清空聊天记录",nil) detailText:nil img:nil modelType:nil]],
                                                      @[[ECBaseCellModel baseModelWithText:[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"退出",nil),_changeTitle] detailText:nil img:nil modelType:ec_groupsetvc_cell_centerText]],
                                                      ]];
    array2.count!=0?:[self.dataArray removeObject:array2];
}
#pragma mark - 懒加载
- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 44.0;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = EC_Color_VCbg;
    }
    return _tableView;
}
@end
