//
//  ECInputToolView.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/2.
//
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

typedef NS_ENUM(NSInteger, ECInputToolStatus) {
    ECInputToolStatus_Normal,//非编辑状态
    ECInputToolStatus_TextEditing,//输入文字
    ECInputToolStatus_Voice,//录音
    ECInputToolStatus_Face, //表情
    ECInputToolStatus_More //更多
};

@protocol ECInputToolViewDelegate <NSObject>

- (void)inputViewStatusChange:(ECInputToolStatus)status fromeStatus:(ECInputToolStatus)fromStatus;

- (void)inputToolView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height;

@end

@interface ECInputToolView : UIView

@property (nonatomic, weak) id<ECInputToolViewDelegate> delegate;
@property (nonatomic, strong) HPGrowingTextView *inputTextView;

@property (nonatomic, assign) ECInputToolStatus status;

@property (nonatomic, copy) NSString *receiver;

@end
