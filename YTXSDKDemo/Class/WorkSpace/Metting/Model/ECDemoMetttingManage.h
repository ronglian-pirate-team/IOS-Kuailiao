//
//  ECDemoMetttingManage.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/5.
//
//

#import <Foundation/Foundation.h>

@interface ECDemoMetttingManage : NSObject

+ (instancetype)sharedInstanced;

- (NSMutableArray *)deleteSelfOfMeeting:(NSMutableArray *)members;

@end
