//
//  NSObject+ECSwizzleMethod.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/30.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (ECSwizzleMethod)

- (BOOL)ec_validObserverKeyPath:(NSString *)key;

- (instancetype)initWithData:(id)data;

- (instancetype)initWithBaeOneObjectCompletion:(ECBaseCompletionOneObjectBlock)baseOneObjectCompletion;
- (instancetype)initWithBaeTwoObjectCompletion:(ECBaseCompletionTwoObjectBlock)baseTwoObjectCompletion;
- (instancetype)initWithBaeOneObjectCompletion:(ECBaseCompletionOneObjectBlock)baseOneObjectCompletion nothingTitle:(NSString *)nothingTitle;
- (instancetype)initWithBaeTwoObjectCompletion:(ECBaseCompletionTwoObjectBlock)baseTwoObjectCompletion nothingTitle:(NSString *)nothingTitle;


- (void)ec_swizzleMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;

@end
