//
//  ECVoiceMeetingVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/17.
//
//

#import "ECVoiceMeetingView.h"
#import "ECCallOperationView.h"
#import "ECVoiceMeetingMemberCell.h"

@interface ECVoiceMeetingView ()<UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

@property (nonatomic, strong) ECCallOperationView *microPhoneView;//麦克风打开/关闭
@property (nonatomic, strong) ECCallOperationView *exitView;//退出
@property (nonatomic, strong) ECCallOperationView *speakerView;//扬声器打开/关闭
@property (nonatomic, strong) UIButton *packUpBtn;//收起
@property (nonatomic, strong) UIButton *dismissBtn;//解散
@property (nonatomic, strong) UILabel *nameLabel;//当前操作者名字
@property (nonatomic, strong) UILabel *hostLabel;//会议创建者
@property (nonatomic, strong) UILabel *meetingNameLabel;//会议名称

@property (nonatomic, strong) UICollectionView *collectionView;//会议成员展示
@property (nonatomic, strong) UITableView *tableView;//会议成员加入/退出消息展示

@property (nonatomic, strong) NSMutableArray *tableSource;//会议成员加入/退出消息
@property (nonatomic, strong) NSMutableArray *collectionSource;//会议成员

@property (nonatomic, strong) UILabel *alertLabel;
@property (nonatomic, strong) UILabel *timeLabel;//会议时间显示

@property (nonatomic, strong) NSTimer *timer;//开始会议定时器
@property (nonatomic, assign) NSInteger second;//会议时间

@property (nonatomic, assign) BOOL isCreater;//是否是会议创建者

@end

@implementation ECVoiceMeetingView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.alpha = 0;
        self.tableSource = [NSMutableArray array];
        self.collectionSource = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveChatroomMsg:) name:EC_KNOTIFICATION_ReceiveMultiVoiceMeetingMsg object:nil];
        [self buildUI];
    }
    return self;
}

- (void)show{
    [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:YES];
    [[ECDevice sharedInstance].VoIPManager setMute:NO];
    [self createMeetingRoom];
    [[AppDelegate sharedInstanced].window addSubview:self];
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
    }];
}

- (NSTimer *)timer{
    if(!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startTimer) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}

- (void)startTimer{
    self.second++;
    NSInteger sec = self.second % 60;
    NSInteger min = self.second / 60;
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", min, sec];
}

- (void)quertMeetingMember{
    [[ECDevice sharedInstance].meetingManager queryMeetingMembersByMeetingType:ECMeetingType_MultiVoice andMeetingNumber:self.meetingRoomNum completion:^(ECError *error, NSArray *members) {
        [self.collectionSource addObjectsFromArray:members];
        [self.collectionView reloadData];
    }];
}

- (void)createMeetingRoom{
    if(!self.meetingParams){
        [self dismissBtn];
        return;
    }
    __weak typeof(self)weakSelf = self;
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:weakSelf animated:YES];
    hud.label.text = @"";
    hud.removeFromSuperViewOnHide = YES;
    [[ECDevice sharedInstance].meetingManager createMultMeetingByType:self.meetingParams completion:^(ECError *error, NSString *meetingNumber) {
        [MBProgressHUD hideHUDForView:weakSelf animated:YES];
        self.meetingRoomNum = meetingNumber;
        if(error.errorCode == ECErrorType_NoError){
            self.isCreater = YES;
            EC_Demo_AppLog(@"语音会议创建成功");
            self.second = 0;
            self.timer.fireDate = [NSDate distantPast];
            [self.tableSource addObject:NSLocalizedString(@"发起会议", nil)];
            [self.tableView reloadData];
            [self quertMeetingMember];
        }else{
            EC_Demo_AppLog(@"语音会议创建失败, %@", error.errorDescription);
        }
    }];

}

- (void)joinMeetingRoom:(NSString *)meetingNum{
    NSString *pwd = @"";
    __weak typeof(self)weakSelf = self;
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:weakSelf animated:YES];
    hud.label.text = @"";
    hud.removeFromSuperViewOnHide = YES;
    [[ECDevice sharedInstance].meetingManager joinMeeting:meetingNum ByMeetingType:ECMeetingType_MultiVoice andMeetingPwd:pwd completion:^(ECError *error, NSString *meetingNumber) {
        [MBProgressHUD hideHUDForView:weakSelf animated:YES];
        self.meetingRoomNum = meetingNumber;
        if(error.errorCode == ECErrorType_NoError){
            self.second = 0;
            self.timer.fireDate = [NSDate distantPast];
            [self quertMeetingMember];
        }else{
            EC_Demo_AppLog(@"语音会议加入失败, %@", error.errorDescription);
        }
    }];
}

- (void)joinOrCreateError:(ECError *)error withMeetingNum:(NSString *)meetingNumber{
    if (error.errorCode == ECErrorType_NotExist) {
        error.errorDescription = [NSString stringWithFormat: @"房间%@已解散或者不存在！",meetingNumber];
    } else if (error.errorCode == ECErrorType_PasswordInvalid) {
        error.errorDescription = @"密码验证失败！";
    }
    NSString* detail = error.errorDescription.length>0?[NSString stringWithFormat:@"\r描述:%@",error.errorDescription]:@"";
    UIAlertView *alertview = [[UIAlertView alloc]  initWithTitle:@"加入群聊失败" message:[NSString stringWithFormat:@"错误码:%d%@",(int)error.errorCode,detail]  delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertview show];
}

- (void)onReceiveChatroomMsg:(NSNotification *)noti{
    ECMultiVoiceMeetingMsg* receiveMsgInfo = noti.object;
    if (![receiveMsgInfo.roomNo isEqualToString: self.meetingRoomNum]) {
        return;
    }
    switch (receiveMsgInfo.type) {
        case MultiVoice_JOIN:
            for (ECVoIPAccount *who in receiveMsgInfo.joinArr) {
                [self.tableSource addObject:[NSString stringWithFormat:@"%@ %@%@", [NSDate ec_stringFromCurrentDateWithFormate:@"mm:ss"], who.account, NSLocalizedString(@"进入了会议", nil)]];
                ECMultiVoiceMeetingMember *member = [[ECMultiVoiceMeetingMember alloc] init];
                member.account = who;
                member.role = 0;
                [self.collectionSource addObject:member];
            }
            [self.collectionView reloadData];
            [self.tableView reloadData];
            break;
        case MultiVoice_EXIT:
            for (ECVoIPAccount *who in receiveMsgInfo.exitArr) {
                [self.tableSource addObject:[NSString stringWithFormat:@"%@ %@%@", [NSDate ec_stringFromCurrentDateWithFormate:@"mm:ss"], who.account, NSLocalizedString(@"退出了会议", nil)]];
                for (ECMultiVoiceMeetingMember *m in self.collectionSource) {
                    if ([who.account isEqualToString:m.account.account] && who.isVoIP == m.account.isVoIP) {
                        [self.collectionSource removeObject:m];
                        break;
                    }
                }
            }
            [self.collectionView reloadData];
            [self.tableView reloadData];
        default:
            break;
    }
}

#pragma mark - 
- (void)packupAction{
    [self removeFromSuperview];
}

- (void)disMissAction{
    [[ECDevice sharedInstance].meetingManager exitMeeting];
    if(_timer){
        [_timer invalidate];
        _timer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)microAction{
    BOOL mute = [[ECDevice sharedInstance].VoIPManager getMuteStatus];
    [[ECDevice sharedInstance].VoIPManager setMute:!mute];
}

- (void)exitAction{
    [self disMissAction];
}

- (void)speakerAction{
    BOOL isLoud = [[ECDevice sharedInstance].VoIPManager getLoudsSpeakerStatus];
    [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:!isLoud];
}

#pragma mark - UITable View Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ECVoiceMeeting_Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = EC_Color_Sec_Text;
    cell.textLabel.font = EC_Font_System(13);
    cell.textLabel.text = self.tableSource[indexPath.row];
    cell.contentView.backgroundColor = EC_Color_Tabbar;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableSource.count;
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0){
        
    }else if (buttonIndex == 1){
    }
}

#pragma mark - UICollection View delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"邀请人员", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Voip邀请", nil), NSLocalizedString(@"手机号邀请", nil), nil];
        [actionSheet showInView:self];
    }else if (indexPath.row == 1){
        
    }else if (indexPath.row == 2){
        for (ECMultiVoiceMeetingMember *m in self.collectionSource) {
            [[ECDevice sharedInstance].meetingManager setMember:m.account speakListen:1 ofMeetingType:ECMeetingType_MultiVoice andMeetingNumber:self.meetingRoomNum completion:^(ECError *error, NSString *meetingNumber) {
                if(error.errorCode == ECErrorType_NoError){
                    EC_Demo_AppLog(@"设置静音成功");
                }else{
                    EC_Demo_AppLog(@"设置静音失败");
                }
            }];
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ECVoiceMeetingMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ECVoiceMeetingMember_Cell" forIndexPath:indexPath];
    NSArray *operationArr = @[@{@"title":NSLocalizedString(@"邀请成员", nil), @"image":@""}, @{@"title":NSLocalizedString(@"删除成员", nil), @"image":@""}, @{@"title":NSLocalizedString(@"全员静音", nil), @"image":@""}];
    if(indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2){
        cell.operationInfo = operationArr[indexPath.row];
    }else{
        ECMultiVoiceMeetingMember *member = self.collectionSource[indexPath.row - 3];
        cell.voiceMember = member;
    }
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.collectionSource.count + 3;
}

#pragma mark - UI创建
- (void)buildUI{
    self.backgroundColor = EC_Color_Tabbar;
    [self addSubview:self.packUpBtn];
    [self addSubview:self.dismissBtn];
    [self addSubview:self.nameLabel];
    [self addSubview:self.hostLabel];
    [self addSubview:self.meetingNameLabel];
    [self addSubview:self.microPhoneView];
    [self addSubview:self.exitView];
    [self addSubview:self.speakerView];
    [self addSubview:self.collectionView];
    [self addSubview:self.tableView];
    [self addSubview:self.alertLabel];
    [self addSubview:self.timeLabel];
    EC_WS(self)
    [self.packUpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(22);
        make.top.equalTo(weakSelf).offset(32);
    }];
    [self.dismissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(28);
        make.right.equalTo(weakSelf).offset(-24);
        make.height.offset(28);
        make.width.offset(100);
    }];
    self.dismissBtn.ec_radius = 14;
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(15);
        make.top.equalTo(weakSelf.packUpBtn.mas_bottom).offset(30);
        make.width.height.offset(66);
    }];
    [self.hostLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.nameLabel.mas_right).offset(10);
        make.top.equalTo(weakSelf.nameLabel.mas_top);
        make.right.equalTo(weakSelf);
        make.height.offset(33);
    }];
    [self.meetingNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.hostLabel.mas_left);
        make.top.equalTo(weakSelf.hostLabel.mas_bottom);
        make.right.equalTo(weakSelf);
        make.height.offset(33);
    }];
    NSArray *operationViews = @[self.microPhoneView, self.exitView, self.speakerView];
    [operationViews mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:46 leadSpacing:56 tailSpacing:56];
    [operationViews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf).offset(-30);
        make.height.offset(85);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.top.equalTo(weakSelf.nameLabel.mas_bottom).offset(10);
        make.bottom.equalTo(weakSelf.collectionView.mas_top).offset(-10);
    }];
    [self.alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.nameLabel.mas_bottom).offset(10);
        make.right.equalTo(weakSelf).offset(-30);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.alertLabel.mas_bottom).offset(5);
        make.right.equalTo(weakSelf).offset(-28);
    }];
}

- (UIButton *)packUpBtn{
    if(!_packUpBtn){
        _packUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_packUpBtn setImage:EC_Image_Named(@"yuyinliaotianIconSuoxiao") forState:UIControlStateNormal];
        [_packUpBtn addTarget:self action:@selector(packupAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _packUpBtn;
}

- (UIButton *)dismissBtn{
    if(!_dismissBtn){
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dismissBtn addTarget:self action:@selector(disMissAction) forControlEvents:UIControlEventTouchUpInside];
        [_dismissBtn setTitle:NSLocalizedString(@"解散房间", nil) forState:UIControlStateNormal];
        [_dismissBtn setTitleColor:EC_Color_White forState:UIControlStateNormal];
        _dismissBtn.backgroundColor = [UIColor colorWithHex:0xf88dbb];
        _dismissBtn.titleLabel.font = EC_Font_SystemBold(16);
    }
    return _dismissBtn;
}

- (UILabel *)nameLabel{
    if(!_nameLabel){
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor colorWithHex:0x5981f5];
        _nameLabel.textColor = EC_Color_White;
        _nameLabel.font = EC_Font_System(15);
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.ec_radius = 33;
        _nameLabel.text = @"名字";
    }
    return _nameLabel;
}

- (UILabel *)hostLabel{
    if(!_hostLabel){
        _hostLabel = [[UILabel alloc] init];
        _hostLabel.textColor = EC_Color_Main_Text;
        _hostLabel.font = EC_Font_System(17);
        _hostLabel.text = @"主持人：我";
    }
    return _hostLabel;
}

- (UILabel *)meetingNameLabel{
    if(!_meetingNameLabel){
        _meetingNameLabel = [[UILabel alloc] init];
        _meetingNameLabel.textColor = EC_Color_Sec_Text;
        _meetingNameLabel.font = EC_Font_System(14);
        _meetingNameLabel.text = @"房间名称：语音会议";
    }
    return _meetingNameLabel;
}

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = EC_Color_Tabbar;
        _tableView.rowHeight = 30;
        _tableView.backgroundColor = EC_Color_Tabbar;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ECVoiceMeeting_Cell"];
    }
    return _tableView;
}

- (UILabel *)alertLabel{
    if(!_alertLabel){
        _alertLabel = [[UILabel alloc] init];
        _alertLabel.textColor = EC_Color_Sec_Text;
        _alertLabel.font = EC_Font_System(12);
        _alertLabel.text = NSLocalizedString(@"会议计时", nil);
    }
    return _alertLabel;
}

- (UILabel *)timeLabel{
    if(!_timeLabel){
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor colorWithHex:0x666666];
        _timeLabel.font = EC_Font_SystemBold(17);
        _timeLabel.text = @"00 : 00";
    }
    return _timeLabel;
}

- (UICollectionView *)collectionView{
    if(!_collectionView){
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 30;
        layout.itemSize = CGSizeMake(60, 90);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 12);
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, EC_kScreenH - 280, EC_kScreenW, 90) collectionViewLayout:layout];
//        _collectionView.center = CGPointMake(EC_kScreenW / 2, EC_kScreenH / 2 + 45);
        _collectionView.collectionViewLayout = layout;
        _collectionView.backgroundColor = EC_Color_Tabbar;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[ECVoiceMeetingMemberCell class] forCellWithReuseIdentifier:@"ECVoiceMeetingMember_Cell"];
    }
    return _collectionView;
}

- (ECCallOperationView *)microPhoneView{
    if(!_microPhoneView){
        _microPhoneView = [[ECCallOperationView alloc] initWithImage:@"yuyinliaotianIconJingyinNormal" title:NSLocalizedString(@"麦克风", nil)];
        _microPhoneView.textColor = EC_Color_VoiceCall_Text_Gray;
        [_microPhoneView addTarget:self action:@selector(microAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _microPhoneView;
}

- (ECCallOperationView *)exitView{
    if(!_exitView){
        _exitView = [[ECCallOperationView alloc] initWithImage:@"yuyinliaotianIconGuaduanNormal" title:NSLocalizedString(@"退出", nil)];
        _exitView.textColor = EC_Color_VoiceCall_Text_Gray;
        [_exitView addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitView;
}

- (ECCallOperationView *)speakerView{
    if(!_speakerView){
        _speakerView = [[ECCallOperationView alloc] initWithImage:@"yuyinliaotianIconMiantiNormal" title:NSLocalizedString(@"扬声器", nil)];
        _speakerView.textColor = EC_Color_VoiceCall_Text_Gray;
        [_speakerView addTarget:self action:@selector(speakerAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speakerView;
}

- (void)dealloc{
    if(_timer){
        [_timer invalidate];
        _timer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
