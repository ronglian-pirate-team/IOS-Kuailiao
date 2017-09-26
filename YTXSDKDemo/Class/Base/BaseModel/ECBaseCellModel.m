//
//  ECBaseCellModel.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/24.
//

#import "ECBaseCellModel.h"

@implementation ECBaseCellModel
- (instancetype)initWithText:(NSString *)text detailText:(NSString *)detailText img:(UIImage *)iconImg modelType:(NSString*)modelType {
    if (self==[super init]) {
        _text = [text copy];
        _detailText = [detailText copy];
        _iconImg = iconImg?:nil;
        _modelType = [modelType copy];
    }
    return self;
}

+ (instancetype)baseModelWithText:(NSString *)text detailText:(NSString *)detailText img:(UIImage *)iconImg modelType:(NSString*)modelType {
    return [[self alloc] initWithText:text detailText:detailText img:iconImg modelType:modelType];
}
@end
