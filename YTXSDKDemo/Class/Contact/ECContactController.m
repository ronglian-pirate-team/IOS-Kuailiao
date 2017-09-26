//
//  ECContactController.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/24.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "ECContactController.h"
#import "ECCreateMeetingVC.h"
#import "ECFriend.h"
#import "ECFriendManager.h"
#import "ECChatController.h"
#import "ECContactSearchResultVC.h"
#import "ECFriendInfoDetailVC.h"
#import "ECContactCell.h"

#define ec_contactlistvc_search_h 44.0f

@interface ECContactController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) NSArray *firstLetters;
@property (nonatomic, strong) NSDictionary *firstLetterDic;

@end

@implementation ECContactController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.connectArray = [[ECFriendManager sharedInstanced] fetchFriendFromDB];
}

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendList) name:EC_KNOTIFICATION_onReceiveFriendNotiMsg object:nil];
    self.dataArray = @[@{@"image":@"addressbookIconNewfriend", @"text":NSLocalizedString(@"新的好友",nil)}, @{@"image":@"addressbookIconQunzu", @"text":NSLocalizedString(@"群组",nil)}, @{@"image":@"addressbookIconTaolunzu", @"text":NSLocalizedString(@"讨论组",@"讨论组")}];
    self.connectArray = [NSMutableArray array];
    self.firstLetters = [NSArray array];
    self.firstLetterDic = [NSDictionary dictionary];
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendInfo) name:EC_DEMO_KNotice_UpdateFriendRemark object:nil];
    [self fetchFriendList];
}

#pragma mark - 好友关系数据获取

/**
 @brief 首先取数据库中的数据展示，然后从服务器同步获取，获取成功则展示
 */
- (void)fetchFriendList{
    [self updateFriendInfo];
    [self updateFriendList];
}


/**
 @brief 修改好友备注等使用者自己操作的修改信息，信息修改成功后直接更新数据库，不需要在server获取，直接在数据库得到的即最新数据
 */
- (void)updateFriendInfo{
    self.connectArray = [[ECFriendManager sharedInstanced] fetchFriendFromDB];
}


/**
 @brief SDK 好友通知，增加、删除需从server获取最新数据，新数据同步本地数据库缓存
 */
- (void)updateFriendList{
    [[ECFriendManager sharedInstanced] fetchFriendFromServer:^(NSMutableArray *friends) {
        if(friends){
//            self.connectArray = friends;
        }
    }];
}

- (void)setConnectArray:(NSMutableArray *)connectArray{
    self.firstLetterDic = [[ECFriendManager sharedInstanced] firstLetterFriend:connectArray];
    self.firstLetters = [[ECFriendManager sharedInstanced]firstLetters:self.firstLetterDic];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECGroupType groupType = ECGroupType_NONE;
    if(indexPath.section == 0){
        ECBaseContoller *vc = nil;
        if(indexPath.row == 0){
            vc = [[NSClassFromString(@"ECNewFriendVC") alloc] init];
        }else if (indexPath.row == 1 || indexPath.row == 2){
            groupType = indexPath.row == 1?ECGroupType_Group:ECGroupType_Discuss;
            vc = [[NSClassFromString(@"ECGroupListVC") alloc] initWithBaeOneObjectCompletion:nil nothingTitle:[NSString stringWithFormat:@"您还没有创建任何%@,点击右上角+按钮创建",groupType==ECGroupType_Group?@"群组":@"讨论组"]];
        }
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController ec_pushViewController:vc animated:YES data:@(groupType)];
    }else{
        ECFriend *friend = self.firstLetterDic[self.firstLetters[indexPath.section - 1]][indexPath.row];
        ECFriendInfoDetailVC *detailVC = [[ECFriendInfoDetailVC alloc] init];
        detailVC.friendInfo = friend;
        detailVC.isFriendInfo = YES;
        detailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ECContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConnectCell_Cell"];
    if(indexPath.section == 0){
        NSDictionary *dic = self.dataArray[indexPath.row];
        cell.imageView.image = EC_Image_Named(dic[@"image"]);
        cell.textLabel.text = dic[@"text"];
        cell.textLabel.font = EC_Font_System(15);
    }else{
        ECFriend *friend = self.firstLetterDic[self.firstLetters[indexPath.section - 1]][indexPath.row];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:friend.avatar] placeholderImage:EC_Image_Named(@"messageIconHeader")];
        cell.textLabel.text = friend.displayName;
        cell.textLabel.font = EC_Font_System(15);
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *sectionView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ECContact_Section"];
    sectionView.textLabel.text = self.firstLetters[section - 1];
    return sectionView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? self.dataArray.count : [self.firstLetterDic[self.firstLetters[section - 1]] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 0 : 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.firstLetters.count + 1;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray *tmpArr = [self.firstLetters mutableCopy];
    [tmpArr insertObject:UITableViewIndexSearch atIndex:0];
    return tmpArr;
}

#pragma mark - UI创建
- (void)buildUI{
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    EC_WS(self);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    [super buildUI];
}

- (UISearchController *)searchController{
    if(!_searchController){
        ECContactSearchResultVC *result = [[ECContactSearchResultVC alloc] init];
        _searchController = [[UISearchController alloc] initWithSearchResultsController:result];
        _searchController.searchResultsUpdater = result;
        _searchController.searchBar.placeholder = NSLocalizedString(@"搜索",@"搜索");
        _searchController.hidesNavigationBarDuringPresentation = YES;
        _searchController.searchBar.searchBarStyle =UISearchBarStyleMinimal;
        _searchController.searchBar.frame = CGRectMake(0, 0, EC_kScreenW, 44.0);
    }
    return _searchController;
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 60;
        _tableView.sectionIndexColor = EC_Color_Index_Text;
        _tableView.backgroundColor = EC_Color_VCbg;
        _tableView.sectionIndexBackgroundColor = EC_Color_Clear;
        [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
        [_tableView registerClass:[ECContactCell class] forCellReuseIdentifier:@"ConnectCell_Cell"];
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"ECContact_Section"];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
