//
//  ECChatNavTitleView.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/2.
//
//

#import "ECChatNavTitleView.h"

#define EC_ChatNav_titleViewH 44.0f
#define EC_ChatNav_titleViewW 120.0f
#define EC_ChatNav_HorMargin 20.0f

@interface ECChatNavTitleView ()
@property (nonatomic, strong) UILabel *titleL;
@property (nonatomic, strong) UILabel *stateL;
@end
@implementation ECChatNavTitleView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self buildUI];
    }
    return self;
}

- (void)setUserState:(ECUserInputState)userState{
    switch (userState) {
        case ECUserInputState_None:
            self.titleL.text = [ECDeviceHelper ec_getNickNameWithSessionId:[ECAppInfo sharedInstanced].sessionMgr.session.sessionId];

            break;
        case ECUserInputState_White:
            self.titleL.text = NSLocalizedString(@"正在输入...", nil);
            break;
        case ECUserInputState_Record:
            self.titleL.text = NSLocalizedString(@"正在录音...", nil);
            break;
        default:
            break;
    }
}

- (void)buildUI {
    [self addSubview:self.titleL];
    if (![ECAppInfo sharedInstanced].sessionMgr.session.isGroup) {
        [self addSubview:self.stateL];
        [[ECDevice sharedInstance] getUsersState:@[[ECAppInfo sharedInstanced].sessionMgr.session.sessionId] completion:^(ECError *error, NSArray *usersState) {
            ECUserState *state = usersState.firstObject;
            if ([[ECAppInfo sharedInstanced].sessionMgr.session.sessionId isEqualToString:state.userAcc]) {
                if (state.isOnline) {
                    self.stateL.text = [NSString stringWithFormat:@"%@-%@", [ECDeviceHelper ec_getDeviceWithType:state.deviceType], [ECDeviceHelper ec_getNetWorkWithType:state.network]];
                } else {
                    self.stateL.text = @"对方不在线";
                }
            }
        }];
    }
    self.frame = CGRectMake(0, 0, EC_ChatNav_titleViewW, EC_ChatNav_titleViewH);
    self.center = CGPointMake(EC_kScreenW / 2, self.center.y);
}

- (UILabel *)titleL {
    if (!_titleL) {
        _titleL = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0, EC_ChatNav_titleViewW, ![ECAppInfo sharedInstanced].sessionMgr.session.isGroup?EC_ChatNav_titleViewH*0.7:EC_ChatNav_titleViewH)];
        _titleL.textAlignment = NSTextAlignmentCenter;
        _titleL.textColor = [UIColor whiteColor];
        _titleL.backgroundColor = [UIColor clearColor];
        _titleL.text = [ECDeviceHelper ec_getNickNameWithSessionId:[ECAppInfo sharedInstanced].sessionMgr.session.sessionId];
    }
    return _titleL;
}

- (UILabel *)stateL {
    if (!_stateL) {
        _stateL = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.titleL.frame), EC_ChatNav_titleViewW, EC_ChatNav_titleViewH*0.3)];
        _stateL.font = [UIFont systemFontOfSize:11.0f];
        _stateL.textAlignment = NSTextAlignmentCenter;
        _stateL.textColor = [UIColor whiteColor];
        _stateL.backgroundColor = [UIColor clearColor];
        _stateL.text = @"对方不在线";
    }
    return _stateL;
}
@end
