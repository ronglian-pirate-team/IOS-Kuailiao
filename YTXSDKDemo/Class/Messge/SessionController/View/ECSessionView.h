//
//  ECSessionView.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/24.
//  Copyright © 2017年 xt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSessionCell.h"

typedef enum : NSUInteger {
    EC_Session_HanleType_Delete=1,
    EC_Session_HanleType_Top,
} EC_Session_HanleType;

typedef void(^ECClickSessionToChatBlock)(ECSession *session);


@interface ECSessionView : UIView

@property (nonatomic, strong) NSMutableArray *sessionArray;

@property (nonatomic, assign) EC_CONNECTED_LinkState linkState;

- (instancetype)initWithBlock:(ECClickSessionToChatBlock)block;

- (void)ec_reloadSingleRowWithSession:(ECSession *)session;
@end
