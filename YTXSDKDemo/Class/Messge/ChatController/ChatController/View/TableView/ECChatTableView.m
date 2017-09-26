//
//  ECChatTableView.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/3.
//
//

#import "ECChatTableView.h"
#import "ECMessage+ECUtil.h"
#import "ECChatBaseCell.h"
#import "ECChatTextCell.h"
#import "ECChatImageCell.h"
#import "ECChatVoiceCell.h"
#import "ECChatVideoCell.h"
#import "ECChatLocationCell.h"
#import "ECChatPreviewCell.h"
#import "ECChatFileCell.h"
#import "ECChatCallTextCell.h"
#import "ECChatBaseImgCell.h"
#import "ECChatRedpacketCell.h"
#import "ECChatRedpacketTakenTipCell.h"
#import "ECChatBlockTool.h"
#import "ECChatCellMacros.h"
#import "ECChatVideoCell+SightVideo.h"
#import "ECChatFireImgCell.h"
#import "ECChatRevokeCell.h"
#import "ECSession+Util.h"
#import "ECCellHeightModel.h"

#define ec_chatcell_null_reusedid @"ec_chatcell_null_reusedid"

@interface ECChatTableView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ECChatTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        [self buildUI];
    }
    return self;
}

#pragma mark - 刷新的方法

- (void)ec_reloadSingleRowWithMessage:(ECMessage *)msg {
    EC_WS(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EC_SS(weakSelf);
        for (NSInteger i=strongSelf.messageArray.count-1; i>=0; i--) {
            id content = [strongSelf.messageArray objectAtIndex:i];
            if ([content isKindOfClass:[NSNull class]]) {
                continue;
            }
            ECMessage *message = (ECMessage *)content;
            if ([msg.messageId isEqualToString:message.messageId]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                });
                break;
            }
        }
    });
}

- (void)ec_reloadSingleRow:(ECChatBaseCell *)cell withReplaceMessage:(ECMessage *)msg {
    if ([cell isKindOfClass:[ECChatBaseCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath)
            return;
        [self.messageArray replaceObjectAtIndex:indexPath.row withObject:msg];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)ec_reloadSingleWithReplaceMessage:(ECMessage *)dstMsg {
    EC_WS(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EC_SS(weakSelf);
            for (NSInteger i=strongSelf.messageArray.count-1; i>=0; i--) {
                id content = [strongSelf.messageArray objectAtIndex:i];
                if ([content isKindOfClass:[NSNull class]]) {
                    continue;
                }
                ECMessage *message = (ECMessage *)content;
                if ([dstMsg.messageId isEqualToString:message.messageId]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.messageArray replaceObjectAtIndex:i withObject:dstMsg];
                        [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    });
                    break;
                }
            }
    });
}

- (void)ec_resendMessage:(ECChatBaseCell *)cell withReplaceMessage:(ECMessage *)msg {
    if ([cell isKindOfClass:[ECChatBaseCell class]]) {
        [self.messageArray removeObject:cell.message];
        [self.messageArray addObject:msg];
        [self.tableView reloadData];
    }
}

- (void)ec_deleteRowWithMessage:(ECMessage *)msg {
    NSInteger row = [self.messageArray indexOfObject:msg];
    if (row == NSNotFound) return;
    if (msg == self.messageArray.lastObject) {
        //删除最后消息才需要刷新session
        ECSession *session = [[ECDBManagerUtil sharedInstanced].sessionDic objectForKey:msg.sessionId];
        if (msg == self.messageArray.firstObject) {
            //如果删除的也是唯一一个消息，删除session
            session.text = @"";
            session.type = MessageBodyType_Text;
        } else {
            //使用前一个消息刷新session
            ECMessage *premessage = self.messageArray[row-1];
            session = [ECSession messageConvertToSession:premessage];
            long long int time = [premessage.timestamp longLongValue];
            session.dateTime = time;
        }
        [[ECDBManager sharedInstanced].sessionMgr updateShowSession:session isShow:YES];
    }
    [[ECDBManager sharedInstanced].messageMgr deleteMessage:msg.messageId withSession:msg.sessionId];;
    
    [self.messageArray removeObject:msg];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)ec_chatScrollToBottom:(CGFloat)duration {
    if (self.tableView && self.messageArray.count > 0) {
        EC_WS(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.messageArray.count - 1 inSection:0];
            [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        });
    }
}

- (void)ec_chatScrollViewToBottom:(BOOL)animated {
    if (self.tableView && self.tableView.contentSize.height > self.tableView.frame.size.height) {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.ec_height + 64.0f) ;
        [self.tableView setContentOffset:offset animated:YES];
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    id cellContent = [self.messageArray objectAtIndex:indexPath.row];
    if ([cellContent isKindOfClass:[ECMessage class]]) {
        
        ECMessage *message = (ECMessage*)cellContent;
        if (!message.isRead && message.messageState == ECMessageState_Receive && !message.isReadFireMessage) {
            [[ECDeviceHelper sharedInstanced] ec_readMessage:message];
        }
    }
    
    if ([cell isKindOfClass:[ECChatVideoCell class]]) {
        ECChatVideoCell *videocell = (ECChatVideoCell *)cell;
        [videocell ec_playSightVideo];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    if ([cell isKindOfClass:[ECChatVideoCell class]]) {
        ECChatVideoCell *videocell = (ECChatVideoCell *)cell;
        [videocell ec_stopSightVideo];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cellContent = self.messageArray[indexPath.row];
    
    if ([cellContent isKindOfClass:[NSNull class]]) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ec_chatcell_null_reusedid];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ec_chatcell_null_reusedid];
            cell.backgroundColor = tableView.backgroundColor;
            UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityView.center = CGPointMake(self.ec_width/2, cell.ec_height/2);
            [activityView sizeToFit];
            activityView.tag = 100;
            [cell.contentView addSubview:activityView];
        }
        UIActivityIndicatorView * activityView = (UIActivityIndicatorView *)[cell.contentView viewWithTag:100];
        [activityView startAnimating];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_KNOTIFICATION_ChatRefreshMoreData object:nil];
        });
        return cell;
    }
    ECMessage *message = (ECMessage *)cellContent;
    BOOL isShow = NO;
    if (indexPath.row == 0) {
        isShow = YES;
    } else {
        id preMessagecontent = [self.messageArray objectAtIndex:indexPath.row-1];
        if ([preMessagecontent isKindOfClass:[NSNull class]]) {
            isShow = YES;
        } else {
            NSNumber *isShowNumber = objc_getAssociatedObject(message, &EC_ChatCell_KTimeIsShowKey);
            if (isShowNumber) {
                isShow = isShowNumber.boolValue;
            } else {
                ECMessage *preMessage = (ECMessage*)preMessagecontent;
                long long timestamp = message.timestamp.longLongValue;
                long long pretimestamp = preMessage.timestamp.longLongValue;
                isShow = ((timestamp - pretimestamp) > 180000); //与前一条消息比较大于3分钟显示
            }
        }
    }
    objc_setAssociatedObject(message, &EC_ChatCell_KTimeIsShowKey, @(isShow), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    BOOL isSender = message.messageState==ECMessageState_Receive?NO:YES;
    NSInteger fileType = message.messageBody.messageBodyType;
    NSString *cellidentifier = [NSString stringWithFormat:@"%@_%@_%d", isSender?@"issender":@"isreceiver",NSStringFromClass([message.messageBody class]),(int)fileType];
    cellidentifier = [NSString stringWithFormat:@"%@_%d",cellidentifier,(int)[ECMessage ExtendTypeOfTextMessage:message]];
    ECChatBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    NSInteger extentType = [ECMessage ExtendTypeOfTextMessage:message];
    if (cell == nil) {
        switch (message.messageBody.messageBodyType) {
            case MessageBodyType_None: {
                if ([[message.messageBody class] isSubclassOfClass:[ECRevokeMessageBody class]]) {
                    cell = [[ECChatRevokeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
                }
            }
                break;
            case MessageBodyType_Text:{
                if (EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_BQMM == extentType) {
                    cell = [[ECChatBaseImgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
                } else if (EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_Redpacket == extentType) {
                    cell = [[ECChatRedpacketCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
                } else if (EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_RedpacketTakenTip == extentType){
                    cell = [[ECChatRedpacketTakenTipCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
                } else {
                    cell = [[ECChatTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
                }
            }
                break;
            case MessageBodyType_Voice:
                cell = [[ECChatVoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
                break;
            case MessageBodyType_Video:
                cell = [[ECChatVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
                break;
            case MessageBodyType_Image:
                if (extentType == EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_FIREMESSAGE) {
                    cell = [[ECChatFireImgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
                } else {
                    cell = [[ECChatImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
                }
                break;
            case MessageBodyType_Call:
                cell = [[ECChatCallTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
                break;
            case MessageBodyType_Location:
                cell = [[ECChatLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
                break;
            case MessageBodyType_Preview:
                cell = [[ECChatPreviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
                break;
            case MessageBodyType_File:
                cell = [[ECChatFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
                break;
            default:
                cell = [[ECChatBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
                break;
        }
    }
    cell.message = message;
    cell.backgroundColor = tableView.backgroundColor;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cellContent = self.messageArray[indexPath.row];
    if ([cellContent isKindOfClass:[NSNull class]]) {
        return 44.0f;
    }
    ECMessage *message = (ECMessage *)cellContent;
    EC_Demo_AppLog(@" chat heightForRowAtIndexPath :%f",message.cellHeight);
    CGFloat height = message.cellHeight >0 ?message.cellHeight:[ECCellHeightModel ec_caculateCellSizeWithMessage:message].cellHeight;
    BOOL isShow = [objc_getAssociatedObject(message, &EC_ChatCell_KTimeIsShowKey) boolValue];
    return  height + (isShow?EC_CHAT_TIMEL_H:0);
}

#pragma mark - UI创建
- (void)buildUI {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.tableView];
    [self handleCellBlock];
    [self registerObserve];
}

#pragma nark - cell的操作刷新事件
- (void)handleCellBlock {
    EC_WS(self);
    [ECChatBlockTool sharedInstanced].ec_reloadSingleCellBlock = ^(ECMessage *ec_msg) {
        [weakSelf ec_reloadSingleRowWithMessage:ec_msg];
    };
    [ECChatBlockTool sharedInstanced].ec_replaceSourceMsgBlock = ^(ECMessage *ec_msg) {
        [weakSelf ec_reloadSingleWithReplaceMessage:ec_msg];
    };
    [ECChatBlockTool sharedInstanced].ec_replaceCellBlock = ^(id ec_cell, ECMessage *ec_msg) {
        [weakSelf ec_reloadSingleRow:ec_cell withReplaceMessage:ec_msg];
    };
    [ECChatBlockTool sharedInstanced].ec_deleteCellBlock = ^(ECMessage *ec_msg) {
        [weakSelf ec_deleteRowWithMessage:ec_msg];
    };
    [ECChatBlockTool sharedInstanced].ec_resendCellBlock = ^(id ec_cell, ECMessage *ec_msg) {
        [weakSelf ec_resendMessage:ec_cell withReplaceMessage:ec_msg];
    };
}
#pragma mark - KVO观察者.监听数据源的变化刷新tableview
- (void)registerObserve {
    [self addObserver:self forKeyPath:@"messageArray" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld  context:nil];
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    EC_Demo_AppLog(@"");
    NSArray *array = nil;
    if ([keyPath isEqualToString:@"frame"]) {
        EC_WS(self);
        [UIView animateWithDuration:0.25 delay:0 options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState) animations:^{
            weakSelf.tableView.frame = self.bounds;
            EC_Demo_AppLog(@"%@",weakSelf.tableView);
        } completion:nil];
        if (self.tableView && self.messageArray.count>0){
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messageArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
        }
    } else if ([keyPath isEqualToString:@"messageArray"]) {
        id obj = change[NSKeyValueChangeNewKey];
        if ([obj isKindOfClass:[NSArray class]]) {
            array = (NSArray *)obj;
            if (array.count == 1 && self.messageArray.count > 1) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
                [self ec_chatScrollToBottom:0.0];
            } else {
                [self.tableView reloadData];
                [self ec_chatScrollViewToBottom:YES];
            }
        }
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"messageArray"];
    [self removeObserver:self forKeyPath:@"frame"];
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollsToTop = NO;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.allowsSelection = NO;
        _tableView.frame = self.bounds;
        _tableView.backgroundColor = EC_Color_Clear;
    }
    return _tableView;
}

- (void)setMessageArray:(NSMutableArray *)messageArray {
    [_messageArray removeAllObjects];
    _messageArray = [messageArray mutableCopy];
}

@end
