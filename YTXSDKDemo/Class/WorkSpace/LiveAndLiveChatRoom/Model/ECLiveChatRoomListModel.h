//
//  ECLiveChatRoomListModel.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/6/8.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECLiveChatRoomListModel : NSObject

@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *pullUrl;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *creator;
@property (nonatomic, copy) NSString *dateCreated;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *declared;
@property (nonatomic, copy) NSString *ext;
@property (nonatomic, copy) NSString *portrait;
@end
