//
//  ECChatTableView.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/3.
//
//

#import <UIKit/UIKit.h>

@class ECChatBaseCell;

@interface ECChatTableView : UIView

@property (nonatomic, strong) NSMutableArray *messageArray;

- (void)ec_chatScrollViewToBottom:(BOOL)animated;
@end
