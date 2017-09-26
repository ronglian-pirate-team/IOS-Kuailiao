//
//  ECMeetingListVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/17.
//
//

#import "ECMeetingListVC.h"
#import "ECCreateMeetingVC.h"
#import "ECMeetingCell.h"
#import "ECMeetingVoiceVC.h"
#import "ECMeetingVideoVC.h"
#import "ECAddFriendVC.h"
#import "ECMeetingInterphoneVC.h"
#import "MJRefresh.h"
#import "ECMeetingListManager.h"

@interface ECMeetingListVC ()<UITableViewDelegate, UITableViewDataSource, ECBaseContollerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation ECMeetingListVC
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self fetchMeetingData];
}

- (void)viewDidLoad {
    self.baseDelegate = self;
    [super viewDidLoad];
    if(self.meetingType == ECMeetingType_Interphone){
        self.title = @"实时对讲";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveInterphoneMsg:) name:EC_KNOTIFICATION_ReceiveInterphoneMeetingMsg object:nil];
    }else{
        self.title = (self.meetingType == ECMeetingType_MultiVoice ? NSLocalizedString(@"语音会议", nil) : NSLocalizedString(@"视频会议", nil));
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveMeetingEnd:) name:EC_KNOTIFICATION_MeetingEnd object:nil];
    }
    self.dataSource = [NSMutableArray array];
}

- (void)fetchMeetingData{
    [[ECMeetingListManager sharedInstanced] fetchMeetingListDataWithType:self.meetingType completion:^(NSArray *list) {
        [self.tableView.mj_header endRefreshing];
        self.dataSource = list;
        [self.tableView reloadData];
        self.dataSource.count == 0?[self showNothingView:@"没有会议信息，点击右上角+号按钮主动创建"]:[self hiddenNothingView];
    }];
}

- (void)onReceiveInterphoneMsg:(NSNotification *)noti{
    ECInterphoneMeetingMsg* receiveMsgInfo = noti.object;
    if (receiveMsgInfo.type == Interphone_INVITE || receiveMsgInfo.type == Interphone_OVER) {
        [self fetchMeetingData];
    }
}

- (void)onReceiveMeetingEnd:(NSNotification *)noti{
    [self fetchMeetingData];
}

#pragma mark - ECBaseVCDelegate
- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString *__autoreleasing *)str {
    *str = @"messageNavbtnGo";
    return ^id {
        if([ECDeviceDelegateHelper sharedInstanced].isCallBusy){
            [ECCommonTool toast:@"只能加入一个会议"];
            return nil;
        }
        if(self.meetingType == ECMeetingType_Interphone){
            ECAddFriendVC *vc = [[ECAddFriendVC alloc] init];
            vc.isEditing = 3;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            ECCreateMeetingVC *createMeetingVC = [[ECCreateMeetingVC alloc] init];
            createMeetingVC.meetingType = self.meetingType;
            [self.navigationController pushViewController:createMeetingVC animated:YES];
        }
        return nil;
    };
}

#pragma mark - UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([ECDeviceDelegateHelper sharedInstanced].isCallBusy){
        [ECCommonTool toast:@"只能加入一个会议"];
        return;
    }
    
    if(self.meetingType != ECMeetingType_Interphone){
        [[ECMeetingListManager sharedInstanced] joinMeetingRoom:[self.dataSource objectAtIndex:self.dataSource.count - indexPath.row - 1]];
    }else if (self.meetingType == ECMeetingType_Interphone){
        ECInterphoneMeetingMsg *msg = self.dataSource[self.dataSource.count - indexPath.row - 1];
        [[ECMeetingListManager sharedInstanced] joinInterphoneRoom:msg];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ECMeetingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ECMeeting_Cell"];
    if(self.meetingType == ECMeetingType_Interphone){
        ECInterphoneMeetingMsg *msg = self.dataSource[self.dataSource.count - 1 - indexPath.row];
        cell.interphoneMeetingMsg = msg;
    }else{
        ECMultiVoiceMeetingRoom *roomInfo = self.dataSource[self.dataSource.count - 1 - indexPath.row];
        cell.meetingRoom = roomInfo;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

#pragma mark - UI创建
- (void)buildUI{
    [super buildUI];
    [self.view addSubview:self.tableView];
    EC_WS(self)
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
    MJRefreshGifHeader *refreshHeader = [MJRefreshGifHeader headerWithRefreshingBlock:^{
        [self fetchMeetingData];
    }];
    self.tableView.mj_header = refreshHeader;
    [super buildUI];
}

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 66;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[ECMeetingCell class] forCellReuseIdentifier:@"ECMeeting_Cell"];
    }
    return _tableView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
