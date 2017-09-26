//
//  ECCreateMeetingVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/16.
//
//

#import "ECCreateMeetingVC.h"
#import "ECGroupNameCell.h"
#import "ECGroupModeCell.h"
#import "ECMeetingVoiceSetCell.h"
#import "ECVoiceMeetingView.h"
#import "ECMeetingVoiceVC.h"
#import "ECMeetingVideoVC.h"

@interface ECCreateMeetingVC ()<UITableViewDelegate, UITableViewDataSource, ECBaseContollerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL isAutoDelete;//创建者退出是否自动删除
@property (nonatomic, assign) BOOL isAutoDismiss;//创建者退出是否自动解散
@property (nonatomic, assign) BOOL isAutoJoin;//是否自动加入
@property (nonatomic, assign) NSInteger voiceMode;

@end

@implementation ECCreateMeetingVC

- (void)viewDidLoad {
    self.baseDelegate = self;
    [super viewDidLoad];
    self.title = NSLocalizedString(@"创建房间", nil);
    self.isAutoDelete = YES;
    self.isAutoDismiss = YES;
    self.isAutoJoin = YES;
    self.voiceMode = 1;
}

- (BOOL)isAutoDelete{
    ECGroupModeCell *cell = nil;
    if(self.meetingType == 1){
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    }else if (self.meetingType == 2){
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    }
    return cell.isOpen;
}

- (BOOL)isAutoDismiss{
    ECGroupModeCell *cell = nil;
    if(self.meetingType == 1){
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:3]];
    }else if (self.meetingType == 2){
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]];
    }
    return cell.isOpen;
}

- (BOOL)isAutoJoin{
    ECGroupModeCell *cell = nil;
    if(self.meetingType == 1){
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:3]];
    }else if (self.meetingType == 2){
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]];
    }
    return cell.isOpen;
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        ECGroupNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ECCreateMeeting_Cell"];
        cell.textLabel.text = NSLocalizedString(@"房间名称", nil);
        return cell;
    }
    if(indexPath.section == 1 && self.meetingType == 1){
        ECGroupNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ECCreateMeeting_Cell"];
        cell.textLabel.text = NSLocalizedString(@"房间密码", nil);
        cell.placeholder = NSLocalizedString(@"请输入1~8位密码(选填)", nil);
        cell.secureTextEntry = YES;
        cell.maxLength = 8;
        return cell;
    }
    if((indexPath.section == 1 && self.meetingType == 2) || (indexPath.section == 2 && self.meetingType == 1)){
        ECMeetingVoiceSetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ECMeetingSettingVoice_Cell"];
        cell.selectVoiceModel = ^(NSInteger model){
            self.voiceMode = model;
        };
        return cell;
    }
    if((indexPath.section == 3 && self.meetingType == 1) || (indexPath.section == 2 || self.meetingType == 2)){
        ECGroupModeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ECMeetingSettingMode_Cell"];
        NSString *str = @"";
        if(indexPath.row == 0){
            str = NSLocalizedString(@"自动删除房间",nil);
        }else if (indexPath.row == 1){
            str = NSLocalizedString(@"创建人退出时自动解散",nil);
        }else if (indexPath.row == 2){
            str = NSLocalizedString(@"创建后自动加入会议",nil);
        }
        [cell ec_configMode:[ECBaseCellModel baseModelWithText:str detailText:@"" img:nil modelType:ec_groupsetvc_cell_switch]];
        return cell;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ((self.meetingType == 1 && section == 3) || (self.meetingType == 2 && section == 2)) ? 3 : 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.meetingType == 1 ? 4 : 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

#pragma mark - ECBase delegate
- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString *__autoreleasing *)str {
    *str = NSLocalizedString(@"下一步", nil);
    return ^id {
        [self.view endEditing:YES];
        ECGroupNameCell *nameCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if(!nameCell.groupName || nameCell.groupName.length == 0){
            [ECCommonTool toast:NSLocalizedString(@"请输入房间名称", nil)];
            return nil;
        }
        NSString *pwd = @"";
        if(self.meetingType == 1){
            ECGroupNameCell *pwdCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            pwd = pwdCell.groupName;
        }
        ECCreateMeetingParams *params = [[ECCreateMeetingParams alloc] init];
        params.meetingType = self.meetingType;
        params.meetingName = nameCell.groupName;
        params.meetingPwd = pwd;
        params.square = 30;
        params.autoClose = self.isAutoDismiss;
        params.autoDelete = self.isAutoDelete;
        params.voiceMod = self.voiceMode;
        params.autoJoin = self.isAutoJoin;
        if(self.isAutoJoin){
            if(self.meetingType == ECMeetingType_MultiVideo){
                ECMeetingVideoVC *video = [[ECMeetingVideoVC alloc] init];
                video.meetingParams = params;
//                [self.navigationController pushViewController:voiceVC animated:YES];
                [video showVideoMeetingView];
            }else if(self.meetingType == ECMeetingType_MultiVoice){
                ECMeetingVoiceVC *voiceVC = [[ECMeetingVoiceVC alloc] init];
                voiceVC.meetingParams = params;
//                [self.navigationController pushViewController:voiceVC animated:YES];
                [voiceVC showVoiceMeetingView];
            }
        }else{
            EC_ShowHUD(@"");
            [[ECDevice sharedInstance].meetingManager createMultMeetingByType:params completion:^(ECError *error, NSString *meetingNumber) {
                EC_HideHUD
                if (error.errorCode == ECErrorType_NoError) {
                    [ECCommonTool toast:NSLocalizedString(@"会议创建成功", nil)];
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [ECCommonTool toast:[NSString stringWithFormat:@"%@, error code %ld, desc %@", NSLocalizedString(@"会议创建失败", nil), error.errorCode, error.errorDescription]];
                }
            }];
        }
        return nil;
    };
}

#pragma mark - UI创建
- (void)buildUI{
    [super buildUI];
    [self.view addSubview:self.tableView];
    EC_WS(self)
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
    [super buildUI];
}

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = EC_Color_VCbg;
        _tableView.tableFooterView = [UIView new];
        _tableView.sectionFooterHeight = 30;
        _tableView.estimatedRowHeight = 44.0;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"ECCreateMetting_Section"];
        [_tableView registerClass:[ECGroupNameCell class] forCellReuseIdentifier:@"ECCreateMeeting_Cell"];
        [_tableView registerClass:[ECGroupModeCell class] forCellReuseIdentifier:@"ECMeetingSettingMode_Cell"];
        [_tableView registerClass:[ECMeetingVoiceSetCell class] forCellReuseIdentifier:@"ECMeetingSettingVoice_Cell"];
    }
    return _tableView;
}

@end
