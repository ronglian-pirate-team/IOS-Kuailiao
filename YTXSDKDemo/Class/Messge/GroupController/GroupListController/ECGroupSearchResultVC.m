//
//  ECGroupSearchResultVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/9/15.
//
//

#import "ECGroupSearchResultVC.h"
#import "ECGroupListCell.h"
#import "ECGroupInfoVC.h"

@interface ECGroupSearchResultVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong) ECGroupMatch *match;

@end

@implementation ECGroupSearchResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.match = [[ECGroupMatch alloc] init];
    self.match.pageSize = 30;
    self.match.pageNo = 0;
}

- (void)fetchGroups:(NSString *)searchText{
    self.match.keywords = searchText;
    NSString *regex = @"g[0-9]{9}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    EC_Demo_AppLog(@"%ld===%@", self.match.searchType, self.match.keywords);
    self.match.searchType = [predicate evaluateWithObject:searchText] ? ECGroupSearchType_GroupId : ECGroupSearchType_GroupName;
    [[ECDevice sharedInstance].messageManager searchPublicGroups:self.match completion:^(ECError *error, NSArray *groups) {
        if(error.errorCode == ECErrorType_NoError){
            [self.baseDataArray removeAllObjects];
            for (ECGroup *g in groups) {
                [self.baseDataArray addObject:g];
            }
            [self.tableView reloadData];
        }else{
        }
    }];
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECGroupInfoVC *infoVC = [[ECGroupInfoVC alloc] init];
    infoVC.group = self.baseDataArray[indexPath.row];
    [self.presentingViewController.navigationController pushViewController:infoVC animated:YES];
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

#pragma mark - UISearchResultsUpdating, UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self fetchGroups:searchBar.text];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
}

#pragma mark - UI创建
- (void)buildUI{
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, EC_kScreenH)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 70;
        _tableView.sectionHeaderHeight = 30;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundView.backgroundColor = EC_Color_VCbg;
        [_tableView registerClass:[ECGroupListCell class] forCellReuseIdentifier:@"Group_Cell"];
    }
    return _tableView;
}

@end
