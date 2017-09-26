//
//  ECCallOperationView.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/9.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ECCallOperationType) {
    ECCallOperationType_Microphone,//麦克风
    ECCallOperationType_Speaker,//扬声器
    ECCallOperationType_Camera,//摄像头
    ECCallOperationType_Exit//退出
};

@interface ECCallOperationView : UIView

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *selectImageName;

@property (nonatomic, assign) ECCallOperationType operationType;

- (instancetype)initWithImage:(NSString *)imageName title:(NSString *)title;
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
