//
//  ECGroupDeleteMemberVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/15.
//
//

#import "ECGroupMemberOperationVC.h"
#import "ECInviteBottomView.h"
#import "ECUserCell.h"
#import "KCPinyinHelper.h"
#import "ECDemoGroupManage+Forbid.h"

@interface ECGroupMemberOperationVC ()<UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *members;
@property (nonatomic, strong) ECGroup *group;
@property (nonatomic, assign) ECGroupMemberOperation operation;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, weak) ECInviteBottomView *inviteBottomView;
@property (nonatomic, strong) NSMutableArray *selectArr;;
@property (nonatomic, strong) NSArray *firstLetters;
@property (nonatomic, strong) NSDictionary *firstLetterDic;

@end

@implementation ECGroupMemberOperationVC

- (void)fetchData:(NSArray *)members{
    self.firstLetterDic = [self firstLetterContacts:members];
    self.firstLetters = [self.firstLetterDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *letter1 = obj1;
        NSString *letter2 = obj2;
//        if([letter1 characterAtIndex:0] == '#')
//            return NSOrderedDescending;
        if ([letter1 characterAtIndex:0] < [letter2 characterAtIndex:0]) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    [self.tableView reloadData];
}

- (void)groupMemberOperation{
    if(self.operation == ECGroupMemberOperation_Delete){
        [self deleteGroupMember];
    }else if(self.operation == ECGroupMemberOperation_Forbid){
        [self silenceGroupMember];
    }
}

- (void)silenceGroupMember{
    EC_ShowHUD(@"正在设置...")
    NSMutableArray *members = [NSMutableArray array];
    for (NSIndexPath *index in self.tableView.indexPathsForSelectedRows) {
        NSArray *arr = self.firstLetterDic[self.firstLetters[index.section]];
        ECGroupMember *member = arr[index.row];
        [members addObject:member];
    }
    [[ECDemoGroupManage sharedInstanced] forbidMembers:members completion:^{
        EC_HideHUD
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)deleteGroupMember{
    EC_ShowHUD(@"")
    NSMutableArray *tmpArr = [NSMutableArray array];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    for (NSIndexPath *index in self.tableView.indexPathsForSelectedRows) {
        NSArray *arr = self.firstLetterDic[self.firstLetters[index.section]];
        ECGroupMember *m = arr[index.row];
        dispatch_group_enter(dispatchGroup);
        [[ECDevice sharedInstance].messageManager deleteGroupMember:self.group.groupId member:m.memberId completion:^(ECError *error, NSString *groupId, NSString *member) {
            dispatch_group_leave(dispatchGroup);
            if(error.errorCode == ECErrorType_NoError){
                EC_Demo_AppLog(@"删除成功");
                for (ECGroupMember *m in self.members) {
                    if([m.memberId isEqualToString:member]){
                        [[ECDemoGroupManage sharedInstanced].members removeObject:m];
                        [[ECDBManager sharedInstanced].groupMemberMgr deleteMember:m.memberId inGroup:groupId];
                    }else{
                        [tmpArr addObject:m];
                    }
                }
            }else{
                [ECCommonTool toast:error.errorDescription];
            }
        }];
    }
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^(){
        EC_HideHUD
//        [ECDemoGroupManage sharedInstanced].members = [[[ECDBManager sharedInstanced].groupMemberMgr queryMembers:self.group.groupId] mutableCopy];
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_ReloadGroupMember object:nil];
        [self.navigationController popViewControllerAnimated:YES];
        if(self.baseOneObjectCompletion)
            self.baseOneObjectCompletion(tmpArr);
    });
}

- (NSDictionary *)firstLetterContacts:(NSArray *)contacts{
    NSMutableDictionary *contactDic = [NSMutableDictionary dictionary];
    for (ECGroupMember *member in contacts) {
        if((self.operation == ECGroupMemberOperation_Forbid && member.speakStatus == ECSpeakStatus_Forbid))
            continue;
        if(member.role == ECMemberRole_Creator || self.group.selfRole == member.role)
            continue;
        NSString *firstLetter = [self firstLetter:member.display];
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

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *firstLetter = self.firstLetters[indexPath.section];
    ECGroupMember *member = self.firstLetterDic[firstLetter][indexPath.row];
    [self.selectArr addObject:member];
    self.inviteBottomView.selectCount = self.selectArr.count;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *firstLetter = self.firstLetters[indexPath.section];
    ECGroupMember *member = self.firstLetterDic[firstLetter][indexPath.row];
    for (ECGroupMember *m in self.selectArr) {
        if([m.memberId isEqualToString:member.memberId]){
            [self.selectArr removeObject:member];
            break;
        }
    }
    self.inviteBottomView.selectCount = tableView.indexPathsForSelectedRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ECUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeleteMember_Cell"];
    if (cell==nil) {
        cell = [[ECUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DeleteMember_Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    NSString *firstLetter = self.firstLetters[indexPath.section];
    ECGroupMember *member = self.firstLetterDic[firstLetter][indexPath.row];
    cell.contactType = ECUserOperationType_None;
    cell.member = member;
    for (ECGroupMember *m in self.selectArr) {
        if([m.memberId isEqualToString:member.memberId])
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
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
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
}

#pragma mark - UISearchBar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSArray *searchArr = [[ECDemoGroupManage sharedInstanced] searchMembers:searchText inMembers:self.members];
    [self fetchData:searchArr];
}

#pragma mark = UI创建
- (void)buildUI{
    self.operation = (ECGroupMemberOperation)[self.basePushData integerValue];
    self.group = [ECDemoGroupManage sharedInstanced].group;
    if(self.operation == ECGroupMemberOperation_Delete){
        self.title = NSLocalizedString(@"删除成员", nil);
        self.members = [ECDemoGroupManage sharedInstanced].members;
    }else if (self.operation == ECGroupMemberOperation_Forbid){
        self.title = NSLocalizedString(@"添加禁言成员", nil);
        self.members = [[ECDemoGroupManage sharedInstanced] unForbidMembers];;
    }
    self.selectArr = [NSMutableArray array];

    [self.view addSubview:self.tableView];
    EC_WS(self)
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view).offset(-50);
    }];
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    ECInviteBottomView *bottomView = [[ECInviteBottomView alloc] init];
    bottomView.operationTitle = self.operation == ECGroupMemberOperation_Delete ? NSLocalizedString(@"删除", nil) : NSLocalizedString(@"确定", nil);
    bottomView.createGroup = ^{
        [weakSelf groupMemberOperation];
    };
    [self.view addSubview:bottomView];
    self.inviteBottomView = bottomView;
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(weakSelf.view);
        make.height.offset(50);
    }];
    
    [self fetchData:self.members];

    [super buildUI];
}

#pragma mark - 懒加载
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
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 70;
        _tableView.sectionHeaderHeight = 30;
        _tableView.backgroundView.backgroundColor = EC_Color_VCbg;
        _tableView.sectionIndexColor = EC_Color_Index_Text;
        _tableView.sectionIndexBackgroundColor = EC_Color_Clear;
        _tableView.editing = YES;
        [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"Contact_Section"];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

@end
