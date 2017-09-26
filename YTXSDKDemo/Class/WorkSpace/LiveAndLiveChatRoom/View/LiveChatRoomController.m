//
//  LiveChatRoomController.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/5/8.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "LiveChatRoomController.h"
#import "ECDeviceDelegateHelper+LiveChatRoom.h"
#import "ECLiveChatRoomCell.h"
#import "LiveChatRoomBaseModel.h"

@interface LiveChatRoomController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) NSMutableArray *messageArray;
@property (nonatomic, strong) ECLiveChatRoomInfo *info;
@property (nonatomic, strong) LiveChatRoomTool *liveChatRoomTool;
@end

@implementation LiveChatRoomController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self registNotification];
}

- (void)prepareUI {
    [self.view addSubview:self.myTableView];
    
    __weak typeof(self)weakSelf = self;
    [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
}

- (void)registNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillChangeFame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView:) name:EC_KNOTIFICATION_onLiveChatRoomMesssageChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableView:) name:EC_KNOTIFICATION_SendLiveChatRoomMessageCompletion object:nil];
    
}

- (void)unRegistNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}
#pragma mark - 基本方法
#pragma mark - 通知方法
- (void)keyBoardWillChangeFame:(NSNotification *)noti {
    
    LiveChatRoomTool *chatToolView = [LiveChatRoomTool sharedInstanced];
    
    NSDictionary *userInfo = noti.userInfo;
    //    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat viewH = endFrame.size.height;
    CGRect frame = self.view.frame;
    if (endFrame.origin.y==EC_kScreenH) {
        frame.origin.y = EC_kScreenH-ECMsgH-80.0f-30.0f;
        viewH = 0;
    } else {
        frame.origin.y = EC_kScreenH-viewH-ECMsgH-ECToolViewH-30.0f;
    }
    frame.size.width = EC_kScreenW*0.8;
    __weak typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.1 delay:0.0f options:(UIViewAnimationOptionBeginFromCurrentState) animations:^{
        weakSelf.view.frame = frame;
        chatToolView.frame = CGRectMake(0, EC_kScreenH-ECToolViewH-viewH, EC_kScreenW, ECToolViewH);
    } completion:^(BOOL finished) {
    }];
    if (self.messageArray.count>0) {
        [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)refreshTableView:(NSNotification *)noti {
    ECMessage *msg = nil;
    if ([noti.userInfo isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = noti.userInfo;
        ECError *error = dict[EC_KErrorKey];
        if(error.errorCode != ECErrorType_NoError)
            return;
        msg = dict[EC_KMessageKey];
        if (error.errorCode == ECErrorType_LiveChatRoom_Forbid) {
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_kNotificationCenter_ClickMessageSender object:nil];
            [ECCommonTool toast:@"您已被禁言"];
            if ([self.messageArray containsObject:msg]) {
                NSInteger row = [self.messageArray indexOfObject:msg];
                [self.messageArray removeObject:msg];
                if (self.messageArray.count==0) {
                    [self.myTableView reloadData];
                } else {
                    [self.myTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
                }
            }
            return;
        }
    }
    if (noti.object) {
        msg = (ECMessage *)noti.object;
    }
    if (![msg.to isEqualToString:self.chatRoomId]) {
        return;
    }
    [self.messageArray addObject:msg];
    [self.myTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        if (self.messageArray.count>0){
            [UIView performWithoutAnimation:^{
                [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }];
        }
    });
}
#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusedCellId = @"livechatroommessage_reused";
    ECLiveChatRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedCellId];
    if (!cell) {
        cell = [[ECLiveChatRoomCell alloc] initWithStyle:0 reuseIdentifier:reusedCellId];
        cell.backgroundColor = [UIColor clearColor];
    }
    [cell bindData:(ECMessage *)self.messageArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECMessage *msg = (ECMessage *)self.messageArray[indexPath.row];
    [self.liveChatRoomTool.inputTextView resignFirstResponder];
    if (![msg.from isEqualToString:@"系统消息"])
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_kNotificationCenter_ClickMessageSender object:msg];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ECMessage *msg = (ECMessage *)self.messageArray[indexPath.row];
    ECTextMessageBody *textBody = (ECTextMessageBody *)msg.messageBody;
    NSString *nickName = msg.senderName;
    if(nickName.length > 6)
        nickName = [nickName substringToIndex:6];
    if(nickName.length == 0)
        nickName = msg.from;
    NSString *text = nickName;//[NSString stringWithFormat:@"%@:",msg.senderName.length==0?msg.from:msg.senderName];
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]}];
    CGSize contentSize = [textBody.text boundingRectWithSize:CGSizeMake(EC_kScreenW*0.8-size.width-15-40, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]} context:nil].size;
    return contentSize.height<40?40:contentSize.height+20;
}
#pragma mark - LiveChatRoomToolDelegate
- (void)liveChatRoomTool:(LiveChatRoomTool *)liveChatRoomTool growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    self.liveChatRoomTool = liveChatRoomTool;
    __weak __typeof(self)weakSelf = self;
    float diff = (growingTextView.frame.size.height - height);
    void(^animations)() = ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            CGRect rect = liveChatRoomTool.frame;
            rect.size.height -= diff;
            rect.origin.y += diff;
            liveChatRoomTool.frame = rect;
            
            CGRect tableFrame = strongSelf.myTableView.frame;
            tableFrame.size.height += diff;
            strongSelf.myTableView.frame = tableFrame;
        }
    };
    
    [UIView animateWithDuration:0.1 delay:0.0f options:(UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:nil];
    if (self && self.messageArray.count>0){
        [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (BOOL)liveChatRoomTool:(LiveChatRoomTool *)liveChatRoomTool growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    self.liveChatRoomTool = liveChatRoomTool;
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [self sendTextMessage:growingTextView.text];
        growingTextView.text = @"";
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    if (range.length == 1) {
        return YES;
    }
    return YES;
}

- (void)LiveChatRoomTool:(LiveChatRoomTool *)liveChatRoomTool emojiSendBtn:(UIButton *)sender {
    self.liveChatRoomTool = liveChatRoomTool;
    [self sendTextMessage:liveChatRoomTool.inputTextView.text];
    liveChatRoomTool.inputTextView.text = @"";
}
#pragma mark - 发送消息
/**
 *@brief 发送文本消息
 */
-(void)sendTextMessage:(NSString *)text {
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length==0) {
        [ECCommonTool toast:@"不能发送空白消息"];
        return;
    }
    ECTextMessageBody *msgBody = [[ECTextMessageBody alloc] initWithText:text];
    ECMessage *msg = [[ECMessage alloc] initWithReceiver:self.chatRoomId body:msgBody];
    msg.senderName = [LiveChatRoomBaseModel sharedInstanced].nickName.length>0?[LiveChatRoomBaseModel sharedInstanced].nickName:
    [ECAppInfo sharedInstanced].persionInfo.nickName;
    msg = [[ECDeviceHelper sharedInstanced] ec_sendLiveChatRoomMessage:msg];
}

#pragma mark - 懒加载
- (UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] init];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.tableFooterView = [UIView new];
        _myTableView.backgroundColor = [UIColor clearColor];
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myTableView.sectionHeaderHeight = 60.0f;
        _myTableView.estimatedRowHeight = 100.0f;
    }
    return _myTableView;
}

- (NSMutableArray *)messageArray {
    if (!_messageArray) {
        _messageArray = [NSMutableArray array];
        ECTextMessageBody *body = [[ECTextMessageBody alloc] initWithText:@"我们倡导绿色直播，封面和直播内容含吸烟、低俗、引诱、暴露等都会被封停帐号，同时禁止直播聚众闹事、集会，网警24小时在线巡逻，文明直播，从我做起"];
        ECMessage *messge = [[ECMessage alloc] initWithReceiver:self.chatRoomId body:body];
        messge.from = @"系统通知";
        [_messageArray addObject:messge];
    }
    return _messageArray;
}

- (void)dealloc {
    [self unRegistNotification];
}
@end
