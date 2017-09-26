//
//  ECGroupListVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/14.
//
//

#import "ECGroupMemberListVC.h"
#import "KCPinyinHelper.h"

@interface ECGroupMemberListVC ()<UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate>

@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSArray *groupMembers;
@property (nonatomic, strong) NSArray *firstLetters;
@property (nonatomic, strong) NSDictionary *firstLetterDic;

@end

@implementation ECGroupMemberListVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - 获取/处理数据操作
- (void)fetchData{
    [[ECDevice sharedInstance].messageManager queryGroupMembers:self.groupId completion:^(ECError *error, NSString *groupId, NSArray *members) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[ECDBManager sharedInstanced].groupMemberMgr insertGroupMembers:members inGroup:groupId];
        });
        if(error.errorCode != ECErrorType_NoError){
            members = [[ECDBManager sharedInstanced].groupMemberMgr queryMembers:groupId];
        }
        self.groupMembers = members;
        self.firstLetterDic = [self firstLetterContacts:members];
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
    }];
}

- (NSDictionary *)firstLetterContacts:(NSArray *)contacts{
    NSMutableDictionary *contactDic = [NSMutableDictionary dictionary];
    for (ECGroupMember *member in contacts) {
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
    [self.view endEditing:YES];
    if(self.baseOneObjectCompletion){
        NSString *firstLetter = self.firstLetters[indexPath.section];
        ECGroupMember *member = self.firstLetterDic[firstLetter][indexPath.row];
        self.baseOneObjectCompletion(member);
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupMember_Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *firstLetter = self.firstLetters[indexPath.section];
    ECGroupMember *member = self.firstLetterDic[firstLetter][indexPath.row];
    cell.imageView.image = EC_Image_Named(@"messageIconWork");
    if(member.remark && member.remark.length){
        cell.textLabel.text = member.remark;
    }else if (member.display && member.display.length){
        cell.textLabel.text = member.display;
    }else if (member.memberId && member.memberId){
        cell.textLabel.text = member.memberId;
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

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
}

#pragma mark - UISearchBar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
//    NSArray *searchArr = [[ECAddressBookManager sharedInstance] searchContacts:searchText];
//    self.firstLetterDic = [[ECAddressBookManager sharedInstance] firstLetterContacts:searchArr];
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

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    searchBar.barTintColor = EC_Color_VCbg;
    searchBar.searchBarStyle = UISearchBarStyleDefault;
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
}

#pragma mark = UI创建
- (void)buildUI{
    self.groupId = self.basePushData;
    [self.view addSubview:self.tableView];
    EC_WS(self)
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view).offset(weakSelf.isEditing ? -50 : 0);
    }];
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.groupMembers = [NSArray array];
    [self fetchData];
    [super buildUI];
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
    if(!_tableView){
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
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"GroupMember_Cell"];
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"Contact_Section"];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

@end
