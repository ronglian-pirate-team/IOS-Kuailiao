//
//  ECBaseContoller.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/19.
//  Copyright © 2017年 huangjue. All rights reserved.
//

#import "ECBaseContoller.h"
#import "ECBaseBackgroundView.h"
#import "ECBaseManage.h"

@interface ECBaseContoller ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) ECBaseItemBlock rightItemBlock;
@property (nonatomic, strong) ECBaseItemBlock leftItemBlock;
@property (nonatomic, strong) ECBaseBackgroundView *nothingView;
@property (nonatomic, copy) NSString *nothingTitle;
@end

@implementation ECBaseContoller

- (instancetype)initWithData:(id)data {
    self = [super init];
    if (self) {
        self.baseToData = data;
    }
    return self;
}

- (instancetype)initWithBaeOneObjectCompletion:(ECBaseCompletionOneObjectBlock)baseOneObjectCompletion {
    self = [super init];
    if (self) {
        self.baseOneObjectCompletion = baseOneObjectCompletion;
    }
    return self;
}

- (instancetype)initWithBaeTwoObjectCompletion:(ECBaseCompletionTwoObjectBlock)baseTwoObjectCompletion {
    self = [super init];
    if (self) {
        self.baseTwoObjectCompletion = baseTwoObjectCompletion;
    }
    return self;
}

- (instancetype)initWithBaeOneObjectCompletion:(ECBaseCompletionOneObjectBlock)baseOneObjectCompletion nothingTitle:(NSString *)nothingTitle {
    self = [super init];
    if (self) {
        self.baseOneObjectCompletion = baseOneObjectCompletion;
        self.nothingTitle = nothingTitle;
    }
    return self;
}

- (instancetype)initWithBaeTwoObjectCompletion:(ECBaseCompletionTwoObjectBlock)baseTwoObjectCompletion nothingTitle:(NSString *)nothingTitle {
    self = [super init];
    if (self) {
        self.baseTwoObjectCompletion = baseTwoObjectCompletion;
        self.nothingTitle = nothingTitle;
    }
    return self;
}

- (void)viewDidLoad {
    self.basePushData = [ECBaseManage sharedInstanced].basePushData;
    [super viewDidLoad];
    [self buildUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self ec_addNotify];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.navigationController){
        if(self.navigationController.viewControllers.firstObject == self){
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }else{
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
    }
}

#pragma mark - 添加通知
- (void)ec_addNotify {
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"self.baseDataArray"]) {
        [[change objectForKey:NSKeyValueChangeNewKey] count]>0?[self hiddenNothingView]:[self showNothingView:self.nothingTitle];
    }
}

- (void)dealloc {
    if ([self ec_validObserverKeyPath:@"self.baseDataArray"])
        [self removeObserver:self forKeyPath:@"self.baseDataArray"];
}

#pragma mark - 导航
- (void)configLeftBtnItem {
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(baseController:configLeftBtnItemWithStr:)]) {
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn addTarget:self action:@selector(clickedLeftItem:) forControlEvents:UIControlEventTouchUpInside];
        NSString *str = nil;
        self.leftItemBlock = [self.baseDelegate baseController:self configLeftBtnItemWithStr:&str];
        if (str) {
            UIImage *img = EC_Image_Named(str);
            if (img) {
                [leftBtn setImage:img forState:UIControlStateNormal];
            } else {
                [leftBtn setTitle:str forState:UIControlStateNormal];
            }
            [leftBtn sizeToFit];
        }
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        return;
    }
    
    UIBarButtonItem * leftItem = nil;
    leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"endingdianhuaBtnBack2"] style:UIBarButtonItemStyleDone target:self action:@selector(popViewController:)];
    if (self.navigationController.childViewControllers.count>1)
        self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)configRightBtnItem {
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(baseController:configRightBtnItemWithStr:)]) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn addTarget:self action:@selector(clickedRightItem:) forControlEvents:UIControlEventTouchUpInside];
        NSString *str = nil;
        self.rightItemBlock = [self.baseDelegate baseController:self configRightBtnItemWithStr:&str];
        if (str) {
            UIImage *img = EC_Image_Named(str);
            if (img) {
                [rightBtn setImage:img forState:UIControlStateNormal];
            } else {
                [rightBtn setTitle:str forState:UIControlStateNormal];
            }
            [rightBtn sizeToFit];
        }
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    }
}

- (void)popViewController:(UIBarButtonItem *)item {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickedRightItem:(UIBarButtonItem *)sender {
    if (self.rightItemBlock) {
        id data = self.rightItemBlock();
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_ClickNav_Item object:data];
    }
}

- (void)clickedLeftItem:(UIBarButtonItem *)sender {
    if (self.leftItemBlock) {
        id data = self.leftItemBlock();
        [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_ClickNav_Item object:data];
    }
}

#pragma mark - UI创建
- (void)buildUI {
    [self addObserver:self forKeyPath:@"self.baseDataArray" options:NSKeyValueObservingOptionNew context:nil];
    self.view.backgroundColor = EC_Color_VCbg;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self configLeftBtnItem];
    [self configRightBtnItem];
}

#pragma mark - 背景图
- (void)showNothingView:(NSString *)nothingTitle {
    self.nothingView.hidden = NO;
    self.nothingView.nothingTitle = nothingTitle;
    [self.view bringSubviewToFront:self.nothingView];
}

- (void)hiddenNothingView{
    self.nothingView.hidden = YES;
}

#pragma mark - 懒加载
- (ECBaseBackgroundView *)nothingView{
    if(!_nothingView){
        _nothingView = [[ECBaseBackgroundView alloc] init];
        _nothingView.hidden = YES;
        [self.view addSubview:_nothingView];
        EC_WS(self)
        [_nothingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.view).offset(80);
            make.right.equalTo(weakSelf.view).offset(-70);
            make.top.equalTo(weakSelf.view).offset(200);
            make.bottom.equalTo(weakSelf.view).offset(-190);
        }];
    }
    return _nothingView;
}

- (NSMutableArray *)baseDataArray {
    if (!_baseDataArray) {
        _baseDataArray = [NSMutableArray array];
    }
    return _baseDataArray;
}
@end
