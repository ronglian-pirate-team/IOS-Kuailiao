//
//  ECScanResultVC.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/1.
//
//

#import "ECScanResultVC.h"
#import "ECScanResultView.h"

@interface ECScanResultVC ()

@end

@implementation ECScanResultVC

#pragma mark - UI创建
- (void)buildUI{
    if ([self.scanResultStr hasPrefix:@"http://"] || [self.scanResultStr hasPrefix:@"https://"]) {
        [self buildWebUI];
    } else {
        ECScanResultView *resultView = [[ECScanResultView alloc] init];
        resultView.result = self.scanResultStr;
        [self.view addSubview:resultView];
        EC_WS(self)
        [resultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf.view);
        }];
    }
    [super buildUI];
}

- (void)buildWebUI{
}

@end
