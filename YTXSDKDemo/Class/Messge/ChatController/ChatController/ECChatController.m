//
//  ECChatController.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/2.
//
//

#import "ECChatController.h"
#import "ECChatNavTitleView.h"
#import "ECChatTableView.h"
#import "ECChatFetchModel.h"
#import "UIImage+ECUtil.h"
#import "ECChatBlockTool.h"
#import "ECChatToolVC.h"
#import "ECDemoChatManager.h"

@interface ECChatController ()<ECBaseContollerDelegate>
@property (nonatomic, strong) ECSession *session;

@property (nonatomic, strong) ECChatTableView *msgView;
@property (nonatomic, strong) ECChatToolVC *chatToolVC;
@property (nonatomic, strong) ECChatNavTitleView *navTitleView;
@end

@implementation ECChatController
{
    dispatch_once_t onceToken;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.layer.contents = (id)[[ECDemoChatManager sharedInstanced] ec_chatBackgroundImageOfSessionId:_session.sessionId sourceImg:nil].CGImage;
    [ECDeviceDelegateConfigCenter sharedInstanced].isConversation = YES;
    EC_WS(self);
    dispatch_once(&onceToken, ^{
        [weakSelf.msgView ec_chatScrollViewToBottom:YES];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [ECDeviceDelegateConfigCenter sharedInstanced].isConversation = NO;
}

#pragma mark - 右上角导航
- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString *__autoreleasing *)str {
    *str = @"chatNaviconQunzuNormal";
    EC_WS(self);
    UIViewController *settingVC = [[NSClassFromString(!_session.isGroup?@"ECSingleChatDetailController":@"ECGroupSettingVC") alloc] init];
    return ^id{
        [weakSelf.navigationController pushViewController:settingVC animated:YES];
        return weakSelf.session.sessionId;
    };
    return nil;
}

#pragma mark - UI创建
- (void)buildUI {
    self.view.layer.contentsGravity = kCAGravityResizeAspect;
    self.baseDelegate = self;
    self.session = [ECAppInfo sharedInstanced].sessionMgr.session;

    self.navTitleView = [[ECChatNavTitleView alloc] init];
    self.navigationItem.titleView = self.navTitleView;
    [self.view addSubview:self.msgView];
    [self addChildViewController:self.chatToolVC];
    EC_WS(self)
    [ECChatFetchModel sharedInstanced].chatModelBlock = ^(NSMutableArray *array) {
        id content = array.lastObject;
        if (array.count == 1 && [content isKindOfClass:[ECMessage class]]) {
            ECMessage *msg = (ECMessage *)content;
            if(msg.messageBody.messageBodyType == MessageBodyType_UserState){
                weakSelf.navTitleView.userState = ((ECUserStateMessageBody *)msg.messageBody).userState.integerValue;
            }else{
                [[weakSelf.msgView mutableArrayValueForKeyPath:@"messageArray"] addObject:array.lastObject];
            }
        } else {
            weakSelf.msgView.messageArray = array;
        }
    };
    [super buildUI];
}

#pragma mark - 懒加载
- (ECChatTableView *)msgView {
    if (!_msgView) {
        _msgView = [[ECChatTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.ec_width, self.view.ec_height - EC_InputView_H)];
        _msgView.messageArray = [[ECChatFetchModel sharedInstanced] ec_fetchMessageModel:_session.sessionId];;
    }
    return _msgView;
}

- (ECChatToolVC *)chatToolVC {
    if (!_chatToolVC) {
        _chatToolVC = [[ECChatToolVC alloc] init];
        ECChatVCModel *model = [[ECChatVCModel alloc] init];
        model.receiver = _session.sessionId;
        model.tableView = self.msgView;
        _chatToolVC = [[ECChatToolVC alloc] initWithModel:model];
        _chatToolVC.view.frame = CGRectMake(0, self.view.ec_height - EC_InputView_H, self.view.ec_width, EC_InputView_H);
        [self.view addSubview:_chatToolVC.view];
    }
    return _chatToolVC;
}
@end
