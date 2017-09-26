//
//  CustomEmojiView.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/18.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "CustomEmojiView.h"

#define EXPRESSION_SCROLL_VIEW_TAG 100
#define pagecontrolW 120.0f
#define pagecontrolH 20.0f
#define emojiViewH 236.0f
#define footViewH 40.0f

@interface EmojiFootView : UIView
@property (nonatomic, strong) UIButton *sendBtn;
@end

@implementation EmojiFootView
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
    [_sendBtn setBackgroundImage:[[UIImage imageNamed:@"common_resizable_blue_N"] stretchableImageWithLeftCapWidth:6 topCapHeight:20] forState:UIControlStateNormal];
    [_sendBtn setBackgroundImage:[[UIImage imageNamed:@"common_resizable_blue_H"] stretchableImageWithLeftCapWidth:6 topCapHeight:20]forState:UIControlStateHighlighted];
    [_sendBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:_sendBtn.currentTitle attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f],NSForegroundColorAttributeName:[UIColor blackColor]}] forState:UIControlStateNormal];
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

@interface CustomEmojiView()<UIScrollViewDelegate>
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) EmojiFootView *footView;
@property (nonatomic, strong) UIPageControl *pageCtrl;
@property (nonatomic, strong) NSArray *defaultArray;
@property (nonatomic, assign) CGFloat emojiH;
@end

@implementation CustomEmojiView
{
    UIScrollView  *_pageScroll;
}

+ (CustomEmojiView*)shardInstance{
    static dispatch_once_t emojiviewOnce;
    static CustomEmojiView *cutomemojiview;
    dispatch_once(&emojiviewOnce, ^{
        cutomemojiview = [[CustomEmojiView alloc] init];
    });
    return cutomemojiview;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, EC_kScreenW, emojiViewH);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillChangeFame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

- (void)setEmojiH:(CGFloat)emojiH {
    _emojiH = emojiH;
    self.frame = CGRectMake(0, 0, EC_kScreenW, _emojiH);
}

- (void)keyBoardWillChangeFame:(NSNotification *)noti {
    CGFloat keyH = [[noti.userInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    if (self.emojiH != keyH ) {
        for (UIView *view in self.subviews) {
            [view removeFromSuperview];
        }
        self.emojiH = keyH;
        [self buildEmojiUi];
    }
}

- (void)setDefaultEmojiArray:(NSArray<NSString *> *)emojiArray {
    _defaultArray = emojiArray;
}

- (void)buildEmojiUi {
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.backgroundColor = [UIColor clearColor];
    
    NSInteger pageCount = self.defaultArray.count/(4*7) +1;
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, EC_kScreenW, self.ec_height-pagecontrolH-footViewH)];
    scrollView.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
    scrollView.tag = EXPRESSION_SCROLL_VIEW_TAG;
    _pageScroll = scrollView;
    _pageScroll.scrollsToTop = NO;
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width*pageCount, scrollView.frame.size.height);
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    _pageCtrl.numberOfPages = pageCount;
    
    int row = 4;
    int column = 7;
    int number = 0;
    CGFloat emojiW = 40.0f;
    CGFloat emojiH = 30.0f;
    CGFloat marginH = (EC_kScreenW -column*emojiW)/(column+1);
    CGFloat marginV = (self.ec_height-pagecontrolH-footViewH-row*emojiH)/(row+1);
    for (int p=0; p<pageCount; p++)
    {
        NSInteger page_X = p*scrollView.frame.size.width;
        for (int j=0; j<row; j++)
        {
            NSInteger row_y = marginV*(j+1)+emojiH*j;
            for (int i=0; i<column; i++)
            {
                NSInteger column_x = marginH*(i+1)+emojiW*i;
                if (number > 170)
                {
                    break;
                }
                
                if (j!=row-1 || i!=column-1)
                {
                    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(page_X+column_x, row_y, emojiW, emojiH)];
                    btn.tag = number;
                    btn.backgroundColor = [UIColor clearColor];
                    [btn setTitle:_defaultArray[number] forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(putExpress:) forControlEvents:UIControlEventTouchUpInside];
                    [scrollView addSubview:btn];
                    number++;
                }
            }
        }
        
        UIButton* delBtn = [[UIButton alloc] initWithFrame:CGRectMake(page_X+marginH*column+(column-1)*emojiW, marginV*row+(row-1)*emojiH, emojiW, emojiH)];
        delBtn.backgroundColor = [UIColor clearColor];
        [delBtn setImage:[UIImage imageNamed:@"emoji_delete_pressed"] forState:UIControlStateHighlighted];
        [delBtn setImage:[UIImage imageNamed:@"emoji_delete"] forState:UIControlStateNormal];
        [delBtn addTarget:self action:@selector(backspaceText:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:delBtn];
    }
    
    [self addSubview:scrollView];
    [self addSubview:self.footView];
    [self addSubview:self.pageCtrl];
    [_footView.sendBtn addTarget:self action:@selector(emojiSendBtn:) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - 基本方法
- (void)layoutSubviews {
    [super layoutSubviews];
    
    __weak typeof(self)weakSelf = self;
    [self.footView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(weakSelf).offset(0);
        make.width.offset(EC_kScreenW);
        make.height.offset(footViewH);
    }];
    
    [self.pageCtrl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(weakSelf);
        make.bottom.equalTo(weakSelf.footView.mas_top).offset(-10.0f);
        make.height.offset(10.0f);
    }];
}

- (UIPageControl *)pageCtrl {
    if (!_pageCtrl) {
        _pageCtrl = [[UIPageControl alloc] init];
        _pageCtrl.numberOfPages = self.defaultArray.count/(4*7) +1;
        _pageCtrl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageCtrl.pageIndicatorTintColor = [UIColor grayColor];
        _pageCtrl.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1];
        [_pageCtrl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    }
    return _pageCtrl;
}

- (EmojiFootView *)footView {
    if (!_footView) {
        _footView = [[EmojiFootView alloc] init];
    }
    return _footView;
}

#pragma mark -
- (void)switchToDefaultKeyboard {
    if (_textView) {
        _textView.inputView = nil;
        [_textView reloadInputViews];
        _textView = nil;
    }
}

- (void)attachEmotionKeyboardTo:(UIView *)view Input:(UITextView *)textView {
    _textView = (UITextView *)textView;
    if (!_textView.isFirstResponder) {
        [_textView becomeFirstResponder];
    }
    if (!_pageCtrl) {
        [self buildEmojiUi];
    }
    _textView.inputView = self;
    [_textView reloadInputViews];
    [_textView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSysKeyBoard)]];
}

- (void)putExpress:(id)sender{
    UIButton *button_tag = (UIButton *)sender;
    [_textView insertText:_defaultArray[button_tag.tag]];
} 

- (void)backspaceText:(id)sender{
    [_textView deleteBackward];
}

- (void)emojiSendBtn:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(emojiSendBtn:)]) {
        [self.delegate emojiSendBtn:sender];
    }
}

- (void)tapSysKeyBoard {
    [self switchToDefaultKeyboard];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapTextView)]) {
        [self.delegate tapTextView];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == EXPRESSION_SCROLL_VIEW_TAG)
    {
        //更新UIPageControl的当前页
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.frame;
        [_pageCtrl setCurrentPage:offset.x / bounds.size.width];
    }
}

- (void)pageTurn:(UIPageControl*)sender
{
    //令UIScrollView做出相应的滑动显示
    CGSize viewSize = _pageScroll.frame.size;
    CGRect rect = CGRectMake(sender.currentPage * viewSize.width, 0, viewSize.width, viewSize.height);
    [_pageScroll scrollRectToVisible:rect animated:YES];
}

@end
