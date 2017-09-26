//
//  ECTransmitMessageController.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/25.
//

#import "ECTransmitMessageController.h"
#import "ECNewFriendVC.h"
#import "ECGroupListVC.h"
#import "ECCreateMeetingVC.h"
#import "ECFriend.h"
#import "ECFriendManager.h"
#import "ECChatController.h"
#import "ECContactSearchResultVC.h"
#import "ECContactCell.h"

#define ec_contactlistvc_search_h 44.0f

@interface ECTransmitMessageController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) NSArray *firstLetters;
@property (nonatomic, strong) NSDictionary *firstLetterDic;
@property (nonatomic, strong) ECMessage *message;
@end

@implementation ECTransmitMessageController

#pragma mark - 好友关系数据获取

/**
 @brief 首先取数据库中的数据展示，然后从服务器同步获取，获取成功则展示
 */
- (void)fetchFriendList{
    self.connectArray = [[ECFriendManager sharedInstanced] fetchFriendFromDB];
    [[ECFriendManager sharedInstanced] fetchFriendFromServer:^(NSMutableArray *friends) {
        if(friends && friends.count > 0)
            self.connectArray = friends;
    }];
}

- (void)updateFriendInfo{
    self.connectArray = [[ECFriendManager sharedInstanced] fetchFriendFromDB];
}

- (void)setConnectArray:(NSMutableArray *)connectArray{
    self.firstLetterDic = [[ECFriendManager sharedInstanced] firstLetterFriend:connectArray];
    self.firstLetters = [[ECFriendManager sharedInstanced]firstLetters:self.firstLetterDic];
    [self.myTableView reloadData];
}
#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.firstLetters.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.dataArray.count : [self.firstLetterDic[self.firstLetters[section - 1]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ECContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConnectCell_Cell"];
    if(indexPath.section == 0){
        NSDictionary *dic = self.dataArray[indexPath.row];
        cell.imageView.image = EC_Image_Named(dic[@"image"]);
        cell.textLabel.text = dic[@"text"];
        cell.textLabel.font = EC_Font_System(15);
    }else{
        ECFriend *friend = self.firstLetterDic[self.firstLetters[indexPath.section - 1]][indexPath.row];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:friend.avatar] placeholderImage:EC_Image_Named(@"messageIconHeader")];
        if(friend.remarkName && friend.remarkName.length > 0)
            cell.textLabel.text = friend.remarkName;
        else if(friend.nickName && friend.nickName.length > 0)
            cell.textLabel.text = friend.nickName;
        else{
            cell.textLabel.text = friend.useracc;
        }
        cell.textLabel.font = EC_Font_System(15);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0) {
        NSDictionary *dic = self.dataArray[indexPath.row];
        UIViewController *vc = [[NSClassFromString(@"ECGroupListVC") alloc] initWithBaeOneObjectCompletion:^(id data) {
            [[ECDeviceHelper sharedInstanced] ec_sendTransimitMessage:self.message to:data];
        } nothingTitle:[NSString stringWithFormat:@"您还没有创建任何%@,点击右上角+按钮创建",dic[@"text"]]];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController ec_pushViewController:vc animated:YES data:@(indexPath.row?ECGroupType_Discuss:ECGroupType_Group)];
    } else {
        ECFriend *friend = self.firstLetterDic[self.firstLetters[indexPath.section - 1]][indexPath.row];
        [ECAlertController alertControllerWithTitle:NSLocalizedString(@"是否确认转发消息给好友：", nil) message:[friend displayName] cancelTitle:NSLocalizedString(@"取消", nil) DestructiveTitle:nil DefautTitleArray:@[NSLocalizedString(@"转发", nil)] showInView:self handler:^(UIAlertAction *action) {
            if ([action.title isEqualToString:NSLocalizedString(@"转发", nil)]) {
                [[ECDeviceHelper sharedInstanced] ec_sendTransimitMessage:self.message to:friend.useracc];
            }
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        return 44.0f;
    }
    return 65.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *sectionView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ECContact_Section"];
    sectionView.textLabel.text = self.firstLetters[section - 1];
    return sectionView;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray *tmpArr = [self.firstLetters mutableCopy];
    [tmpArr insertObject:UITableViewIndexSearch atIndex:0];
    return tmpArr;
}
#pragma mark - UI创建
- (void)buildUI {
    self.title = NSLocalizedString(@"选择联系人", nil);
    [self.view addSubview:self.myTableView];
    self.connectArray = [NSMutableArray array];
    self.firstLetters = [NSArray array];
    self.firstLetterDic = [NSDictionary dictionary];
    self.myTableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    self.dataArray = @[@{@"image":@"addressbookIconQunzu", @"text":NSLocalizedString(@"群组",nil)}, @{@"image":@"addressbookIconTaolunzu", @"text":NSLocalizedString(@"讨论组",@"讨论组")}];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendInfo) name:EC_DEMO_KNotice_UpdateFriendRemark object:nil];
    [self fetchFriendList];
    [super buildUI];
}

- (instancetype)initWithMessage:(ECMessage *)message {
    self = [super init];
    if (self) {
        self.message = [[ECMessageDB sharedInstanced] getMessageWithMessageId:message.messageId OfSession:message.sessionId];
    }
    return self;
}
#pragma mark - 懒加载
- (UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _myTableView.sectionIndexColor = EC_Color_Index_Text;
        _myTableView.backgroundColor = EC_Color_VCbg;
        _myTableView.sectionIndexBackgroundColor = EC_Color_Clear;
        [_myTableView setSectionIndexBackgroundColor:[UIColor clearColor]];
        [_myTableView registerClass:[ECContactCell class] forCellReuseIdentifier:@"ConnectCell_Cell"];
        [_myTableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"ECContact_Section"];
        _myTableView.tableFooterView = [[UIView alloc] init];
    }
    return _myTableView;
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
@end
