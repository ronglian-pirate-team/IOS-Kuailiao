//
//  ECCallOpenView.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/11.
//
//

#import "ECCallOpenView.h"

@interface ECCallOpenView()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation ECCallOpenView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self buildUI];
    }
    return self;
}

- (void)time:(NSInteger)second{
    NSInteger sec = second % 60;
    NSInteger min = second / 60;
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", min, sec];
}

- (void)setImageName:(NSString *)imageName{
    self.imageView.image = EC_Image_Named(imageName);
}

- (void)setCallType:(CallType)callType{
    _callType = callType;
    if(callType == VIDEO){
        self.timeLabel.hidden = YES;
        self.imageView.hidden = YES;
    }
}

- (void)setStatus:(NSString *)status{
    self.timeLabel.text = status;
}

- (void)buildUI{
    [self addSubview:self.imageView];
    [self addSubview:self.timeLabel];
    EC_WS(self)
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf);
        make.left.equalTo(weakSelf).offset(20);
        make.right.equalTo(weakSelf).offset(-20);
        make.height.mas_equalTo(weakSelf.imageView.mas_width).multipliedBy(1);
        make.top.equalTo(weakSelf).offset(10);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf);
        make.top.equalTo(weakSelf.imageView.mas_bottom).offset(2);
    }];
}

- (UIImageView *)imageView{
    if(!_imageView){
        _imageView = [[UIImageView alloc] init];
        _imageView.image = EC_Image_Named(@"workbenchIconYuyin2");
    }
    return _imageView;
}

- (UILabel *)timeLabel{
    if(!_timeLabel){
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = EC_Color_White;
        _timeLabel.font = EC_Font_System(10);
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.text = @"等待中";
    }
    return _timeLabel;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint curP = [touch locationInView:self];
    CGPoint preP = [touch previousLocationInView:self];
    CGFloat offsetX = curP.x - preP.x;
    CGFloat offsetY = curP.y - preP.y;
    self.transform = CGAffineTransformTranslate(self.transform, offsetX, offsetY);
    if(self.touchMove)
        self.touchMove(self.frame);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(!self.touchMoveEnd)
        return;
    CGFloat w = self.superview.ec_width;
    CGFloat h = self.superview.ec_height;
    CGFloat y = (self.ec_y < 0 ? 0 : (self.ec_y + self.ec_height > h ? h - self.ec_height : self.ec_y));
    if(self.ec_x + self.ec_width / 2 <= w / 2){
        self.touchMoveEnd(0, y);
    }else{
        self.touchMoveEnd(w - self.ec_width, y);
    }
}

@end
