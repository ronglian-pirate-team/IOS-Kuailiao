//
//  ECChatVoiceItemView.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/2.
//
//

#import <UIKit/UIKit.h>
#import "ECChatVoiceBottomView.h"

@interface ECChatVoiceItemView : UIView

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *selectImageName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) ECChatVoiceType voiceType;

- (void)addTarget:(id)target action:(SEL)sel forControlEvents:(UIControlEvents)event;
- (void)hiddenHelperView;
- (void)showHelperView;

@end
