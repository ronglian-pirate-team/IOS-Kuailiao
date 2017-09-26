//
//  ECGroupCardVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/25.
//
//

#import "ECGroupCardVC.h"
#import "ECGroupNameCell.h"
#import "ECDemoGroupManage.h"

@interface ECGroupCardVC ()<ECBaseContollerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) ECGroup *group;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) ECGroupMember *groupMember;
@end

@implementation ECGroupCardVC

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if(indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"ECGroupNormal_Cell"];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ECGroupNormal_Cell"];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"ECGroupInput_Cell"];
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    switch (indexPath.row) {
        case 0:
            cell.detailTextLabel.text = self.group.groupId;
            break;
        case 1:
            cell.detailTextLabel.text = [ECDevicePersonInfo sharedInstanced].userName;
            break;
        case 2:
            cell.detailTextLabel.text = self.groupMember.sex == ECSexType_Male ? @"男" : @"女";
            break;
        case 3:
            ((ECGroupNameCell *)cell).groupName = self.groupMember.display;
            break;
        case 4:
            ((ECGroupNameCell *)cell).groupName = self.groupMember.tel;
            break;
        case 5:
            ((ECGroupNameCell *)cell).groupName = self.groupMember.mail;
            break;
        case 6:
            ((ECGroupNameCell *)cell).groupName = self.groupMember.remark;
            break;
        default:
            break;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

#pragma mark - BaseController delegate
- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString *__autoreleasing *)str{
    *str = @"保存";
    return ^id{
        [self.view endEditing:YES];
        ECGroupNameCell *nicknameCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        if(!nicknameCell.groupName || nicknameCell.groupName.length == 0){
            [ECCommonTool toast:NSLocalizedString(@"请输入昵称", nil)];
            return nil;
        }
        ECGroupNameCell *telCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
        ECGroupNameCell *mailCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
        ECGroupNameCell *remarkCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
        EC_ShowHUD(@"")
        self.groupMember.display = nicknameCell.groupName;
        self.groupMember.tel = telCell.groupName;
        self.groupMember.mail = mailCell.groupName;
        self.groupMember.remark = remarkCell.groupName;
        [[ECDemoGroupManage sharedInstanced] modifyMemberCard:self.groupMember];
        return nil;
    };
}
#pragma mark - UI创建
- (void)buildUI{
    self.baseDelegate = self;
    self.group = [ECDemoGroupManage sharedInstanced].group;
    self.title = self.basePushData;
    [self.view addSubview:self.tableView];
    EC_WS(self);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
    self.dataArray = @[[NSString stringWithFormat:@"%@id",[self.title substringToIndex:self.title.length-2]], NSLocalizedString(@"个人id", nil), NSLocalizedString(@"性别", nil), NSLocalizedString(@"昵称", nil), NSLocalizedString(@"电话", nil), NSLocalizedString(@"E-mail", nil), NSLocalizedString(@"可扩展字段", nil)];

    [super buildUI];
}

- (void)ec_addNotify {
    EC_WS(self)
    [[ECDevice sharedInstance].messageManager queryMemberCard:[ECDevicePersonInfo sharedInstanced].userName belong:self.group.groupId completion:^(ECError *error, ECGroupMember *member) {
        if (error.errorCode == ECErrorType_NoError) {
            weakSelf.groupMember = member;
            [weakSelf.tableView reloadData];
        }
    }];
}
#pragma mark - 懒加载
- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[ECGroupNameCell class] forCellReuseIdentifier:@"ECGroupInput_Cell"];
    }
    return _tableView;
}

@end
