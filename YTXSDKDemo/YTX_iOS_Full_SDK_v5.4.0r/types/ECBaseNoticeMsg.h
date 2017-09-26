//
//  ECBaseNoticeMsg.h
//  CCPiPhoneSDK
//
//  Created by huangjue on 2017/9/1.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ECBaseNoticeMsg_Type_None,
    
    ECBaseNoticeMsg_Type_Group,
    
    ECBaseNoticeMsg_Type_Friend,
    
} ECBaseNoticeMsg_Type;

@interface ECBaseNoticeMsg : NSObject

@property (nonatomic, readonly) ECBaseNoticeMsg_Type baseType;

/**
 @brief 通知消息的时间
 */
@property (nonatomic, copy) NSString *dateCreated;

@property (nonatomic, assign) BOOL isRead;

@end
