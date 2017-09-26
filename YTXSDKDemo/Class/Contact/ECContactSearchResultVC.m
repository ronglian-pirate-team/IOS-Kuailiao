//
//  ECContactSearchResultVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/22.
//
//

#import "ECContactSearchResultVC.h"
#import "ECFriendManager.h"
#import "ECFriendInfoDetailVC.h"
#import "ECContactCell.h"

@interface ECContactSearchResultVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray *connectArray;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ECContactSearchResultVC

#pragma mark - UItableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECFriend *friend = self.connectArray[indexPath.row];
    ECFriendInfoDetailVC *detailVC = [[ECFriendInfoDetailVC alloc] init];
    detailVC.friendInfo = friend;
    detailVC.isFriendInfo = YES;
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.presentingViewController.navigationController pushViewController:detailVC animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ECContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConnectCell_Cell"];
    ECFriend *friend = self.connectArray[indexPath.row];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:friend.avatar] placeholderImage:EC_Image_Named(@"messageIconHeader")];
    cell.textLabel.text = friend.displayName;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.connectArray.count;
}

#pragma mark - UISearchResultsUpdating 代理方法
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *inputStr = searchController.searchBar.text ;
    self.connectArray = [[ECFriendManager sharedInstanced] searchContacts:inputStr];
    [self.tableView reloadData];
}

#pragma mark - UI创建
- (void)buildUI{
    [self.view addSubview:self.tableView];
    EC_WS(self)
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    [super buildUI];
}

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 60;
        _tableView.backgroundColor = EC_Color_VCbg;
        _tableView.sectionIndexBackgroundColor = EC_Color_Clear;
        [_tableView registerClass:[ECContactCell class] forCellReuseIdentifier:@"ConnectCell_Cell"];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

@end
