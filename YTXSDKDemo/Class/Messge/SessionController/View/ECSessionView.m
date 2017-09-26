//
//  ECSessionView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/24.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "ECSessionView.h"

#define EC_SESSION_LINKVIEW_V 42.0f

@interface ECSessionView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) ECClickSessionToChatBlock block;
@property (nonatomic, strong) UIView *linkView;

@end

@implementation ECSessionView

- (instancetype)initWithBlock:(ECClickSessionToChatBlock)block {
    if(self = [super init]) {
        [self buildUI];
        self.block = block;
    }
    return self;
}

#pragma mark - 刷新的方法
- (void)ec_reloadSingleRowWithSession:(ECSession *)session {
    NSInteger row = [self.sessionArray indexOfObject:session];
    if (row == NSNotFound) return;
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

#pragma mark - 监听数据源的变化刷新tableview
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"sessionArray"]) {
        [self.tableView reloadData];
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"sessionArray"];
}
#pragma mark - 网络重连时自动登陆
- (void)loginWithHaveUserLogined {
    [[ECDeviceHelper sharedInstanced] ec_loginECSdk:^(ECError *error) {
    }];
}
#pragma mark - 更新头部
-(void)setLinkState:(EC_CONNECTED_LinkState)linkState {
    _linkState = linkState;
    if (linkState == EC_CONNECTED_LinkState_Success) {
        _linkView = nil;
    } else if (linkState == EC_CONNECTED_LinkState_Failed) {
        _linkView = nil;
        UIImage *img = EC_Image_Named(@"xiaoxIconJingtan");
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:(CGRect){20.0f,(EC_SESSION_LINKVIEW_V - img.size.height) / 2,img.size}];
        imgV.image = img;
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imgV.frame) + 11.0f, CGRectGetMinY(imgV.frame), EC_kScreenW - CGRectGetMaxX(imgV.frame) + 11.0f - 20.0f ,self.linkView.ec_height - CGRectGetMinY(imgV.frame) * 2)];
        label.backgroundColor = [UIColor clearColor];
        label.font = EC_Font_System(14.0f);
        label.textColor = EC_Color_Session_LinkViewTitleText;
        label.text = NSLocalizedString(@"当前网络不可用,请检查您的网络设置",nil);
        [self.linkView addSubview:imgV];
        [self.linkView addSubview:label];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginWithHaveUserLogined)];
        [self.linkView addGestureRecognizer:tap];
        
    } else if(linkState == EC_CONNECTED_LinkState_Linking) {
        if (self.linkView.subviews.count != 1) {
            _linkView = nil;
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15.0f, 0.0f, EC_kScreenW - 15 * 2 , self.linkView.ec_height)];
            label.font = EC_Font_System(14.0f);
            label.backgroundColor = [UIColor clearColor];
            label.text = NSLocalizedString(@"连接中...", nil);
            label.textColor = EC_Color_Session_LinkViewTitleText;
            [self.linkView addSubview:label];
        }
    }
    self.tableView.tableHeaderView = _linkView;
}

#pragma mark - UITableViewDataSource和UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sessionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ECSessionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Session_Cell"];
    cell.session = self.sessionArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECSession *session = self.sessionArray[indexPath.row];
    if (self.block)
        self.block(session);
}

- (NSArray<UITableViewRowAction*> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    EC_WS(self)
    ECSessionCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    ECSession *session = weakSelf.sessionArray[indexPath.row];
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"删除",nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [ECAlertController sheetControllerWithTitle:nil message:NSLocalizedString(@"删除后,将清空该聊天的消息记录",nil) cancelTitle:NSLocalizedString(@"取消", nil) DestructiveTitle:@[NSLocalizedString(@"删除", nil)] DefautTitleArray:nil showInView:[AppDelegate sharedInstanced].currentVC handler:^(UIAlertAction *action) {
            if ([action.title isEqualToString:@"删除"]) {
                [weakSelf.sessionArray removeObjectAtIndex:indexPath.row];
                [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_HandleSession object:session userInfo:@{@"type":@(EC_Session_HanleType_Delete)}];
            }
        }];
    }];
    UITableViewRowAction *topAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:session.isTop ? NSLocalizedString(@"取消置顶",nil) : NSLocalizedString(@"置顶会话",nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        session.isTop = !session.isTop;
        [cell endEditing:YES];
        [[ECDevice sharedInstance].messageManager setSession:session.sessionId IsTop:session.isTop completion:^(ECError *error, NSString *seesionId) {
            if (error.errorCode == ECErrorType_NoError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_KNotice_HandleSession object:session userInfo:@{@"type":@(EC_Session_HanleType_Top)}];
                    if(session.isTop){
                        NSIndexPath *firstIndexPath =[NSIndexPath indexPathForRow:0 inSection:indexPath.section];
                        [weakSelf.sessionArray exchangeObjectAtIndex:0 withObjectAtIndex:indexPath.row];
                        [tableView moveRowAtIndexPath:indexPath toIndexPath:firstIndexPath];
                        [tableView reloadRowsAtIndexPaths:@[firstIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                });
            } else {
                session.isTop = !session.isTop;
            }
        }];
    }];
    topAction.backgroundColor = EC_Color_lightGray;
    NSArray *arr = @[deleteAction, topAction];
    return arr;
}

#pragma mark - UI创建
- (void)buildUI{
    UITableView *tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[ECSessionCell class] forCellReuseIdentifier:@"Session_Cell"];
    tableView.rowHeight = 68;
    tableView.tableFooterView = [UIView new];
    [self addSubview:tableView];
    EC_WS(self)
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
    self.tableView = tableView;
    [self addObserver:self forKeyPath:@"sessionArray" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld  context:nil];
}

#pragma mark - 懒加载
- (UIView *)linkView {
    if (!_linkView) {
        _linkView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, EC_SESSION_LINKVIEW_V)];
        _linkView.backgroundColor = EC_Color_Session_LinkView_Bg;
    }
    return _linkView;
}

- (void)setSessionArray:(NSMutableArray *)sessionArray{
    [_sessionArray removeAllObjects];
    _sessionArray = [sessionArray mutableCopy];
}
@end
