//
//  ECChatMoreView.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/2.
//
//

#import <UIKit/UIKit.h>
#import "ECChatMoreItemView.h"

typedef NS_ENUM(NSInteger, ECChatMoreViewType) {
    ECChatMoreViewType_Personal,//个人即点对点
    ECChatMoreViewType_Group //群组、讨论组
};

@protocol ECChatMoreViewDelegate <NSObject>
@optional
- (void)chatMoreViewWithType:(ECChatMoreItemViewType)type;

@end

@interface ECChatMoreView : UIView

@property (nonatomic, weak) id<ECChatMoreViewDelegate> delegate;
@property (nonatomic, assign) ECChatMoreViewType type;
@property (nonatomic, copy) NSString *receiver;

@end
