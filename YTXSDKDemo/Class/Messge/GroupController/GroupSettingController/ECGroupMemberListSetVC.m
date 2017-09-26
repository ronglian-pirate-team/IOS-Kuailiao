//
//  ECGroupMemberListVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/9/4.
//
//

#import "ECGroupMemberListSetVC.h"
#import "ECGroupMemberListCell.h"
#import "KCPinyinHelper.h"
#import "ECDemoGroupManage+Admin.h"

@interface ECGroupMemberListSetVC ()<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UISearchResultsUpdating, UISearchBarDelegate>
@property (nonatomic, assign) NSInteger isAdminOrCreaterSet;//0 查看成员 1 设置管理员  2 转让群
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, strong) NSArray *members;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *selectIndex;
@property (nonatomic, strong) NSArray *firstLetters;
@property (nonatomic, strong) NSDictionary *firstLetterDic;
@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation ECGroupMemberListSetVC

- (void)fetchDataOperation:(NSArray *)members{
    self.firstLetterDic = [self firstLetterContacts:members];
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

- (NSDictionary *)firstLetterContacts:(NSArray *)contacts{
    NSMutableDictionary *contactDic = [NSMutableDictionary dictionary];
    for (ECGroupMember *member in contacts) {
        if ([member isKindOfClass:[NSNull class]])
            continue;
        if(self.isAdminOrCreaterSet == 1 && member.role != ECMemberRole_Member)
            continue;
        NSString *firstLetter = [self firstLetter:member.display];
        if(member.role != ECMemberRole_Member)
            firstLetter = @" ";
        NSMutableArray *subArray = [contactDic objectForKey:firstLetter];
        if (!subArray) {
            subArray = [NSMutableArray array];
            [contactDic setObject:subArray forKey:firstLetter];
        }
        [subArray addObject:member];
    }
    return contactDic;
}

- (NSString *)firstLetter:(NSString *)name{
    NSString *firstLetter = [[KCPinyinHelper quickConvert:name] uppercaseString];
    if(!firstLetter || ![firstLetter isKindOfClass:[NSString class]])
        firstLetter = @"#";
    return firstLetter;
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex != alertView.cancelButtonIndex){
        NSString *firstLetter = self.firstLetters[self.selectIndex.section];
        ECGroupMember *groupMember = self.firstLetterDic[firstLetter][self.selectIndex.row];
        EC_ShowHUD(@"")
        [[ECDevice sharedInstance].messageManager setGroupMemberRole:self.groupId member:groupMember.memberId role:(self.isAdminOrCreaterSet == 1 ? ECMemberRole_Admin : ECMemberRole_Creator) completion:^(ECError *error, NSString *groupId, NSString *memberId) {
            EC_HideHUD
            if (error.errorCode == ECErrorType_NoError) {
                groupMember.role = (self.isAdminOrCreaterSet == 1 ? ECMemberRole_Admin : ECMemberRole_Creator);
                [[ECDemoGroupManage sharedInstanced].adminMembers addObject:groupMember];
                [[ECDBManager sharedInstanced].groupMemberMgr updateGroupMember:memberId memberRole:groupMember.role inGroup:self.groupId];
                [[ECDBManager sharedInstanced].groupMemberMgr updateGroupMember:[ECDevicePersonInfo sharedInstanced].userName memberRole:ECMemberRole_Member inGroup:self.groupId];
                if(self.isAdminOrCreaterSet == 2){
                    [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_ReloadGroupSetTable object:nil];
                }
                [ECCommonTool toast:@"设置成功"];
                [self.tableView reloadRowsAtIndexPaths:@[self.selectIndex] withRowAnimation:UITableViewRowAnimationNone];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [ECCommonTool toast:@"设置失败"];
            }
        }];
    }
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *firstLetter = self.firstLetters[indexPath.section];
    ECGroupMember *groupMember = self.firstLetterDic[firstLetter][indexPath.row];
    if(!self.isAdminOrCreaterSet)
        return;
    if(self.isAdminOrCreaterSet == 1 && groupMember.role != ECMemberRole_Member)
        return;
    if(self.isAdminOrCreaterSet == 2 && groupMember.role == ECMemberRole_Creator)
        return;
    self.selectIndex = indexPath;
    NSString *toUser = groupMember.display ? groupMember.display : groupMember.memberId;
    NSString *message = (self.isAdminOrCreaterSet == 1 ? [NSString stringWithFormat:@"设置%@为管理员", toUser] : [NSString stringWithFormat:@"转让群主给%@", toUser]);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) otherButtonTitles:NSLocalizedString(@"确定", nil), nil];
    [alert show];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ECGroupMemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ECGroupMemberList_Cell"];
    if(cell == nil){
        cell = [[ECGroupMemberListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ECGroupMemberList_Cell"];
    }
    NSString *firstLetter = self.firstLetters[indexPath.section];
    ECGroupMember *member = self.firstLetterDic[firstLetter][indexPath.row];
    cell.groupMember = member;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *sectionView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Contact_Section"];
    sectionView.textLabel.text = self.firstLetters[section];
    if(section == 0 && self.isAdminOrCreaterSet != 1){
        NSString *firstLetter = self.firstLetters[section];
        sectionView.textLabel.text = [NSString stringWithFormat:@"群主、管理员(%ld)", [self.firstLetterDic[firstLetter] count]];
    }
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

#pragma mark - UISearchResultsUpdating  UISearchBarDelegate
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSArray *searchArr = [[ECDemoGroupManage sharedInstanced] searchMembers:searchText inMembers:self.members];
    [self fetchDataOperation:searchArr];
}

#pragma mark - UI创建
- (void)buildUI{
    self.isAdminOrCreaterSet = [self.basePushData integerValue];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (self.isAdminOrCreaterSet == 1) {
        self.title = NSLocalizedString(@"添加管理员", nil);
        self.members = [[ECDemoGroupManage sharedInstanced] queryOrdinaryMembers];
    }else if (self.isAdminOrCreaterSet == 2) {
        self.title = NSLocalizedString(@"转让群", nil);
        self.members = [ECDemoGroupManage sharedInstanced].members;
    } else {
        self.title = NSLocalizedString(@"群成员", nil);
        EC_ShowHUD(@"正在加载...");
        [[ECDemoGroupManage sharedInstanced] queryGroupMembers:^(NSArray *demoMember) {
            EC_HideHUD;
            weakSelf.members = demoMember;
            [weakSelf.tableView reloadData];
            [weakSelf fetchDataOperation:weakSelf.members];
        }];
    }
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.view addSubview:self.tableView];
    self.groupId = [ECDemoGroupManage sharedInstanced].group.groupId;
    EC_WS(self)
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    [super buildUI];
}

- (void)ec_addNotify {
    [self fetchDataOperation:self.members];
}
#pragma mark - 懒加载
- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.rowHeight = 70;
        _tableView.sectionHeaderHeight = 30;
        _tableView.backgroundView.backgroundColor = EC_Color_VCbg;
        _tableView.sectionIndexColor = EC_Color_Index_Text;
        _tableView.sectionIndexBackgroundColor = EC_Color_Clear;
        [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"Contact_Section"];
    }
    return _tableView;
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

@end
