//
//  ECDemoGroupManage+Admin.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/9.
//

#import "ECDemoGroupManage.h"

@interface ECDemoGroupManage (Admin)

@property (nonatomic, strong) NSMutableArray *adminMembers;

- (NSArray *)queryOrdinaryMembers;
@end
