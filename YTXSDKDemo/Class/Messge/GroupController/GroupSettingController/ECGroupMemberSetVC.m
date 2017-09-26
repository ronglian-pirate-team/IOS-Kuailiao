//
//  ECForbidListVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/16.
//
//

#import "ECGroupMemberSetVC.h"
#import "ECUserCell.h"
#import "ECGroupModeCell.h"
#import "ECDemoGroupManage+Forbid.h"
#import "ECDemoGroupManage+Admin.h"

@interface ECGroupMemberSetVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, assign) ECMemberRole role;
@property (nonatomic, strong) NSArray *members;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, assign) ECGroupMemberSet memberSetType;
@end

@implementation ECGroupMemberSetVC

- (void)fetchDataSource{
    [self.dataSource removeAllObjects];
    if(self.memberSetType == ECGroupMemberSet_Forbid) {
        [self.dataSource addObjectsFromArray:[ECDemoGroupManage sharedInstanced].forbidMembers];
    }else if (self.memberSetType == ECGroupMemberSet_AdminSet){
        [self.dataSource addObjectsFromArray:[ECDemoGroupManage sharedInstanced].adminMembers];
        self.headerLabel.text = [NSString stringWithFormat:@"管理员(%ld/%ld)", (unsigned long)self.dataSource.count, [ECDemoGroupManage sharedInstanced].members.count];
    }
    [self.tableView reloadData];
}

- (void)showMemberSetResult:(BOOL)isAddAdmin {
    UIView *resultView = [[UIView alloc] initWithFrame:CGRectMake(0, -64, EC_kScreenW, 64)];
    resultView.backgroundColor = EC_Color_App_Main;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, EC_kScreenW, 44)];
    label.textColor = EC_Color_White;
    label.font = EC_Font_System(14);
    label.text = (isAddAdmin ? NSLocalizedString(@"添加成功", nil) : NSLocalizedString(@"取消成功", nil));
    [resultView addSubview:label];
    [[AppDelegate sharedInstanced].window addSubview:resultView];
    [UIView animateWithDuration:0.2 animations:^{
        resultView.frame = CGRectMake(0, 0, EC_kScreenW, 64);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            resultView.frame = CGRectMake(0, -64, EC_kScreenW, 64);
        } completion:^(BOOL finished) {
            [resultView removeFromSuperview];
        }];
    }];
}

#pragma mark - TableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == self.dataSource.count){
        if(self.memberSetType == ECGroupMemberSet_AdminSet){
            [[AppDelegate sharedInstanced].rootNav ec_pushViewController:[[NSClassFromString(@"ECGroupMemberListSetVC") alloc] init] animated:YES data:@(1)];
        } else {
            UIViewController *banVC = [[NSClassFromString(@"ECGroupMemberOperationVC") alloc] init];
            [self.navigationController ec_pushViewController:banVC animated:YES data:@(2)];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == self.dataSource.count){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ECAddForibdMember_Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text=self.memberSetType==ECGroupMemberSet_Forbid?NSLocalizedString(@"添加禁言成员", nil):NSLocalizedString(@"添加管理员", nil);
        cell.textLabel.textColor = EC_Color_Main_Text;
        cell.textLabel.font = EC_Font_SystemBold(16);
        cell.imageView.image = EC_Image_Named(@"addressbookIconNewfriend");
        return cell;
    }
    ECUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ForbidMember_Cell"];
    if (cell==nil) {
        cell = [[ECUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ForbidMember_Cell"];
        cell.contactType = ECUserOperationType_None;
    }
    ECGroupMember *memebr = self.dataSource[indexPath.row];
    cell.groupId = self.groupId;
    cell.member = memebr;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row == self.dataSource.count ? 44 : 70;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row == self.dataSource.count ?NO : YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    ECGroupMember *memebr = self.dataSource[indexPath.row];
    if (self.memberSetType == ECGroupMemberSet_AdminSet) {
        [[ECDevice sharedInstance].messageManager setGroupMemberRole:self.groupId member:memebr.memberId role:ECMemberRole_Member completion:^(ECError *error, NSString *groupId, NSString *memberId) {
            if(error.errorCode == ECErrorType_NoError){
                memebr.role = ECMemberRole_Member;
                [[ECDBManager sharedInstanced].groupMemberMgr updateGroupMember:memberId memberRole:ECMemberRole_Member inGroup:self.groupId];
                [[ECDemoGroupManage sharedInstanced].adminMembers removeObject:memebr];
                [self.dataSource removeObjectAtIndex:indexPath.row];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self showMemberSetResult:NO];
            }
        }];
    } else if (self.memberSetType == ECGroupMemberSet_Forbid) {
        EC_ShowHUD(@"正在取消禁言...");
        [[ECDemoGroupManage sharedInstanced] unForbidMembers:@[memebr] completion:^{
            EC_HideHUD;
            [self fetchDataSource];
        }];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.memberSetType == ECGroupMemberSet_Forbid?NSLocalizedString(@"取消禁言", nil):NSLocalizedString(@"取消管理员", nil);
}

#pragma mark - UI创建
- (void)buildUI{
    self.groupId = [ECDemoGroupManage sharedInstanced].group.groupId;
    self.role = [ECDemoGroupManage sharedInstanced].group.selfRole;
    self.memberSetType = (ECGroupMemberSet)[self.basePushData integerValue];
    self.title = self.memberSetType == ECGroupMemberSet_Forbid ?  NSLocalizedString(@"设置群内禁言", nil) : NSLocalizedString(@"设置管理员", nil);
    [self.view addSubview:self.tableView];
    if(self.memberSetType == ECGroupMemberSet_Forbid)
        self.tableView.tableFooterView = [self tableFooterView];
    else
        self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = [self tableHeaderView];
    EC_WS(self)
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
    self.dataSource = [NSMutableArray array];
    [super buildUI];
}

- (void)ec_addNotify {
    [self fetchDataSource];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchDataSource) name:EC_DEMO_KNotice_ReloadGroupForbidMember object:nil];
}
#pragma mark - 懒加载
- (UIView *)tableHeaderView{
    UIView *headerV = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, 40)];
    self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, EC_kScreenW, 40)];
    self.headerLabel.text = self.memberSetType == ECGroupMemberSet_Forbid ? NSLocalizedString(@"被禁言的成员", nil) : @"管理员";
    self.headerLabel.textColor = EC_Color_Sec_Text;
    self.headerLabel.font = EC_Font_System(13);
    [headerV addSubview:self.headerLabel];
    return headerV;
}

- (UIView *)tableFooterView{
    UIView *footerV = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, 30)];
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, EC_kScreenW, 30)];
    footerLabel.text = NSLocalizedString(@"开启后，只允许群主和指定成员发言", nil);
    footerLabel.textColor = EC_Color_Sec_Text;
    footerLabel.font = EC_Font_System(13);
    [footerV addSubview:footerLabel];
    return footerV;
}

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = EC_Color_VCbg;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ECGroupModeCell class] forCellReuseIdentifier:@"ECForbidAllMember_Cell"];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ECAddForibdMember_Cell"];
    }
    return _tableView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
