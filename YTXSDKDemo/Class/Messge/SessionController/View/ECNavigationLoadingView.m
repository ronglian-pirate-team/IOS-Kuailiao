//
//  ECNavigationLoadingView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/21.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "ECNavigationLoadingView.h"

@interface ECNavigationLoadingView()
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *alertLabel;

@end

@implementation ECNavigationLoadingView

- (id)initWihTitle:(NSString *)title{
    if(self = [super init]){
        _title = title;
        [self buildUI];
    }
    return self;
}

- (void)buildUI{
    UILabel *alertLabel = [[UILabel alloc] init];
    _alertLabel = alertLabel;
    alertLabel.text = _title;
    alertLabel.textColor = EC_Color_White;
    alertLabel.textAlignment = NSTextAlignmentCenter;
    [alertLabel sizeToFit];
    [self addSubview:alertLabel];
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:_indicatorView];
    [_indicatorView startAnimating];
    alertLabel.frame = CGRectMake(30, 0, alertLabel.frame.size.width, 44);
    _indicatorView.center = CGPointMake(_indicatorView.center.x, 44  / 2);
    self.frame = CGRectMake(0, 0, alertLabel.frame.size.width + 30, 44);
    self.center = CGPointMake(EC_kScreenW / 2, self.center.y);
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.alertLabel.text = title;
}

@end
