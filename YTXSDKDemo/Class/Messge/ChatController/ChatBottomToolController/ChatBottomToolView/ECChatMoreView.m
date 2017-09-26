//
//  ECChatMoreView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/2.
//
//

#import "ECChatMoreView.h"
#import "ECChatMoreViewTool.h"

#define EC_ChatItem_W EC_kScreenW / 4
#define EC_ChatItem_H 92

@interface ECChatMoreView()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation ECChatMoreView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self buildUI];
    }
    return self;
}

- (void)setType:(ECChatMoreViewType)type{
    _type = type;
    [self configMoreView];
}

- (void)moreItemAction:(UIButton *)sender{
    ECChatMoreItemView *itemView = (ECChatMoreItemView *)sender.superview;
//    if([self.delegate respondsToSelector:@selector(chatMoreViewWithType:)])
//        [self.delegate chatMoreViewWithType:itemView.type];
    ECChatMoreViewTool *tool = [ECChatMoreViewTool sharedInstanced];
    tool.receiver = self.receiver;
    switch (itemView.type) {
        case ECChatMoreViewItemType_Photo:
            tool.isReadDeleteMessage = NO;
            [tool sendMessageSelectImages];
            break;
        case ECChatMoreViewItemType_Camera:
            tool.isReadDeleteMessage = NO;
            [tool sendMessageTakePicture];
            break;
        case ECChatMoreViewItemType_Video:
            [tool sendMessageTakeVideo];
            break;
        case ECChatMoreViewItemType_Location:
            [tool sendMessageSelectLocation];
            break;
        case ECChatMoreViewItemType_RedPackage:
            [tool sendMessageRedpacket];
            break;
        case ECChatMoreViewItemType_ReadBurn:
            tool.isReadDeleteMessage = YES;
            [tool sendMessageReadFire];
            break;
        case ECChatMoreViewItemType_ChatVoice:
            [tool takeCallVoice];
            break;
        case ECChatMoreViewItemType_ChatVideo:
            [tool takeCallVideo];
            break;
        default:
            break;
    }
}

#pragma mark - UI创建
- (void)buildUI{
    [self addSubview:self.scrollView];
    self.backgroundColor = EC_Color_White;
    EC_WS(self)
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf);
    }];
}

- (UIScrollView *)scrollView{
    if(!_scrollView){
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.backgroundColor = EC_Color_White;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl{
    if (!_pageControl) {
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        [self addSubview:pageControl];
        _pageControl = pageControl;
        _pageControl.hidesForSinglePage = YES;
        _pageControl.currentPageIndicatorTintColor = EC_Color_White;
        _pageControl.pageIndicatorTintColor = EC_Color_Gray;
//        [_pageControl addTarget:self action:@selector(pageControlAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageControl;
}

- (void)configMoreView{
    EC_WS(self)
    int count = ((self.type == ECChatMoreViewType_Personal && ![self.receiver isEqualToString:[ECDevicePersonInfo sharedInstanced].userName]) ? 7 : 4);
    for (int i = 0; i < count; i++) {
        ECChatMoreItemView *itemView = [[ECChatMoreItemView alloc] init];
        itemView.type = ECChatMoreViewItemType_Photo + i;
        [itemView addTarget:self action:@selector(moreItemAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:itemView];
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.offset(EC_ChatItem_W);
            make.height.offset(EC_ChatItem_H);
            make.left.equalTo(weakSelf).offset(EC_ChatItem_W * (i % 4));
            make.top.equalTo(weakSelf).offset(EC_ChatItem_H * (i / 4));
        }];
    }
}

@end
