//
//  ECGiftView.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 2017/6/21.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "ECGiftView.h"
#import "LiveChatRoomBaseModel.h"

#define footH 44.0f
#define EC_LIVE_COLU 4

@interface ECLiveChatGiftBtn : UIButton
@property (nonatomic, strong) UILabel *priceL;
@property (nonatomic, strong) UILabel *numL;
@end

@implementation ECLiveChatGiftBtn

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _priceL = [[UILabel alloc] init];
        _priceL.text = @"99";
        _priceL.textColor = [UIColor whiteColor];
        _priceL.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_priceL];
        
        _numL = [[UILabel alloc] init];
        _numL.textColor = [UIColor whiteColor];
        _numL.textAlignment = NSTextAlignmentRight;
        [self addSubview:_numL];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.priceL.frame = CGRectMake(20, self.frame.size.height-44.0f, (self.frame.size.width-20*2), 44.0f);
    self.numL.frame = CGRectMake(20, 5, self.frame.size.width-30, 34.0f);
}
@end

@interface HeaderView : UIView
@property (nonatomic, strong) UIButton *exitBtn;
@end

@implementation HeaderView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepareUI];
        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}

- (void)prepareUI {
    _exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_exitBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self addSubview:_exitBtn];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    __weak typeof(self)weakSelf = self;
    [_exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf).offset(-10.0f);
        make.width.offset(35.0f);
        make.height.offset(35.0f);
        make.centerY.equalTo(weakSelf.mas_centerY);
    }];
}
@end

@interface FootView : UIView
@property (nonatomic, strong) UIButton *sendBtn;
@end

@implementation FootView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepareUI];
    }
    return self;
}

- (void)prepareUI {
    _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [_sendBtn setTitle:@"发送" forState:UIControlStateHighlighted];
    [_sendBtn setBackgroundColor:[UIColor colorWithRed:27/255.0f green:209/255.0f blue:188/255.0f alpha:1.0f]];
    _sendBtn.layer.cornerRadius = 5.0f;
    _sendBtn.layer.masksToBounds = YES;
    [self addSubview:_sendBtn];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    __weak typeof(self)weakSelf = self;
    [_sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(0.0f);
        make.bottom.equalTo(weakSelf).offset(-5.0f);
        make.right.equalTo(weakSelf).offset(-20.0f);
        make.width.offset(120.0f);
    }];
}
@end

@interface ECGiftView ()<UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *giftLists;
@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) FootView *footView;
@property (nonatomic, strong) ECLiveChatGiftBtn *oldBtn;
@end

@implementation ECGiftView
{
    UIButton *_selectBtn;
    NSInteger _count;
}

+ (instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static ECGiftView *cls = nil;
    dispatch_once(&onceToken, ^{
        cls = [[[self class] alloc] init];
    });
    return cls;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithHex:0x050506 alpha:0.6];
        _giftLists = [NSMutableArray array];
        [_giftLists addObjectsFromArray:@[@"520",@"fly",@"paoche",@"qiqiu",@"wen",@"bangbangtang",@"baoxiang",@"feiji",@"jiezhi", @"loveheart",@"redrose",@"tiantianquan",@"ttq",@"yinghua",@"zuanshi"]];
    }
    return self;
}

- (void)setDefaultArray:(NSArray *)array {
    if (self.giftLists.count>0 && array.count>0) {
        [_giftLists removeAllObjects];
        [_giftLists addObjectsFromArray:array];
    }
}

- (void)buildUi {
    if (_scrollview) return;
    [self addSubview:self.scrollview];
    [self addSubview:self.footView];
    [self addSubview:self.pageControl];
    
    NSInteger count = self.giftLists.count;
    NSInteger row = 2;
    NSInteger page = count/(row*EC_LIVE_COLU)+1;
    CGFloat w = EC_kScreenW/EC_LIVE_COLU;
    CGFloat h = (EC_LIVEROOM_GiftViewH-footH-10*3)/row-0.3;
    _scrollview.contentSize = CGSizeMake(EC_kScreenW*page, EC_LIVEROOM_GiftViewH-footH-10*3);
    _pageControl.numberOfPages = page;
    
    for (NSInteger i=0; i<count; i++) {
        ECLiveChatGiftBtn *btn = [[ECLiveChatGiftBtn alloc] init];
        [btn setImage:[UIImage imageNamed:self.giftLists[i]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:self.giftLists[i]] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(giftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.borderColor = [UIColor colorWithRed:39/255.0f green:39/255.0f blue:49/255.0f alpha:1.0f].CGColor;
        btn.layer.borderWidth = 0.2f;
        btn.tag = i;
        btn.titleLabel.text = self.giftLists[i];
        btn.titleLabel.hidden = YES;
        [self.scrollview addSubview:btn];
        
        NSInteger pageI = i/(row*EC_LIVE_COLU);
        CGFloat r = (i/EC_LIVE_COLU)%row;
        CGFloat v = i%EC_LIVE_COLU;
        
        btn.frame = CGRectMake(v*w+pageI*EC_kScreenW,r*h, w, h);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    __weak typeof(self)weakSelf = self;
    [self.footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(weakSelf).offset(0);
        make.width.offset(EC_kScreenW);
        make.height.offset(footH);
    }];
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf.footView.mas_top).offset(-10.0f);
        make.height.offset(10.0f);
    }];

    [_scrollview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf).offset(0);
        make.left.and.right.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf.pageControl.mas_top).offset(-10.0f);
    }];

}

- (void)animationWithView:(UIView *)superView {
    [self buildUi];
    
    self.frame = CGRectMake(0, EC_kScreenH-EC_LIVEROOM_GiftViewH, EC_kScreenW, EC_LIVEROOM_GiftViewH);
    [superView addSubview:self];
    
    CAKeyframeAnimation *ani = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    ani.values = @[@(EC_kScreenH),@(EC_kScreenH-EC_LIVEROOM_GiftViewH/2)];
    ani.duration = 0.25;
    ani.removedOnCompletion = NO;
    ani.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:ani forKey:@"giftpostion"];
}

- (void)sendBtnClick:(UIButton *)sender {

    NSString *text = nil;
    NSString *userData = nil;
    if ([_selectBtn.titleLabel.text isEqualToString:@"paoche"]) {
        text = [NSString stringWithFormat:@"我送了%d个跑车",(int)_count];
        userData = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{EC_LiveRoom_SendRacingCarGift:_selectBtn.titleLabel.text} options:0 error:nil] encoding:NSUTF8StringEncoding];;

    } else if ([_selectBtn.titleLabel.text isEqualToString:@"520"] || [_selectBtn.titleLabel.text isEqualToString:@"fly"] || [_selectBtn.titleLabel.text isEqualToString:@"lanseyaoji"] || [_selectBtn.titleLabel.text isEqualToString:@"wen"] || [_selectBtn.titleLabel.text isEqualToString:@"qiqiu"]) {
        text = [NSString stringWithFormat:@"我送了%d个爱心",(int)_count];
        userData = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{EC_LiveRoom_SendLoveGift:_selectBtn.titleLabel.text} options:0 error:nil] encoding:NSUTF8StringEncoding];;
    } else if(_selectBtn.titleLabel.text.length>0) {
        text = [NSString stringWithFormat:@"我送了%d个其他礼物",(int)_count];
        userData = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{EC_LiveRoom_SendOtherGift:_selectBtn.titleLabel.text} options:0 error:nil] encoding:NSUTF8StringEncoding];;
    } else {
        return;
    }
    
    ECTextMessageBody *msgBody = [[ECTextMessageBody alloc] initWithText:text];
    ECMessage *msg = [[ECMessage alloc] initWithReceiver:[LiveChatRoomBaseModel sharedInstanced].roomModel.roomId body:msgBody];
    msg.userData = userData;
    msg = [[ECDeviceHelper sharedInstanced] ec_sendLiveChatRoomMessage:msg];
    [self switchDefault];
}

- (void)giftBtnClicked:(ECLiveChatGiftBtn *)sender {
    
    _selectBtn = sender;
    if (_oldBtn!=sender) {
//        sender.layer.borderColor = [UIColor colorWithRed:27/255.0f green:209/255.0f blue:188/255.0f alpha:1.0f].CGColor;
//        sender.layer.borderWidth = 0.5;
//        _oldBtn.layer.borderColor = [UIColor colorWithRed:39/255.0f green:39/255.0f blue:49/255.0f alpha:1.0f].CGColor;
//        _oldBtn.layer.borderWidth = 0.2f;
        _oldBtn.numL.text = @"";
        _oldBtn = sender;
        _count = 1;
    } else {
//        sender.layer.borderColor = [UIColor colorWithRed:39/255.0f green:39/255.0f blue:49/255.0f alpha:1.0f].CGColor;
//        sender.layer.borderWidth = 0.2f;
//        _oldBtn = nil;
        if (_count>=30) {
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"礼物数量最多发送三十个" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
            return;
        }
        _count ++;
    }
    sender.numL.text = [NSString stringWithFormat:@"x%d",(int)_count];
}

- (void)switchDefault {
//    _oldBtn.layer.borderColor = [UIColor colorWithRed:39/255.0f green:39/255.0f blue:49/255.0f alpha:1.0f].CGColor;
//    _oldBtn.layer.borderWidth = 0.2f;
    _oldBtn.numL.text = @"";
    _count = 1;
    _oldBtn = nil;
    [self removeFromSuperview];
}
#pragma mark - 懒加载

- (UIScrollView *)scrollview {
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc] init];
        _scrollview.delegate = self;
        _scrollview.pagingEnabled = YES;
        _scrollview.contentSize = CGSizeMake(EC_kScreenW, EC_LIVEROOM_GiftViewH);
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.layer.borderWidth = 0.3;
        _scrollview.layer.borderColor = [UIColor colorWithRed:39/255.0f green:39/255.0f blue:49/255.0f alpha:1.0f].CGColor;
    }
    return _scrollview;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.numberOfPages = self.giftLists.count/6 +1;
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    }
    return _pageControl;
}

- (FootView *)footView {
    if (!_footView) {
        _footView = [[FootView alloc] init];
        [_footView.sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _footView;
}
@end
