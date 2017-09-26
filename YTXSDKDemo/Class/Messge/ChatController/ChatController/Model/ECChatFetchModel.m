//
//  ECChatFetchModel.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/3.
//
//

#import "ECChatFetchModel.h"
#import "ECChatCellMacros.h"
#import "ECChatBlockTool.h"
#import "ECCellHeightModel.h"

@interface ECChatFetchModel ()
@property (nonatomic, strong) NSMutableArray *msgArray;
@property (nonatomic, strong) NSMutableArray *tempMsgArray;
@property (nonatomic, strong) NSString *sessionId;
@end

@implementation ECChatFetchModel

+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static ECChatFetchModel *model = nil;
    dispatch_once(&onceToken, ^{
        model = [[[self class] alloc] init];
    });
    return model;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.msgArray = [NSMutableArray array];
        self.tempMsgArray = [NSMutableArray array];
        [self addObserver:self forKeyPath:@"msgArray" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_KNOTIFICATION_ReceiveDeleteMessageNoti object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([note.object isKindOfClass:[ECMessage class]]) {
                ECMessage *msg = (ECMessage *)note.object;
                if ([ECChatBlockTool sharedInstanced].ec_reloadSingleCellBlock)
                    [ECChatBlockTool sharedInstanced].ec_reloadSingleCellBlock(msg);
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_KNOTIFICATION_ReceiveReadedMessageNoti object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([note.object isKindOfClass:[ECMessage class]]) {
                ECMessage *msg = (ECMessage *)note.object;
                if ([ECChatBlockTool sharedInstanced].ec_replaceSourceMsgBlock)
                    [ECChatBlockTool sharedInstanced].ec_replaceSourceMsgBlock(msg);
            }
        }];

        [[NSNotificationCenter defaultCenter] addObserverForName:EC_KNOTIFICATION_DeleteMessageNoti object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([note.object isKindOfClass:[ECMessage class]]) {
                ECMessage *msg = (ECMessage *)note.object;
                if ([ECChatBlockTool sharedInstanced].ec_replaceSourceMsgBlock)
                    [ECChatBlockTool sharedInstanced].ec_replaceSourceMsgBlock(msg);
            }
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_DEMO_kNotification_RealoadChatSigleRow object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([note.object isKindOfClass:[ECMessage class]]) {
                ECMessage *msg = (ECMessage *)note.object;
                if ([ECChatBlockTool sharedInstanced].ec_reloadSingleCellBlock)
                    [ECChatBlockTool sharedInstanced].ec_reloadSingleCellBlock(msg);
            }
        }];

        [[NSNotificationCenter defaultCenter] addObserverForName:EC_KNOTIFICATION_ReceiveRevokeMessageNoti object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([note.object isKindOfClass:[ECMessage class]]) {
                ECMessage *msg = (ECMessage *)note.object;
                if ([ECChatBlockTool sharedInstanced].ec_replaceSourceMsgBlock)
                    [ECChatBlockTool sharedInstanced].ec_replaceSourceMsgBlock(msg);
            }
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_KNOTIFICATION_ReadMessageNoti object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if ([note.object isKindOfClass:[ECMessage class]]) {
                ECMessage *msg = (ECMessage *)note.object;
                if ([ECChatBlockTool sharedInstanced].ec_replaceSourceMsgBlock)
                    [ECChatBlockTool sharedInstanced].ec_replaceSourceMsgBlock(msg);
            }
        }];

        [[NSNotificationCenter defaultCenter] addObserverForName:EC_KNOTIFICATION_DownloadMessageCompletion object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            ECError *error = note.userInfo[EC_KErrorKey];
            if (error.errorCode != ECErrorType_NoError)
                return;
            if ([ECChatBlockTool sharedInstanced].ec_reloadSingleCellBlock)
                [ECChatBlockTool sharedInstanced].ec_reloadSingleCellBlock(note.userInfo[EC_KMessageKey]);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ec_newMessageNotify:) name:EC_KNOTIFICATION_SendNewMesssage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ec_newMessageNotify:) name:EC_KNOTIFICATION_SendNewMesssageCompletion object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ec_newMessageNotify:) name:EC_KNOTIFICATION_ReceiveNewMesssage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ec_LoadMoreMessageNotify:) name:EC_KNOTIFICATION_ChatRefreshMoreData object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_KNOTIFICATION_DB_DeleteMessage object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            if (self.chatModelBlock)
                self.chatModelBlock([NSMutableArray array]);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:EC_KNOTIFICATION_Chat_UserState object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            ECMessage *msg = (ECMessage *)note.object;
            if(self.chatModelBlock && [msg isKindOfClass:[ECMessage class]])
                self.chatModelBlock([NSMutableArray arrayWithObject:msg]);
        }];
    }
    return self;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    EC_Demo_AppLog(@"");
    if (self.msgArray.count > 0 && self.chatModelBlock)
        self.chatModelBlock(self.msgArray);
}

- (void)dealloc {
    [[ECChatFetchModel sharedInstanced] removeObserver:self forKeyPath:@"msgArray"];
}

- (NSMutableArray *)ec_fetchMessageModel:(NSString *)sessionId {
    self.sessionId = sessionId;
    NSMutableArray *array = [NSMutableArray arrayWithArray:[[ECDBManager sharedInstanced].messageMgr getLatestSomeMessagesCount:EC_CHAT_LOADMESSAGE_MAXCOUNT OfSession:sessionId]];
    if (array.count == EC_CHAT_LOADMESSAGE_MAXCOUNT)
        [array insertObject:[NSNull null] atIndex:0];
    self.tempMsgArray = array;
    return array;
}

- (void)ec_newMessageNotify:(NSNotification *)noti {
    if (noti.object && [noti.object isKindOfClass:[ECMessage class]]) {
        ECMessage *msg = (ECMessage *)noti.object;
        if ([msg.from isEqualToString:msg.to] && msg.messageState == ECMessageState_SendSuccess)
            return;
        msg = [ECCellHeightModel ec_caculateCellSizeWithMessage:msg];
        if (self.chatModelBlock && [msg.sessionId isEqualToString:self.sessionId])
            self.chatModelBlock([NSMutableArray arrayWithObject:msg]);
        [self.msgArray addObject:msg];
        self.tempMsgArray = self.msgArray;
    } else if (noti.userInfo && [noti.userInfo isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)noti.userInfo;
        ECMessage *msg = dict[EC_KMessageKey];
        if ([ECChatBlockTool sharedInstanced].ec_reloadSingleCellBlock && [msg.sessionId isEqualToString:self.sessionId])
            [ECChatBlockTool sharedInstanced].ec_reloadSingleCellBlock(msg);
    }
}

- (void)ec_LoadMoreMessageNotify:(NSNotification *)noti {
    if (self.tempMsgArray.count > 1) {
        ECMessage *msg = [self.tempMsgArray objectAtIndex:1];
        if (![msg.sessionId isEqualToString:self.sessionId])
            return;
        NSArray *array = [[ECMessageDB sharedInstanced] getSomeMessagesCount:EC_CHAT_LOADMESSAGE_MAXCOUNT OfSession:msg.sessionId beforeTime:msg.timestamp.longLongValue];
        if (array.count == 0)
            [self.tempMsgArray removeObjectAtIndex:0];
        else {
            NSIndexSet *indexset = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, array.count)];
            [self.tempMsgArray insertObjects:array atIndexes:indexset];
            if (array.count < EC_CHAT_LOADMESSAGE_MAXCOUNT) {
                [self.tempMsgArray removeObjectAtIndex:0];
            }
        }
        [self.msgArray removeAllObjects];
        if (self.tempMsgArray.count > 0 && self.chatModelBlock)
            self.chatModelBlock(self.tempMsgArray);
    }
}

@end
