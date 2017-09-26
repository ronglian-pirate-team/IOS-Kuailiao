//
//  ECDBMacro.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/25.
//

#ifndef ECDBMacro_h
#define ECDBMacro_h

#import "ECDBManager.h"

#define EC_KNOTIFICATION_DB_DeleteMessage              @"EC_KNOTIFICATION_DB_DeleteMessage"

#define EC_DB_LOG(fmt,...) ![ECDBManager sharedInstanced].isOpenDebugLog?:NSLog((fmt), ##__VA_ARGS__);

#define EC_ValidateNullStr(originalStr) (!originalStr || [originalStr isKindOfClass:[NSNull class]] || [originalStr isKindOfClass:[NSNull class]] || [[originalStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 || originalStr == nil) ? @"" : originalStr

#define EC_ISNullStr(originalStr) (!originalStr || [originalStr isKindOfClass:[NSNull class]] || [originalStr isKindOfClass:[NSNull class]] || [[originalStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 || originalStr == nil)

#endif /* ECDBMacro_h */
