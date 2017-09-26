//
//  ECGroupTypeVC.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/26.
//
//

#import "ECBaseContoller.h"

@interface ECGroupTypeVC : ECBaseContoller

@property (nonatomic, copy) void (^selectType)(NSInteger index, NSString *type);

@end
