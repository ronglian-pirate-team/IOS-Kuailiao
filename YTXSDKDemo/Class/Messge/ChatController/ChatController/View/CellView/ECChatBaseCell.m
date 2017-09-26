//
//  ECChatBaseCell.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/3.
//
//

#import "ECChatBaseCell.h"
#import "ECChatClickCellTool.h"
#import "ECChatBaseCell+LongPress.h"
#import "ECChatFetchModel.h"
#import "ECCellHeightModel.h"

#define EC_CHAT_TIME_MARGIN 60.0f
#define EC_CHAT_BGCONTENT_MARGIN 60.0f
#define EC_CHAT_PORTRAIT_MARGIN 29.0f
#define EC_CHAT_PORTRAIT_WH 40.0f
#define EC_CHAT_PORTRAIT_LEFT 12.0f
#define EC_CHAT_READL_W 120.0f
#define EC_CHAT_READL_H 10.5f
#define EC_CHAT_SENDSTATUS_WH 30.0f

const char EC_ChatCell_KTimeIsShowKey;

@interface ECChatBaseCell ()
@property (nonatomic, strong) UILabel *timeL;
@property (nonatomic, strong) UIImageView *protraitImgV;
@property (nonatomic, strong) UILabel *readL;
@property (nonatomic, strong) UIView *sendStatusView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIButton *resendBtn;
@end

@implementation ECChatBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildUI];
    }
    return self;
}

#pragma mark - 事件
- (void)tapPortraitEvent:(UIGestureRecognizer *)gesture {
    EC_Demo_AppLog(@"%s",__func__);
    [[ECChatClickCellTool sharedInstanced] ec_Click_ChatCelltapPortraitEventWithMessage:self.message];
}

- (void)tapContentBgEvent:(UIGestureRecognizer *)gesture {
    EC_Demo_AppLog(@"%@--%s",self.message.messageBody,__func__);
    [[ECChatClickCellTool sharedInstanced] ec_Click_ChatCellEventWithMessage:self.message];
}

- (void)resendBtnTap:(UIButton *)sender {
    [self resendMessage];
}

- (void)tapReadLEvent:(UIGestureRecognizer *)gesture {
    if ([self.message.sessionId hasPrefix:@"g"]) {
        EC_Demo_AppLog(@"%s",__func__);
        [[ECChatClickCellTool sharedInstanced] ec_Click_ChatCelltapReadLEventWithMessage:self.message];
    }
}
#pragma mark - 长按cell
- (void)cellHandleLongPress:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        EC_Demo_AppLog(@"%s",__func__);
        [self becomeFirstResponder];
        [self showMenuViewController:self.bgContentView message:self.message];
    }
}

#pragma mark - 设置数据源
- (void)setMessage:(ECMessage *)message {
    _message = message;
    
    [self addMainContentUI];
    [self getCellHeight];
    [self updateChildUI];
}

#pragma mark - 计算高度
- (void)getCellHeight {
    CGFloat height = self.message.cellHeight;
    if (height)
        return;
    self.message = [ECCellHeightModel ec_caculateCellSizeWithMessage:self.message];
}

#pragma mark - 更新cell的Frame

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat bgconten_w = self.message.cellWidth - EC_CHAT_CELL_H_Other;
    CGFloat portrait_x = EC_CHAT_PORTRAIT_LEFT;
    CGFloat bgcontent_x = EC_CHAT_BGCONTENT_MARGIN;
    if (self.message.messageState != ECMessageState_Receive) {
        portrait_x = EC_kScreenW - EC_CHAT_PORTRAIT_LEFT - EC_CHAT_PORTRAIT_WH;
        bgcontent_x = EC_kScreenW - EC_CHAT_BGCONTENT_MARGIN - bgconten_w;
    }
    //是否显示时间
    BOOL isHiddenTimeL = ![objc_getAssociatedObject(self.message, &EC_ChatCell_KTimeIsShowKey) boolValue];
    CGFloat timeL_V = isHiddenTimeL?0:EC_CHAT_TIMEL_H;
    _timeL.hidden = isHiddenTimeL;
    
    self.timeL.frame = (CGRect){
        EC_CHAT_TIME_MARGIN,
        5.0f,
        EC_kScreenW - EC_CHAT_TIME_MARGIN * 2,
        timeL_V
    };
    if ([ECMessage ExtendTypeOfTextMessage:self.message] != EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_RedpacketTakenTip && ![self.message.messageBody isKindOfClass:[ECRevokeMessageBody class]]) {
        
        _protraitImgV.frame = (CGRect){
            portrait_x,
            CGRectGetMaxY(self.timeL.frame) + EC_CHAT_PORTRAIT_MARGIN,
            EC_CHAT_PORTRAIT_WH,
            EC_CHAT_PORTRAIT_WH
        };
        _protraitImgV.ec_radius = _protraitImgV.ec_width / 2;
        _bgContentView.frame = (CGRect){
            bgcontent_x,
            CGRectGetMinY(_protraitImgV.frame),
            bgconten_w,
            self.message.cellHeight - EC_CHAT_CELL_V_Other
        };
        _readL.frame = (CGRect){
            CGRectGetMinX(_bgContentView.frame) + (_bgContentView.ec_width - EC_CHAT_READL_W)/2,
            CGRectGetMaxY(_bgContentView.frame) + 5,
            EC_CHAT_READL_W,
            EC_CHAT_READL_H
        };
        if ([ECMessage validSendMessage:self.message]) {
            self.sendStatusView.frame = (CGRect){
                CGRectGetMinX(self.bgContentView.frame) - EC_CHAT_SENDSTATUS_WH - 10.0f,
                (CGRectGetMinY(self.bgContentView.frame) +  CGRectGetMaxY(self.bgContentView.frame) - EC_CHAT_SENDSTATUS_WH)/2,
                EC_CHAT_SENDSTATUS_WH,
                EC_CHAT_SENDSTATUS_WH
            };
        }
        _bgContenImgV.frame = _bgContentView.bounds;
    } else {
        [self.readL removeFromSuperview];
        self.bgContenImgV.hidden = YES;
        _bgContentView.frame = (CGRect){
            (EC_kScreenW - self.message.cellWidth) / 2,
            CGRectGetMaxY(_timeL.frame) + 10.0f,
            self.message.cellWidth,
            self.message.cellHeight - EC_CHAT_CELL_V_OtherCell
        };
    }
}

#pragma mark - UI创建
- (void)buildUI {
    [self.contentView addSubview:self.timeL];
    [self.contentView addSubview:self.bgContentView];
}

- (void)addMainContentUI {
    _timeL.text = [NSString dateTime:self.message.timestamp.longLongValue];
    if ([ECMessage ExtendTypeOfTextMessage:self.message] != EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_RedpacketTakenTip && ![self.message.messageBody isKindOfClass:[ECRevokeMessageBody class]]) {
        [self.contentView addSubview:self.protraitImgV];
        [self.bgContentView addSubview:self.bgContenImgV];
    }
    
    if ([ECMessage ExtendTypeOfTextMessage:self.message] != EC_Demo_CAHT_MESSAGE_CUSTOMTYPE_RedpacketTakenTip) {
        
        if (![ECMessage validSendMessage:self.message]) {
            [_protraitImgV sd_setImageWithURL:[NSURL URLWithString:[ECCommonTool userAvatar:self.message.from]] placeholderImage:EC_Image_Named(@"messageIconHeader")];
//            _protraitImgV.image = [UIImage ec_circleImageWithColor:EC_Color_ChatReceiveView_Bg
//                                                              withSize:CGSizeMake(EC_CHAT_PORTRAIT_WH, EC_CHAT_PORTRAIT_WH) withName:@"其他"];
            _bgContenImgV.image = [EC_Image_Named(@"liaotianQipaoWhite") stretchableImageWithLeftCapWidth:33.0f topCapHeight:33.0f];
            
        } else {
            UIImage *image = [UIImage ec_circleImageWithColor:EC_Color_ChatSendView_Bg withSize:CGSizeMake(EC_CHAT_PORTRAIT_WH, EC_CHAT_PORTRAIT_WH) withName:@"我"];
            [_protraitImgV sd_setImageWithURL:[NSURL URLWithString:[ECDevicePersonInfo sharedInstanced].avatar] placeholderImage:image];
//            _protraitImgV.image = [UIImage ec_circleImageWithColor:EC_Color_ChatSendView_Bg
//                                                       withSize:CGSizeMake(EC_CHAT_PORTRAIT_WH, EC_CHAT_PORTRAIT_WH) withName:@"我"];
            _bgContenImgV.image = [EC_Image_Named(@"liaotianQipaoBlue") stretchableImageWithLeftCapWidth:33.0f topCapHeight:33.0f];
            [self.contentView addSubview:self.sendStatusView];
            [self.contentView addSubview:self.readL];
        }
    }
}

- (void)updateChildUI {
    if ([ECMessage validSendMessage:self.message]) {
        [self updateSendState];
        NSString *readStr = @"未读";
        if ([self.message.sessionId hasPrefix:@"g"]) {
            if (!self.message.isRead && self.message.readCount==0) {
                self.message.readCount = [ECAppInfo sharedInstanced].sessionMgr.session.memberCount;
                [[ECMessageDB sharedInstanced] updateMessageReadCount:self.message.sessionId messageId:self.message.messageId readCount:self.message.readCount];
            }
            readStr = [NSString stringWithFormat:@"(%d)%@",(int)self.message.readCount,@"未读"];
        }
        if (self.message.readCount == 0 && self.message.isRead)
            readStr = @"已读";
        self.readL.text = readStr;
    }
    EC_Demo_AppLog(@"%@--%f-%f",self.message.messageBody, self.message.cellWidth,self.message.cellHeight);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView * view = [super hitTest:point withEvent:event];
    CGPoint readPoint = [self.readL convertPoint:point fromView:self.contentView];
    if (CGRectContainsPoint(self.readL.bounds, readPoint))
        view = self.readL;
    return view;
}
#pragma mark - 更新发送状态
- (void)updateSendState {
    ECMessageState state = self.message.messageState;
    switch (state) {
        case ECMessageState_Sending: {
            [_activityView startAnimating];
            _activityView.hidden = NO;
        }
            break;
        case ECMessageState_SendSuccess: {
            [_activityView stopAnimating];
            [_sendStatusView removeFromSuperview];
        }
            break;
        case ECMessageState_SendFail: {
            [_activityView stopAnimating];
            _activityView.hidden = YES;
        }
            break;
        case ECMessageState_Receive: {
            [self.sendStatusView removeFromSuperview];
        }
            break;
        default:
            break;
    }
    self.resendBtn.hidden = (state == ECMessageState_SendFail)?NO:YES;
}
#pragma mark - 懒加载
- (UILabel *)timeL {
    if (!_timeL) {
        _timeL = [[UILabel alloc] init];
        _timeL.textAlignment = NSTextAlignmentCenter;
        _timeL.font = EC_Font_System(12);
        _timeL.textColor = EC_Color_Gray;
        _timeL.hidden = YES;
    }
    return _timeL;
}

- (UIImageView *)protraitImgV {
    if (!_protraitImgV) {
        _protraitImgV = [[UIImageView alloc] init];
        _protraitImgV.userInteractionEnabled = YES;
        _protraitImgV.contentMode = UIViewContentModeScaleAspectFill;
        [_protraitImgV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPortraitEvent:)]];
    }
    return _protraitImgV;
}

- (UIView *)bgContentView {
    if (!_bgContentView) {
        _bgContentView = [[UIView alloc] init];
        [_bgContentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContentBgEvent:)]];
        [_bgContentView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellHandleLongPress:)]];
    }
    return _bgContentView;
}

- (UIImageView *)bgContenImgV {
    if (!_bgContenImgV) {
        _bgContenImgV = [[UIImageView alloc] init];
        _bgContenImgV.userInteractionEnabled = YES;
        _bgContenImgV.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _bgContenImgV;
}

- (UILabel *)readL {
    if (!_readL) {
        _readL = [[UILabel alloc] init];
        _readL.font = EC_Font_System(11.0f);
        _readL.textColor = EC_Color_ChatReadMessageView_Bg;
        _readL.textAlignment = NSTextAlignmentCenter;
        _readL.text = NSLocalizedString(@"对方未读", nil);
        [_readL addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReadLEvent:)]];
    }
    return _readL;
}

- (UIView *)sendStatusView {
    if (!_sendStatusView) {
        _sendStatusView = [[UIView alloc] init];
        _sendStatusView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin;
        _sendStatusView.backgroundColor = self.backgroundColor;
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_sendStatusView addSubview:self.activityView];
        self.activityView.backgroundColor = [UIColor clearColor];
        
        self.resendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendStatusView addSubview:self.resendBtn];
        self.resendBtn.frame = CGRectMake(0, 0, 28, 28);
        self.resendBtn.hidden = YES;
        [self.resendBtn setImage:EC_Image_Named(@"messageSendFailed") forState:UIControlStateNormal];
        [self.resendBtn addTarget:self action:@selector(resendBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendStatusView;
}

@end
