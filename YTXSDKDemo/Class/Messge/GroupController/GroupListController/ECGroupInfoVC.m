//
//  ECGroupInfoVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/9/15.
//
//

#import "ECGroupInfoVC.h"
#import "ECGroupDeclaredCell.h"
#import "ECChatController.h"

@interface ECGroupInfoVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ECGroupInfoVC

- (void)joinAction:(UIButton *)sender{
    if([sender.titleLabel.text isEqualToString:NSLocalizedString(@"发消息", nil)]){
        ECChatController *chatVC = [[ECChatController alloc] init];
        ECSession *session = [[ECSession alloc] init];
        session.sessionId = self.group.groupId;
        session.sessionName = self.group.name;
        session.dateTime = 0;
        session.type = EC_Session_Type_Group;
        session.msgType = 0;
        session.text = @"";
        session.unreadCount = 0;
        session.sumCount = 0;
        session.isAt = NO;
        session.isTop = [[ECDBManager sharedInstanced].sessionMgr selectSession:self.group.groupId].isTop;
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp = [date timeIntervalSince1970]*1000;
        session.dateTime = (long long)tmp;
        session.memberCount = self.group.memberCount;
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_ClickSession object:session];
        [self.navigationController pushViewController:chatVC animated:YES];
        return;
    }
    EC_WS(self);
    [[ECDevice sharedInstance].messageManager joinGroup:self.group.groupId reason:@"" completion:^(ECError *error, NSString *groupId) {
        if(error.errorCode == ECErrorType_NoError) {
            ECSession *session = [[ECSession alloc] initWithSessionId:self.group.groupId];
            session.sessionName = self.group.name;
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_ClickSession object:session];
            UIViewController *vc = [[NSClassFromString(@"ECChatController") alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [[AppDelegate sharedInstanced].rootNav setViewControllers:[NSArray arrayWithObjects:[weakSelf.navigationController.viewControllers objectAtIndex:0],vc, nil] animated:YES];
            [ECCommonTool toast:@"申请已发送"];
        }else{
            [ECCommonTool toast:error.errorDescription];
        }
        EC_Demo_AppLog(@"%ld== %@", error.errorCode, error.errorDescription);
    }];
}

#pragma mark - UITableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ECBaseCellModel *model = self.baseDataArray[indexPath.row];
    if(indexPath.row == self.baseDataArray.count - 1){
        ECGroupDeclaredCell *cell = [[ECGroupDeclaredCell alloc] initDeclared:EC_ValidateNullStr(self.group.declared) ? @"" : self.group.declared reuseIdentifier:@"GroupAnnouncement_Cell"];
        cell.accessoryView = nil;
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EC_GroupInfo_Cell"];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EC_GroupInfo_Cell"];
        }
        cell.textLabel.text = model.text;
        cell.detailTextLabel.text = model.detailText;
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.baseDataArray.count;
}

#pragma mark - UI创建
- (void)buildUI{
    self.title = self.group.name;
    self.view.backgroundColor = EC_Color_VCbg;
    self.baseDataArray = [@[[ECBaseCellModel baseModelWithText:NSLocalizedString(@"群名称", nil) detailText:self.group.name img:nil modelType:nil],
                            [ECBaseCellModel baseModelWithText:NSLocalizedString(@"群主", nil) detailText:self.group.owner img:nil modelType:nil],
                            [ECBaseCellModel baseModelWithText:NSLocalizedString(@"群id", nil) detailText:self.group.groupId img:nil modelType:nil],
                            [ECBaseCellModel baseModelWithText:NSLocalizedString(@"群公告", nil) detailText:self.group.declared img:nil modelType:nil],
                            ] mutableCopy];
    [self.view addSubview:self.tableView];
    EC_WS(self)
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
    ECGroup *g = [[ECDBManager sharedInstanced].groupInfoMgr selectGroupOfGroupId:self.group.groupId];
    UIButton *joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    joinBtn.backgroundColor = EC_Color_Alert_Red;
    [joinBtn setTitle:[g.groupId isEqualToString:self.group.groupId] ? NSLocalizedString(@"发消息", nil) : NSLocalizedString(@"申请加入", nil) forState:UIControlStateNormal];
    joinBtn.frame = CGRectMake(20, EC_kScreenH - 150, EC_kScreenW - 40, 44);
    [joinBtn addTarget:self action:@selector(joinAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:joinBtn];
    [super buildUI];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.sectionFooterHeight = 30;
        _tableView.estimatedRowHeight = 44.0;
        _tableView.scrollEnabled = NO;
        _tableView.rowHeight = UITableViewAutomaticDimension;
    }
    return _tableView;
}

@end
