//
//  ECFriendInfoDetailMoreVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/23.
//
//

#import "ECFriendInfoDetailMoreVC.h"
#import "ECRemarkSetVC.h"
#import "ECFriendManager.h"

@interface ECFriendInfoDetailMoreVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ECFriendInfoDetailMoreVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendInfo) name:EC_DEMO_KNotice_UpdateFriendRemark object:nil];
}

- (void)updateFriendInfo{
    self.friendInfo = [[ECFriendManager sharedInstanced] fetchFriendFromDB:self.friendInfo.useracc];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.detailTextLabel.text = self.friendInfo.remarkName;
}

- (void)deleteFriendAction{
    [ECAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"是否确认删除好友", nil) cancelTitle:NSLocalizedString(@"取消", nil) DestructiveTitle:@[NSLocalizedString(@"删除好友", nil)] DefautTitleArray:nil showInView:self handler:^(UIAlertAction *action) {
        if ([action.title isEqualToString:NSLocalizedString(@"删除好友", nil)]) {
            ECRequestFriendDelete *fr = [[ECRequestFriendDelete alloc] init];
            fr.useracc = [ECSDK_Key stringByAppendingFormat:@"#%@",[ECAppInfo sharedInstanced].persionInfo.userName];
            fr.friendUseracc = [ECSDK_Key stringByAppendingFormat:@"#%@",self.friendInfo.useracc];
            fr.allDel = @"1";
            EC_ShowHUD(@"")
            [[ECAFNHttpTool sharedInstanced] deleteFriend:fr completion:^(NSString *errCode, id responseObject) {
                EC_HideHUD
                if(errCode.integerValue == 0){
                    [ECCommonTool toast:NSLocalizedString(@"删除成功", nil)];
                    [[ECDBManager sharedInstanced].friendMgr deleteFriend:self.friendInfo.useracc];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }else{
                    EC_Demo_AppLog(@"%@",responseObject);
                    [ECCommonTool toast:@"删除好友失败"];
                }
            }];
        }
    }];
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
    cell.textLabel.text = NSLocalizedString(@"设置备注", nil);
    cell.detailTextLabel.text = self.friendInfo.remarkName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

#pragma mark - UI 创建
- (void)buildUI{
    self.title = NSLocalizedString(@"资料设置", nil);
    [self.view addSubview:self.tableView];
    EC_WS(self);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    
    if (![self.friendInfo.useracc isEqualToString:[ECAppInfo sharedInstanced].userName]) {
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setTitle:NSLocalizedString(@"删除好友", nil) forState:UIControlStateNormal];
        deleteBtn.titleLabel.font = EC_Font_System(17);
        [deleteBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteFriendAction) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.ec_radius = 4;
        deleteBtn.backgroundColor = [UIColor colorWithHex:0xf88dbb];
        [self.view addSubview:deleteBtn];
        [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.view).offset(21);
            make.right.equalTo(weakSelf.view).offset(-21);
            make.height.offset(47);
            make.top.equalTo(weakSelf.view).offset(186);
        }];
    }
}

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = EC_Color_VCbg;
        _tableView.tableFooterView = [UIView new];
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
