//
//  ECDeleteMeetingMemberVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/17.
//
//

#import "ECDeleteMeetingMemberVC.h"
#import "ECUserCell.h"

@interface ECDeleteMeetingMemberVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, copy) NSString *meetingNum;
@property (nonatomic, assign) ECMeetingType meetingType;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ECDeleteMeetingMemberVC

#pragma mark - UITableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ECUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ECMeetingMemeber_Cell"];
    if (cell==nil) {
        cell = [[ECUserCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ECMeetingMemeber_Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    ECMultiVoiceMeetingMember *member = self.baseDataArray[indexPath.row];
    cell.voiceMeetingMember = member;
    cell.contactType = ECUserOperationType_Delete;
    cell.completionOperation = ^(ECUserCell *c){
        NSIndexPath *index = [tableView indexPathForCell:c];
        EC_ShowHUD(@"")
        ECVoIPAccount *account;
        if([c.voiceMeetingMember isKindOfClass:[ECMultiVideoMeetingMember class]]){
            account = ((ECMultiVideoMeetingMember *)c.voiceMeetingMember).voipAccount;
        }else{
            account = c.voiceMeetingMember.account;
        }
        [[ECDevice sharedInstance].meetingManager removeMemberFromMultMeetingByMeetingType:self.meetingType andMeetingNumber:self.meetingNum andMember:account completion:^(ECError *error, ECVoIPAccount *memberVoip) {
            if(error.errorCode == ECErrorType_NoError){
                [ECCommonTool toast:@"踢出成功"];
                [self.baseDataArray removeObjectAtIndex:index.row];
                [self.tableView reloadData];
            }else{
                [ECCommonTool toast:[NSString stringWithFormat:@"%@", error.errorDescription]];
            }
            EC_HideHUD
        }];
    };
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.baseDataArray.count;
}

#pragma makr - UI创建
- (void)buildUI {
    self.title = NSLocalizedString(@"删除成员", nil);
    [self.view addSubview:self.tableView];
    EC_WS(self)
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
    [super buildUI];
    if ([self.basePushData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)self.basePushData;
        self.meetingType = (ECMeetingType)[dict[@"meetingType"] integerValue];
        self.meetingNum = dict[@"meetingNum"];
        self.baseDataArray = [NSMutableArray arrayWithArray:dict[@"baseDataArray"]];
    }
}
#pragma mark - 懒加载
- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 70;
        _tableView.backgroundView.backgroundColor = EC_Color_VCbg;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(self.baseOneObjectCompletion)
        self.baseOneObjectCompletion(self);
}

@end
