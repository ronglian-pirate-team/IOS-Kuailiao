//
//  ECInviteBottomView.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/27.
//
//

#import <UIKit/UIKit.h>

@interface ECInviteBottomView : UIView

@property (nonatomic, assign) NSInteger selectCount;
@property (nonatomic, copy) void (^createGroup)();
@property (nonatomic, copy) NSString *operationTitle;

@end
