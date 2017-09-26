//
//  ECCallOpenView.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/11.
//
//

#import <UIKit/UIKit.h>

@interface ECCallOpenView : UIView

@property (nonatomic, copy) void (^touchMove)(CGRect frame);
@property (nonatomic, copy) void (^touchMoveEnd)(CGFloat x, CGFloat y);

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *status;

@property (nonatomic, assign) CallType callType;

- (void)time:(NSInteger)second;

@end
