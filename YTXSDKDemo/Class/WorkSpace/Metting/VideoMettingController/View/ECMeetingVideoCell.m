//
//  ECMutiVideoCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/19.
//
//

#import "ECMeetingVideoCell.h"

#define EC_DEMO_kNotification_RequestVideo @"EC_DEMO_kNotification_RequestVideo"

@interface ECMeetingVideoCell ()

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation ECMeetingVideoCell

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestVideo:) name:EC_DEMO_kNotification_RequestVideo object:nil];
        [self buildUI];
    }
    return self;
}

- (void)requestVideo:(NSNotification *)noti{
    NSString* notiAccount = noti.object;
    if(![notiAccount isEqualToString:self.videoMeetingMember.voipAccount.account])
        return;
    NSString *account = self.videoMeetingMember.voipAccount.account;
    self.nameLabel.text = (account.length > 4 ? [account substringFromIndex:account.length - 4] : account);
    NSArray *addrarr = [self.videoMeetingMember.videoSource componentsSeparatedByString:@":"];
    if (addrarr.count == 2){
        NSString *port = [addrarr objectAtIndex:1];
        [[ECDevice sharedInstance].meetingManager setVideoConferenceAddr:addrarr[0]];
        [self requestVideo:account andPort:port inView:self.bgView withRoomNum:self.meetingRoomNum];
    }
}

- (void)requestVideo:(NSString *)account andPort:(NSString *)port inView:(UIView *)view withRoomNum:(NSString *)meetingRoom{
    if([account isEqualToString:[ECDevicePersonInfo sharedInstanced].userName])
        return;
    [[ECDevice sharedInstance].meetingManager requestMemberVideoWithAccount:account andDisplayView:view andVideoMeeting:meetingRoom andPwd:nil andPort:[port integerValue] completion:^(ECError *error, NSString *meetingNumber, NSString *member) {
        if (error.errorCode == ECErrorType_NoError) {
            EC_Demo_AppLog(@"获取到视频");
        }else {
//            [self requestVideo:account andPort:port inView:view withRoomNum:meetingRoom];
        }
    }];
}

- (void)setVideoMeetingMember:(ECMultiVideoMeetingMember *)videoMeetingMember{
    _videoMeetingMember = videoMeetingMember;
    NSString *account = videoMeetingMember.voipAccount.account;
//    self.nameLabel.text = (account.length > 4 ? [account substringFromIndex:account.length - 4] : account);
    self.nameLabel.text = account;
    NSArray *addrarr = [videoMeetingMember.videoSource componentsSeparatedByString:@":"];
    if (addrarr.count == 2){
        NSString *port = [addrarr objectAtIndex:1];
        [[ECDevice sharedInstance].meetingManager setVideoConferenceAddr:addrarr[0]];
        [self requestVideo:account andPort:port inView:self.bgView withRoomNum:self.meetingRoomNum];
    }
}

- (void)buildUI{
    [self addSubview:self.bgView];
    EC_WS(self)
    [self addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf).offset(7);
        make.right.equalTo(weakSelf).offset(-7);
        make.bottom.equalTo(weakSelf).offset(-5);
    }];
}

- (UIView *)bgView{
    if(!_bgView){
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88, 88)];
        _bgView.backgroundColor = EC_Color_Clear;
    }
    return _bgView;
}

- (UILabel *)nameLabel{
    if(!_nameLabel){
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = EC_Color_White;
        _nameLabel.font = EC_Font_System(11);
    }
    return _nameLabel;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
