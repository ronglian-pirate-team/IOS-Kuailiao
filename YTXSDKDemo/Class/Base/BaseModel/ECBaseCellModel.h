//
//  ECBaseCellModel.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/24.
//

#import <Foundation/Foundation.h>

@interface ECBaseCellModel : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *detailText;
@property (nonatomic, strong) UIImage *iconImg;
@property (nonatomic, copy) NSString *modelType;

+ (instancetype)baseModelWithText:(NSString*)text detailText:(NSString*)detailText img:(UIImage*)iconImg modelType:(NSString *)modelType;

@end
