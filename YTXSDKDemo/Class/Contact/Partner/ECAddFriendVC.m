//
//  ECAddFriendVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/26.
//
//

#import "ECAddFriendVC.h"
#import "ECUserCell.h"
#import "ECAddressBookManager.h"
#import "ECInviteBottomView.h"
#import "ECGroupListVC.h"
#import "ECMeetingInterphoneVC.h"
#import "ECFriendManager.h"
#import "ECFriendInfoDetailVC.h"
#import <MJRefresh/MJRefresh.h>
#import "ECDemoGroupManage.h"

@interface ECAddFriendVC ()<UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, weak) ECInviteBottomView *inviteBottomView;
@property (nonatomic, strong) NSMutableArray *selectArr;;

@end

@implementation ECAddFriendVC

#pragma mark - 数据操作
- (void)fetchData { //添加好友，从通讯录选择

    NSArray *allContacts = [[ECAddressBookManager sharedInstance] allContacts];
    self.firstLetterDic = [[ECAddressBookManager sharedInstance] firstLetterContacts:allContacts];
    self.firstLetters = [self.firstLetterDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *letter1 = obj1;
        NSString *letter2 = obj2;
        if ([letter1 characterAtIndex:0] < [letter2 characterAtIndex:0]) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    [self.tableView reloadData];
}

- (void)fetchFriendData { //邀请成员加入群组、实时对讲，从好友列表选取
    NSArray *friendArr = [[ECDBManager sharedInstanced].friendMgr queryAllFriend];
    self.firstLetterDic = [[ECFriendManager sharedInstanced] firstLetterFriend:friendArr];
    self.firstLetters = [[ECFriendManager sharedInstanced] firstLetters:self.firstLetterDic];
    [self.tableView reloadData];
}

#pragma mark - 类私有方法
- (void)confirmAction{
    NSMutableArray *inviteArr = [NSMutableArray array];
    for (NSIndexPath *index in self.tableView.indexPathsForSelectedRows) {
        NSArray *arr = self.firstLetterDic[self.firstLetters[index.section]];
        ECFriend *friend = arr[index.row];
        [inviteArr addObject:friend.useracc];
    }
    if(self.isEditing == 2){
        [self inviteMembers:self.groupId members:inviteArr isConfirm:2];
        return;
    }
    if(self.isEditing == 3){
        EC_ShowHUD(@"")
        [[ECDevice sharedInstance].meetingManager createInterphoneMeetingWithMembers:inviteArr andVoiceMode:2 completion:^(ECError *error, NSString *meetingNumber) {
            EC_HideHUD
            EC_Demo_AppLog(@"实时对讲创建结果：%ld====%@", error.errorCode, error.errorDescription);
            if(error.errorCode == ECErrorType_NoError){
                ECMeetingInterphoneVC *interphoneVC = [[ECMeetingInterphoneVC alloc] init];
                interphoneVC.meetingNum = meetingNumber;
                interphoneVC.isCreater = YES;
                [self.navigationController pushViewController:interphoneVC animated:YES];
                EC_Demo_AppLog(@"实时对讲创建成功");
            }else{
                [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"实时对讲创建结果：%ld====%@", error.errorCode, error.errorDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
                EC_Demo_AppLog(@"实时对讲创建失败");
            }
        }];
        return;
    }
    ECGroup *groupInfo = [[ECGroup alloc] init];
    groupInfo.name = self.groupName;
    groupInfo.city = self.selectCity;
    groupInfo.province = self.selectProvince;
    groupInfo.mode = self.groupMode;
    groupInfo.type = self.type;
    groupInfo.declared = self.groupDeclared;
    groupInfo.isDiscuss = self.isDiscuss;
    EC_WS(self)
    [[ECDevice sharedInstance].messageManager createGroup:groupInfo completion:^(ECError *error, ECGroup *group) {
        if(error.errorCode == ECErrorType_NoError){
            [ECCommonTool toast:@"创建成功"];
            NSArray *vcs = weakSelf.navigationController.viewControllers;
            [weakSelf.navigationController popToViewController:vcs[1] animated:YES];
            [self inviteMembers:group.groupId members:inviteArr isConfirm:1];
        }else{
            [ECCommonTool toast:error.errorDescription];
        }
    }];
}


/** 
 @brief 邀请成员加入群组

 @param groupId 加入的群组id
 @param members 邀请的人
 */
- (void)inviteMembers:(NSString *)groupId members:(NSArray *)members isConfirm:(NSInteger)confirm{
    EC_ShowHUD(@"")
    [[ECDevice sharedInstance].messageManager inviteJoinGroup:groupId reason:@"欢迎加入" members:members confirm:confirm completion:^(ECError *error, NSString *groupId, NSArray *members) {
        if(error.errorCode == ECErrorType_NoError){
            EC_Demo_AppLog(@"邀请加入群组成功 :%@",groupId);
            if(confirm == 1){
                [self insertMembers:members inGroup:groupId];
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            EC_Demo_AppLog(@"邀请加入群组失败, %@， code = %ld", error.errorDescription, error.errorCode);
        }
        EC_HideHUD
    }];
}

- (void)insertMembers:(NSArray *)members inGroup:(NSString *)groupId{
    NSMutableArray *memberArr = [NSMutableArray array];
    for (NSString *memberId in members) {
        ECGroupMember *member = [[ECGroupMember alloc] init];
        member.memberId = memberId;
        member.groupId = groupId;
        [memberArr addObject:member];
    }
    [[ECDBManager sharedInstanced].groupMemberMgr insertGroupMembers:memberArr inGroup:groupId];
    [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_ReloadGroupMember object:nil];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!self.isEditing){
        NSString *firstLetter = self.firstLetters[indexPath.section];
        ECAddressBook *addressBook = self.firstLetterDic[firstLetter][indexPath.row];
        ECFriendInfoDetailVC *detailVC = [[ECFriendInfoDetailVC alloc] init];
        ECFriend *f = [[ECFriend alloc] init];
        f.useracc = [addressBook.phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
        detailVC.friendInfo = f;
        [self.navigationController pushViewController:detailVC animated:YES];
        return;
    }
    NSString *firstLetter = self.firstLetters[indexPath.section];
    ECFriend *friend = self.firstLetterDic[firstLetter][indexPath.row];
    [self.selectArr addObject:friend];
    if(self.isEditing)
        self.inviteBottomView.selectCount = self.selectArr.count;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *firstLetter = self.firstLetters[indexPath.section];
    ECFriend *friend = self.firstLetterDic[firstLetter][indexPath.row];
    for (ECFriend *f in self.selectArr) {
        if([f.useracc isEqualToString:friend.useracc]){
           [self.selectArr removeObject:friend];
            break;
        }
    }
    if(self.isEditing)
        self.inviteBottomView.selectCount = tableView.indexPathsForSelectedRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ECUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewFriend_Cell"];
    if (cell==nil) {
        cell = [[ECUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NewFriend_Cell"];
    }
    NSString *firstLetter = self.firstLetters[indexPath.section];
    if(!self.isEditing){
        ECAddressBook *addressBook = self.firstLetterDic[firstLetter][indexPath.row];
        cell.addressBook = addressBook;
    }else{
        ECFriend *friend = self.firstLetterDic[firstLetter][indexPath.row];
        cell.friendInfo = friend;
        cell.contactType = ECUserOperationType_None;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        for (ECFriend *f in self.selectArr) {
            if([f.useracc isEqualToString:friend.useracc])
                [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *sectionView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Contact_Section"];
    sectionView.textLabel.text = self.firstLetters[section];
    return sectionView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.firstLetterDic[self.firstLetters[section]] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.firstLetters.count;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray *tmpArr = [self.firstLetters mutableCopy];
    [tmpArr insertObject:UITableViewIndexSearch atIndex:0];
    return tmpArr;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(!self.isEditing)
        return UITableViewCellEditingStyleNone;
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
}

#pragma mark - UISearchBar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchWithText:searchText];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    searchBar.barTintColor = EC_Color_VCbg;
    searchBar.searchBarStyle = UISearchBarStyleDefault;
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self searchWithText:@""];
}

- (void)searchWithText:(NSString *)searchText{
    if(self.isEditing){
        NSArray *friendArr = [[ECFriendManager sharedInstanced] searchContacts:searchText];
        self.firstLetterDic = [[ECFriendManager sharedInstanced] firstLetterFriend:friendArr];
        self.firstLetters = [[ECFriendManager sharedInstanced] firstLetters:self.firstLetterDic];
        [self.tableView reloadData];
    }else{
        NSArray *searchArr = [[ECAddressBookManager sharedInstance] searchContacts:searchText];
        self.firstLetterDic = [[ECAddressBookManager sharedInstance] firstLetterContacts:searchArr];
        self.firstLetters = [self.firstLetterDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *letter1 = obj1;
            NSString *letter2 = obj2;
            if([letter1 characterAtIndex:0] == '#')
                return NSOrderedDescending;
            if ([letter1 characterAtIndex:0] < [letter2 characterAtIndex:0]) {
                return NSOrderedAscending;
            }
            return NSOrderedDescending;
        }];
        [self.tableView reloadData];
    }
}

#pragma mark = UI创建
- (void)buildUI{
    self.selectArr = [NSMutableArray array];
    self.title = self.isEditing ? @"邀请新成员" : @"添加好友";
    [self.view addSubview:self.tableView];
    EC_WS(self)
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view).offset(weakSelf.isEditing ? -50 : 0);
    }];
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    if(self.isEditing){
        ECInviteBottomView *bottomView = [[ECInviteBottomView alloc] init];
        bottomView.createGroup = ^{
            [weakSelf confirmAction];
        };
        [self.view addSubview:bottomView];
        self.inviteBottomView = bottomView;
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(weakSelf.view);
            make.height.offset(50);
        }];
    }
    [self fetchBaseData];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf fetchBaseData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    _tableView.mj_header = header;
    [super buildUI];
}

- (void)fetchBaseData {
    self.isEditing?[self fetchFriendData]:[self fetchData];
}

- (UISearchController *)searchController{
    if(!_searchController){
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchResultsUpdater = self;
        _searchController.searchBar.delegate = self;
        _searchController.searchBar.placeholder = @"搜索";
        _searchController.hidesNavigationBarDuringPresentation = NO;
        _searchController.searchBar.searchBarStyle =UISearchBarStyleMinimal;
        _searchController.searchBar.frame = CGRectMake(0, 0, EC_kScreenW, 44.0);
    }
    return _searchController;
}

- (UITableView *)tableView{
    if(!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 70;
        _tableView.sectionHeaderHeight = 30;
        _tableView.backgroundView.backgroundColor = EC_Color_VCbg;
        _tableView.sectionIndexColor = EC_Color_Index_Text;
        _tableView.sectionIndexBackgroundColor = EC_Color_Clear;
        _tableView.editing = self.isEditing;
        [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"Contact_Section"];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

@end
