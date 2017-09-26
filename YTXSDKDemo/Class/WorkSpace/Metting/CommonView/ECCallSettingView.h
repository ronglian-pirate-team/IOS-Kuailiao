//
//  ECCallSettingView.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/18.
//
//

#import <UIKit/UIKit.h>

@interface ECCallSettingView : UIView

@property (nonatomic, copy) void (^exitMeeting)();

- (instancetype)initWithOperation:(NSArray *)operations withFixedSpacing:(CGFloat)fixed leadSpacing:(CGFloat)lead tailSpacing:(CGFloat)tail;

@end
