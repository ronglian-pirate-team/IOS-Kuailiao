//
//  ECChatToolVC.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/2.
//
//

#import "ECBaseContoller.h"
#import "ECChatMoreView.h"

#define EC_InputView_H 50

@protocol ECChatToolDelegate <NSObject>

- (void)inputViewFrameChange:(CGFloat)y;

@end

@class ECChatVCModel;

@interface ECChatToolVC : ECBaseContoller

- (instancetype)initWithModel:(ECChatVCModel *)model;

@property (nonatomic, weak) id<ECChatToolDelegate> chatToolDelegate;
@property (nonatomic, strong) ECChatVCModel *chatVCModel;

@end

@interface ECChatVCModel : NSObject

@property (nonatomic, copy) NSString *receiver;
@property (nonatomic, strong) UIView *tableView;

@end
