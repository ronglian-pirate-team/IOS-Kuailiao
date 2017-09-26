//
//  ECFriendInfoDetailVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/23.
//
//

#import "ECFriendInfoDetailVC.h"
#import "ECRemarkSetVC.h"
#import "ECFriendInfoDetailHeader.h"
#import "ECFriendInfoDetailFooter.h"
#import "ECFriendInfoDetailMoreVC.h"
#import "ECFriendManager.h"

@interface ECFriendInfoDetailVC ()<UITableViewDelegate, UITableViewDataSource, ECBaseContollerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ECFriendInfoDetailHeader *headerView;
@property (nonatomic, strong) ECFriendInfoDetailFooter *footerView;

@end

@implementation ECFriendInfoDetailVC

- (void)viewDidLoad {
    self.baseDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendInfo) name:EC_DEMO_KNotice_UpdateFriendRemark object:nil];
    [super viewDidLoad];
    [self fetchPersonInfo];
}

- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString *__autoreleasing *)str{
    *str = @"more";
    return ^id{
        ECFriendInfoDetailMoreVC *moreVC = [[ECFriendInfoDetailMoreVC alloc] init];
        moreVC.friendInfo = self.friendInfo;
        [self.navigationController pushViewController:moreVC animated:YES];
        return nil;
    };
}

- (void)fetchPersonInfo{
    NSString *useracc = self.friendInfo.useracc;
    if(!useracc)
        useracc = self.sessionId;
    if(self.isFriendInfo){
        [[ECFriendManager sharedInstanced] fetchFriendInfoFromServer:useracc completion:^(ECFriend *friend) {
            self.friendInfo = friend;
            self.headerView.friendInfo = friend;
            self.footerView.friendInfo = friend;
            [self.tableView reloadData];
        }];
    }else{
        [[ECFriendManager sharedInstanced] fetchPersonalInfoFromServer:useracc completion:^(ECFriend *friend) {
            self.friendInfo = friend;
            self.headerView.friendInfo = friend;
            self.footerView.friendInfo = friend;
            [self.tableView reloadData];
        }];
    }
}

- (void)updateFriendInfo{
    self.friendInfo = [[ECFriendManager sharedInstanced] fetchFriendFromDB:self.friendInfo.useracc];
    self.headerView.friendInfo = self.friendInfo;
    self.footerView.friendInfo = self.friendInfo;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0){
        ECRemarkSetVC *remarkVC = [[ECRemarkSetVC alloc] init];
        remarkVC.friendInfo = self.friendInfo;
        [self.navigationController pushViewController:remarkVC animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ECFriendInfo_Cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ECFriendInfo_Cell"];
        cell.backgroundColor = EC_Color_White;
        cell.detailTextLabel.textColor = EC_Color_Sec_Text;
        cell.textLabel.textColor = EC_Color_Main_Text;
        cell.textLabel.font = EC_Font_System(16);
        cell.detailTextLabel.font = EC_Font_System(16);
    }
    NSArray *tmpArr = @[@[NSLocalizedString(@"设置备注", nil)], @[NSLocalizedString(@"年龄", nil), NSLocalizedString(@"签名", nil)]];
    cell.textLabel.text = tmpArr[indexPath.section][indexPath.row];
    if(indexPath.section == 0){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if(indexPath.section == 1){
        if(indexPath.row == 0){
            if(self.friendInfo && self.friendInfo.birthDay && self.friendInfo.birthDay.length > 0)
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", [NSDate ageWithDateStr:self.friendInfo.birthDay]];
        }else if(indexPath.row == 1){
            if(self.friendInfo)
                cell.detailTextLabel.text = self.friendInfo.sign;
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return section == 0 ? 1 : 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

#pragma mark - UI创建
- (void)buildUI{
    self.sessionId = self.basePushData;
    self.title = NSLocalizedString(@"详细资料", nil);
    [super buildUI];
    self.title = NSLocalizedString(@"详细资料", nil);
    [self.view addSubview:self.tableView];
    EC_WS(self);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
}

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = EC_Color_VCbg;
        self.headerView = [[ECFriendInfoDetailHeader alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, 180)];
        self.headerView.friendInfo = self.friendInfo;
        _tableView.tableHeaderView = self.headerView;
        self.footerView = [[ECFriendInfoDetailFooter alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, 152)];
        self.footerView.friendInfo = self.friendInfo;
        _tableView.tableFooterView = self.footerView;
    }
    return _tableView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
