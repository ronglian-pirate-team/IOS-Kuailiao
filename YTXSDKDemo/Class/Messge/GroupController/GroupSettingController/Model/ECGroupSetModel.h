//
//  ECGroupSetModel.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/6.
//

#import <Foundation/Foundation.h>

@interface ECGroupSetModel : NSObject

+ (instancetype)sharedInstanced;

@property (nonatomic, strong) ECGroup *group;

@property (nonatomic, strong) NSMutableArray *members;

@end
