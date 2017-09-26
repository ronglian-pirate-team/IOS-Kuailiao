//
//  ECLiveChatRoomList.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/22.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ECLiveChatRoomList.h"
#import "ECAFNHttpTool+LiveChatRoom.h"
#import "ECLiveChatRoomController.h"
#import "LiveChatRoomBaseModel.h"
#import "ECLiveChatRoomListModel.h"
#import "MJRefresh.h"
#import "ECLiveRoomListCell.h"

@interface ECLiveChatRoomList ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) MJRefreshAutoNormalFooter *normalFooter;
@end

@implementation ECLiveChatRoomList

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"直播聊天室列表";
    self.view.backgroundColor = [UIColor colorWithRed:0.95f green:0.95f blue:0.96f alpha:1.00f];
    UIBarButtonItem * rightItem = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        rightItem = [[UIBarButtonItem alloc] initWithTitle:@"创建" style:UIBarButtonItemStylePlain target:self action:@selector(createLiveChatRoom:)];

    } else {
        rightItem = [[UIBarButtonItem alloc] initWithTitle:@"创建" style:UIBarButtonItemStylePlain target:self action:@selector(createLiveChatRoom:)];
    }
    [rightItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;

    [self.view addSubview:self.tableView];
    self.listArray = [NSMutableArray array];
    
    [self queryList];
}

#pragma mark - 基本方法
- (void)queryList {
    
    [MBProgressHUD ec_ShowHUD:self.view withMessage:@"请稍后..."];
    NSString *pageSize = @"20";
    __weak __typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        ECQueryLiveChatRoomListsRequest *request = [[ECQueryLiveChatRoomListsRequest alloc] init];
        request.dateTime = @"";
        request.limit = pageSize;
        [[ECAFNHttpTool sharedInstanced] queryLiveChatRoomLists:request completion:^(NSInteger code, NSArray *lists) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            [strongSelf.tableView.mj_header endRefreshing];
            if (code == 0 ) {
                [strongSelf.listArray removeAllObjects];
                for (NSDictionary *dict in lists) {
                    ECLiveChatRoomListModel *model = [[ECLiveChatRoomListModel alloc] init];
                    [model setValuesForKeysWithDictionary:dict];
                    [strongSelf.listArray addObject:model];
                }
                if ([lists count]>=pageSize.intValue) {
                    //返回订单列表超过分页数量，可以加载更多
                    strongSelf.tableView.mj_footer = strongSelf.normalFooter;
                    [strongSelf.tableView.mj_footer resetNoMoreData];
                } else {
                    //无下拉刷新
                    strongSelf.tableView.mj_footer = nil;
                }
            } else {
                [ECCommonTool toast:@"网络异常"];
                strongSelf.tableView.mj_footer = nil;
            }
            [strongSelf.tableView reloadData];
         }];
    }];
    
    [self.tableView.mj_header beginRefreshing];
    
    _normalFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        ECLiveChatRoomListModel *lastModel = weakSelf.listArray.lastObject;
        ECQueryLiveChatRoomListsRequest *request = [[ECQueryLiveChatRoomListsRequest alloc] init];
        request.dateTime = lastModel.dateCreated;
        request.limit = pageSize;
        [[ECAFNHttpTool sharedInstanced] queryLiveChatRoomLists:request completion:^(NSInteger code, NSArray *lists) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf.tableView.mj_footer endRefreshing];
            if (code == 0 ) {
                for (NSDictionary *dict in lists) {
                    ECLiveChatRoomListModel *model = [[ECLiveChatRoomListModel alloc] init];
                    [model setValuesForKeysWithDictionary:dict];
                    [strongSelf.listArray addObject:model];
                }
                if (lists.count==0) {
                    [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                }
                [strongSelf.tableView reloadData];
            } else {
                [ECCommonTool toast:@"网络异常"];
                [strongSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }];
    }];
}

- (void)popToBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createLiveChatRoom:(id)sender {
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否创建聊天室" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"创建", nil];
    alter.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alter show];
    
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ECLiveRoomListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EC_LIVE_ROOMLISTCELL"];
    ECLiveChatRoomListModel *model = self.listArray[indexPath.row];
    [cell configWithModel:model];
    return cell;
}

const char kLiveChatRoomKey ;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECLiveChatRoomListModel *model = self.listArray[indexPath.row];
    [LiveChatRoomBaseModel sharedInstanced].roomModel = model;
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    [sheet addButtonWithTitle:@"进入直播聊天室"];
    BOOL isCreator = [model.creator isEqualToString:[ECAppInfo sharedInstanced].userName];
    if (isCreator) {
        [sheet addButtonWithTitle:([model.state integerValue]==1)?@"关闭聊天室":@"开启聊天室"];
    }
    objc_setAssociatedObject(sheet, &kLiveChatRoomKey,model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [sheet showInView:self.view];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex!=buttonIndex) {
        if (alertView.title.length==0) {
            [ECCommonTool toast:@"房间名称为空"];
        }
        [MBProgressHUD ec_ShowHUD:self.view withMessage:NSLocalizedString(@"请稍等...", nil)];

        ECCreateLiveChatRoomRequest *request = [[ECCreateLiveChatRoomRequest alloc] init];
        request.creator = [ECAppInfo sharedInstanced].userName;
        request.name = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        request.declared = @"看直播,用容联IMPlus聊天室";
        request.ext = @"{\n  \"livechatroom_pimg\" : \"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1495789173924&di=4ba75c037c4c4766a08a74937ce7d6f4&imgtype=0&src=http%3A%2F%2Fscimg.jb51.net%2Ftouxiang%2F201705%2F2017050421474180.jpg\"\n}";
        request.pullUrl = @"http:yuntongxun.com";
        __weak typeof(self)weakSelf = self;
        [[ECAFNHttpTool sharedInstanced] createLiveChatRoom:request completion:^(NSInteger code, NSString *roomId) {
            
            [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
            if (code==0) {

                ECLiveChatRoomListModel *model = [[ECLiveChatRoomListModel alloc] init];
                model.roomId = roomId;
                model.name = request.name;
                model.declared = request.declared;
                model.ext = request.ext;
                model.state = @"1";
//                model.pullUrl = @"";//用户需要传入拉流地址.
                [weakSelf.listArray addObject:model];
                [weakSelf.tableView reloadData];
            } else {
                EC_Demo_AppLog(@"createLiveChatRoom error code:%d",(int)code);
                [ECCommonTool toast:@"创建聊天室失败"];
            }
        }];
    }
}

#pragma mark - UIActionSheetDelegate 
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.cancelButtonIndex != buttonIndex) {
        
        ECLiveChatRoomListModel *model = objc_getAssociatedObject(actionSheet, &kLiveChatRoomKey);
        if (buttonIndex==1) {
            ECLiveChatRoomController *vc = [[ECLiveChatRoomController alloc] init];
            vc.url = [NSString stringWithFormat:@"%@",model.pullUrl];
            vc.roomId = model.roomId;
            
            ECJoinLiveChatRoomRequest *request = [[ECJoinLiveChatRoomRequest alloc] init];
            request.roomId =model.roomId;
            request.nickName = [ECAppInfo sharedInstanced].persionInfo.nickName.length>0?[ECAppInfo sharedInstanced].persionInfo.nickName:[ECAppInfo sharedInstanced].userName;
            [[ECDevice sharedInstance].liveChatRoomManager joinLiveChatRoom:request completion:^(ECError *error, ECLiveChatRoomInfo *roomInfo, ECLiveChatRoomMember *member) {
                if (error.errorCode ==ECErrorType_NoError) {
                    [LiveChatRoomBaseModel sharedInstanced].roomInfo = roomInfo;
                    [LiveChatRoomBaseModel sharedInstanced].type = member.type;
                    [LiveChatRoomBaseModel sharedInstanced].nickName = member.nickName;
                    [self.navigationController pushViewController:vc animated:NO];
                    [self.navigationController setNavigationBarHidden:YES animated:YES];
                } else {
                    if (error.errorCode==620005) {
                        [ECCommonTool toast:@"房间已关闭"];
                        return ;
                    }
                    [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%ld",(long)error.errorCode] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
                }
            }];
        } else if (buttonIndex==2) {
            NSString *state = ([model.state integerValue]==1)?@"2":@"1";
            ECChangeLiveChatRoomStateRequest *request = [[ECChangeLiveChatRoomStateRequest alloc] init];
            request.state = state;
            request.roomId = model.roomId;
            request.userId = [ECAppInfo sharedInstanced].userName;
            [[ECAFNHttpTool sharedInstanced] changeLiveChatRoomState:request completion:^(NSInteger code, NSString *errStr) {
                if (code==0) {
                    model.state = state;
                    [ECCommonTool toast:state.integerValue==1?@"开启聊天室成功":@"关闭聊天室成功"];
                } else {
                    [ECCommonTool toast:[NSString stringWithFormat:@"%ld",(long)code]];
                }
            }];
        }
    }
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}
#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.rowHeight = 400.0f;
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ECLiveRoomListCell class]) bundle:nil] forCellReuseIdentifier:@"EC_LIVE_ROOMLISTCELL"];
        _tableView.separatorInset = UIEdgeInsetsMake(0, -20, 0, 0);
    }
    return _tableView;
}

@end
