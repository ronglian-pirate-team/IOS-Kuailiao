//
//  ECReadMessageController.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/26.
//

#import "ECReadMessageController.h"

@interface ECReadMessageController ()<ECBaseContollerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UIView *segHeadView;
@property (nonatomic, strong) UISegmentedControl *segment;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *memberArray;
@property (nonatomic, strong) NSMutableArray *cacheUnReadArray;
@property (nonatomic, strong) NSMutableArray *cacheReadArray;
@property (nonatomic, strong) ECMessage *message;

@end

@implementation ECReadMessageController

#pragma mark - 点击seg
- (void)onclickedSegment:(UISegmentedControl *)segment {
    switch (segment.selectedSegmentIndex) {
        case 0: {
            [_memberArray removeAllObjects];
            [_memberArray addObjectsFromArray:_cacheUnReadArray];
        }
            break;
        case 1: {
            [_memberArray removeAllObjects];
            [_memberArray addObjectsFromArray:_cacheReadArray];
        }
            break;
            
        default:
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - 查询
- (void)queryMessageReadCount {
    
    [MBProgressHUD ec_ShowHUD:self.view withMessage:@"请求中..."];
    
    EC_WS(self);
    __block BOOL isRead = NO;
    __block BOOL isUnread = NO;
    ECRequestReadMessageList *request = [[ECRequestReadMessageList alloc] init];
    request.type = 1;
    request.msgId = _message.messageId;
    request.pageSize = 50;
    request.pageNo = 1;
    [[ECAFNHttpTool sharedInstanced] queryMessageReadStatus:request completion:^(NSString *err, NSArray *array, NSInteger totalSize) {
        if (err.integerValue != 0) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请求失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        } else {
            isRead = YES;
            [_cacheReadArray addObjectsFromArray:array];
            NSString *item2 = [NSString stringWithFormat:@"已读%@",_cacheReadArray.count>0?[NSString stringWithFormat:@"(%ld)",(long)_cacheReadArray.count]:@""];
            [_segment setTitle:item2 forSegmentAtIndex:1];
            if (isRead && isUnread) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            }
        }
    }];
    
    ECRequestReadMessageList *unreadRequest = [[ECRequestReadMessageList alloc] init];
    unreadRequest.type = 2;
    unreadRequest.msgId = _message.messageId;
    unreadRequest.pageSize = 50;
    unreadRequest.pageNo = 1;
    
    [[ECAFNHttpTool sharedInstanced] queryMessageReadStatus:unreadRequest completion:^(NSString *err, NSArray *array, NSInteger totalSize) {
        if (err.integerValue != 0) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"请求失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        } else {
            isUnread = YES;
            [_memberArray addObjectsFromArray:array];
            [_cacheUnReadArray addObjectsFromArray:array];
            [weakSelf.tableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.message.readCount = _cacheUnReadArray.count;
                [[ECMessageDB sharedInstanced] updateMessageReadCount:self.message.sessionId messageId:self.message.messageId readCount:self.message.readCount];
                NSString *item1 = [NSString stringWithFormat:@"未读%@",_cacheUnReadArray.count>0?[NSString stringWithFormat:@"(%ld)",(long)_cacheUnReadArray.count]:@""];
                [_segment setTitle:item1 forSegmentAtIndex:0];
                [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_RealoadChatSigleRow object:self.message];
            });
            if (isRead && isUnread) {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            }
        }    }];
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _memberArray.count;
}

static NSString *cellId = @"cellId";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    if (cell==nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    }
    id contact = [_memberArray objectAtIndex:indexPath.row];
    NSString *memberId = nil;
    if ([contact isKindOfClass:[ECReadMessageMember class]]) {
        ECReadMessageMember *member = (ECReadMessageMember*)contact;
        memberId = member.userName;
    } else if ([contact isKindOfClass:[NSString class]]) {
        memberId = (NSString*)contact;
    }
    NSString *nickName = [ECDeviceHelper ec_getNickNameWithSessionId:memberId];
    cell.imageView.layer.cornerRadius = 15;
    cell.imageView.layer.masksToBounds = YES;
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",memberId,@"iconReadMessage"]];
    UIImage *image = [UIImage imageWithData:data];
    if (image == nil) {
        image = [UIImage ec_circleImageWithColor:[UIColor orangeColor] withSize:CGSizeMake(30, 30) withName:nickName.length>2?[nickName substringFromIndex:nickName.length-2]:nickName];
        [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:[NSString stringWithFormat:@"%@_%@",memberId,@"iconReadMessage"]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    cell.imageView.image = image;
    cell.textLabel.text = nickName;
    return cell;
}

#pragma mark - UI创建
- (void)buildUI {
    _message = self.basePushData;
    self.baseDelegate = self;
    _memberArray = [NSMutableArray array];
    _cacheUnReadArray = [NSMutableArray array];
    _cacheReadArray = [NSMutableArray array];;
    [self queryMessageReadCount];
    self.title =NSLocalizedString(@"消息回执列表", nil);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view addSubview:self.segHeadView];
    [self.view addSubview:self.tableView];
    [super buildUI];
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_segHeadView.frame), self.view.bounds.size.width, self.view.bounds.size.height-CGRectGetMaxY(_segHeadView.frame)) style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.backgroundColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1];
        _tableView.tableHeaderView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (UIView *)segHeadView {
    if (!_segHeadView) {
        _segHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44.0f)];
        _segHeadView.backgroundColor = EC_Color_White;
        NSString *item1 = [NSString stringWithFormat:@"未读%@",_cacheUnReadArray.count>0?[NSString stringWithFormat:@"(%ld)",(long)_cacheUnReadArray.count]:@""];
        NSString *item2 = [NSString stringWithFormat:@"已读%@",_cacheReadArray.count>0?[NSString stringWithFormat:@"(%ld)",(long)_cacheReadArray.count]:@""];
        _segment = [[UISegmentedControl alloc] initWithItems:@[item1,item2]];
        _segment.selectedSegmentIndex = 0;
        _segment.frame = CGRectMake(10, 7.0f, self.view.bounds.size.width- 10 * 2, 30.0f);
        [_segment addTarget:self action:@selector(onclickedSegment:) forControlEvents:UIControlEventValueChanged];
        [_segHeadView addSubview:_segment];
    }
    return _segHeadView;
}
@end
