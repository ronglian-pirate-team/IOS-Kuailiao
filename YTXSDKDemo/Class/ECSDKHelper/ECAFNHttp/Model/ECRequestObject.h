//
//  ECRequestObject.h
//  YTXSDKDemo
//
//  Created by xt on 17/08/03
//  Copyright (c) __ORGANIZATIONNAME__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECRequestObject : NSObject


@end

@interface ECRequestReadMessageList : ECRequestObject

@property (nonatomic, copy) NSString *msgId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger pageNo;
@property (nonatomic, assign) NSInteger type;

@end


@interface ECRequestQRJoinGroup : ECRequestObject
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *generateQrUserName;
@property (nonatomic, copy) NSString *codeCreateTime;
@property (nonatomic, copy) NSString *joinUserAcc;
@end



