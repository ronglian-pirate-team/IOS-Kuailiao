//
//  ECNewFriendVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/26.
//
//

#import "ECNewFriendVC.h"
#import "ECUserCell.h"
#import "ECAddressBookManager.h"

@interface ECNewFriendVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *friendArr;
@property (nonatomic, strong) NSArray *recommendArr;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ECNewFriendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.friendArr = [NSMutableArray array];
    self.recommendArr = [[ECAddressBookManager sharedInstance] recommendContacts];
    self.dataArray = [NSMutableArray array];
    [self fetchUserRequest];
}

#pragma mark - 获取数据
- (void)fetchUserRequest{
    ECRequestFriendAddList *fr = [[ECRequestFriendAddList alloc] init];
    fr.useracc = [ECSDK_Key stringByAppendingFormat:@"#%@",[ECAppInfo sharedInstanced].persionInfo.userName];
    fr.size = @"20";
    fr.timestamp = @"";
    EC_ShowHUD(@"")
    [[ECAFNHttpTool sharedInstanced] requestAddFriendList:fr completion:^(NSString *errCode, id responseObject) {
        EC_HideHUD
        if(errCode.integerValue == 0 && responseObject[@"inviteList"]){
            for (NSDictionary *userDic in responseObject[@"inviteList"]) {
                ECAddRequestUser *user = [[ECAddRequestUser alloc] init];
                [user setValuesForKeysWithDictionary:userDic];
                [self.dataArray addObject:user];
            }
            [[ECDBManager sharedInstanced].addRequestMgr insertAddRequests:self.dataArray];
            [self.tableView reloadData];
        }else{
            if([responseObject isKindOfClass:[NSString class]]){
//                [ECCommonTool toast:responseObject];
            }
        }
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ECUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewFriend_Cell"];
    if (cell==nil)
        cell = [[ECUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NewFriend_Cell"];
    if(self.dataArray.count == 0 || (self.dataArray.count > 0 && indexPath.section == 1)){
        ECAddressBook *addressBook = self.recommendArr[indexPath.row];
        cell.addressBook = addressBook;
        return cell;
    }else{
        ECAddRequestUser *user = self.dataArray[indexPath.row];
        cell.addRequestUser = user;
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataArray.count == 0)
        return self.recommendArr.count;
    return section == 0 ? self.dataArray.count : self.recommendArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    int sectionNum = 0;
    sectionNum += (self.dataArray.count > 0 ? 1 : 0);
    sectionNum += (self.recommendArr.count > 0 ? 1 : 0);
    return sectionNum;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *sectionView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"NewFriend_Section"];
    if(self.dataArray.count == 0)
        sectionView.textLabel.text = @"好友推荐";
    else
        sectionView.textLabel.text = (section == 0 ? @"好友通知" : @"好友推荐");
    return sectionView;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *sectionView = (UITableViewHeaderFooterView *)view;
    sectionView.textLabel.font = EC_Font_System(14);
    sectionView.textLabel.textColor = EC_Color_Sec_Text;
}

#pragma mark = UI创建
- (void)buildUI{
    self.title = @"新的好友";
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
        _tableView.rowHeight = 70;
        _tableView.sectionHeaderHeight = 30;
        _tableView.backgroundView.backgroundColor = EC_Color_VCbg;
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"NewFriend_Section"];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

@end
