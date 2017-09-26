//
//  ECGroupListVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/26.
//
//

#import "ECGroupListVC.h"
#import "ECGroupCreateVC.h"
#import "ECGroupListCell.h"
#import "ECGroupSettingVC.h"
#import "ECChatController.h"
#import "ECGroupSearchResultVC.h"
#import <MJRefresh/MJRefresh.h>

@interface ECGroupListVC ()<UITableViewDelegate, UITableViewDataSource,ECBaseContollerDelegate>

@property (nonatomic, assign) ECGroupType groupType;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@end

@implementation ECGroupListVC

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECGroup *group = self.baseDataArray[indexPath.row];
    if (self.baseOneObjectCompletion) {
        EC_WS(self);
        [ECAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"是否确认转发消息给：", nil),self.title] message:group.name cancelTitle:NSLocalizedString(@"取消", nil) DestructiveTitle:nil DefautTitleArray:@[NSLocalizedString(@"转发", nil)] showInView:self handler:^(UIAlertAction *action) {
            if ([action.title isEqualToString:NSLocalizedString(@"转发", nil)]) {
                weakSelf.baseOneObjectCompletion(group.groupId);
            }
        }];
    } else {
        ECChatController *chatVC = [[ECChatController alloc] init];
        ECSession *session = [[ECSession alloc] init];
        session.sessionId = group.groupId;
        session.sessionName = group.name;
        session.dateTime = 0;
        session.type = group.isDiscuss ? EC_Session_Type_Discuss : EC_Session_Type_Group;
        session.msgType = 0;
        session.text = @"";//[rs stringForColumn:@"text"];
        session.unreadCount = 0;
        session.sumCount = 0;
        session.isAt = NO;
        session.isTop = [[ECDBManager sharedInstanced].sessionMgr selectSession:group.groupId].isTop;
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp = [date timeIntervalSince1970]*1000;
        session.dateTime = (long long)tmp;
        session.memberCount = group.memberCount;
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_ClickSession object:session];
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ECGroupListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Group_Cell"];
    ECGroup *group = self.baseDataArray[indexPath.row];
    cell.group = group;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.baseDataArray.count;
}

#pragma mark - UI
- (void)buildUI{
    self.groupType = [self.basePushData intValue];
    self.title = self.groupType == ECGroupType_Discuss ?  NSLocalizedString(@"讨论组", nil) : NSLocalizedString(@"群组", nil);
    self.baseDelegate = self;
    [super buildUI];
    self.definesPresentationContext = YES;
    [self.view addSubview:self.tableView];
    EC_WS(self)
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
}

- (void)ec_addNotify {
    EC_WS(self)
    [[ECDevice sharedInstance].messageManager queryOwnGroupsWith:self.groupType completion:^(ECError *error, NSArray *groups) {
        if(error.errorCode == ECErrorType_NoError) {
            if (groups.count == 0)
                [[ECDBManager sharedInstanced].groupInfoMgr deleteAllGroupList];
            else
                [[ECDBManager sharedInstanced].groupInfoMgr insertGroups:groups];
            [weakSelf.baseDataArray removeAllObjects];
            weakSelf.baseDataArray = [NSMutableArray arrayWithArray:groups];
            [weakSelf.tableView reloadData];
        } else {
            [[ECDBManager sharedInstanced].groupInfoMgr selectGroupWithType:self.groupType completion:^(NSArray *array) {
                [weakSelf.baseDataArray removeAllObjects];
                weakSelf.baseDataArray = [NSMutableArray arrayWithArray:array];
                [weakSelf.tableView reloadData];
            }];
        }
    }];
}
#pragma mark - ECBaseContollerDelegate
- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString *__autoreleasing *)str {
    *str = @"messageNavbtnGo";
    return ^id{
        [self.navigationController ec_pushViewController:[[NSClassFromString(@"ECGroupCreateVC") alloc] init] animated:YES data:@(self.groupType == ECGroupType_Discuss)];
        return nil;
    };
}
#pragma mark - 懒加载
- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 70;
        _tableView.sectionHeaderHeight = 30;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundView.backgroundColor = EC_Color_VCbg;
        if(self.groupType == ECGroupType_Group)
            _tableView.tableHeaderView = self.searchController.searchBar;
        [_tableView registerClass:[ECGroupListCell class] forCellReuseIdentifier:@"Group_Cell"];
    }
    return _tableView;
}

- (UISearchController *)searchController{
    if(!_searchController){
        ECGroupSearchResultVC *result = [[ECGroupSearchResultVC alloc] init];
        _searchController = [[UISearchController alloc] initWithSearchResultsController:result];
        _searchController.searchResultsUpdater = result;
        _searchController.searchBar.delegate = result;
        _searchController.searchBar.placeholder = NSLocalizedString(@"群组id或名称搜索",nil);
        _searchController.searchBar.searchBarStyle =UISearchBarStyleMinimal;
        _searchController.searchBar.frame = CGRectMake(0, 0, EC_kScreenW, 44.0);
        _searchController.searchBar.backgroundColor = EC_Color_White;
    }
    return _searchController;
}

@end
