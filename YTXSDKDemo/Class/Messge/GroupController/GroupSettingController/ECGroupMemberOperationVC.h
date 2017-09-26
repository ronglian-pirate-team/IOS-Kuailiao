//
//  ECGroupDeleteMemberVC.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/15.
//
//

#import "ECBaseContoller.h"

typedef NS_ENUM(NSInteger, ECGroupMemberOperation){
    ECGroupMemberOperation_Delete = 1,
    ECGroupMemberOperation_Forbid
};

@interface ECGroupMemberOperationVC : ECBaseContoller

@end
