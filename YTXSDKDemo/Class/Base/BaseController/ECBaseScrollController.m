//
//  ECBaseScrollController.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/17.
//

#import "ECBaseScrollController.h"
#import "UIScrollView+ECTouch.h"

@interface ECBaseScrollController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation ECBaseScrollController
- (void)loadView {
    self.view = self.scrollView;
}

#pragma mark - 添加通知
- (void)ec_addNotify {
    [super ec_addNotify];
}

#pragma mark - UI创建
- (void)buildUI {
    [super buildUI];
    UIView *lastView = self.view.subviews.lastObject;
    _scrollView.contentSize = CGSizeMake(EC_kScreenW, lastView.ec_height + lastView.ec_y);
}

#pragma mark - 懒加载
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.frame = CGRectMake(0, 0, EC_kScreenW, EC_kScreenH - 64);
        _scrollView.contentSize = CGSizeMake(EC_kScreenW, EC_kScreenH);
    }
    return _scrollView;
}
@end
