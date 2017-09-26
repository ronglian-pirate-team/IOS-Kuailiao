//
//  ECChatBlockTool.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/10.
//

#import <Foundation/Foundation.h>

typedef void(^EC_Chat_ReloadSingleCellBlock)(ECMessage *ec_msg);
typedef void(^EC_Chat_ReloadCellWithNewMsgBlock)(id ec_cell,ECMessage *ec_msg);


@interface ECChatBlockTool : NSObject

+ (instancetype)sharedInstanced;

@property (nonatomic, strong) EC_Chat_ReloadSingleCellBlock ec_reloadSingleCellBlock;
@property (nonatomic, strong) EC_Chat_ReloadCellWithNewMsgBlock ec_replaceCellBlock;
@property (nonatomic, strong) EC_Chat_ReloadSingleCellBlock ec_deleteCellBlock;
@property (nonatomic, strong) EC_Chat_ReloadCellWithNewMsgBlock ec_resendCellBlock;
@property (nonatomic, strong) EC_Chat_ReloadSingleCellBlock ec_insertMessageBlock;
@property (nonatomic, strong) EC_Chat_ReloadSingleCellBlock ec_replaceSourceMsgBlock;
@end
