//
//  ECChatMoreItemView.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/2.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ECChatMoreItemViewType) {
    ECChatMoreViewItemType_Photo,
    ECChatMoreViewItemType_Camera,
    ECChatMoreViewItemType_Video,
    ECChatMoreViewItemType_Location,
    ECChatMoreViewItemType_ReadBurn,
    ECChatMoreViewItemType_ChatVoice,
    ECChatMoreViewItemType_ChatVideo,
    ECChatMoreViewItemType_RedPackage
};


@interface ECChatMoreItemView : UIView

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) ECChatMoreItemViewType type;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
