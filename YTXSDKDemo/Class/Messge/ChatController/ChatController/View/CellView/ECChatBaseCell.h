//
//  ECChatBaseCell.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/3.
//
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "ECMessage+ECUtil.h"

#define EC_CHAT_CELL_V_Other 59.0f
#define EC_CHAT_CELL_H_Other 60.0f
#define EC_CHAT_TIMEL_H 9.5f
#define EC_CHAT_BGCONTENT_ANGLE_W 8.0f
#define EC_CHAT_CELL_V_OtherCell 40.5

extern const char EC_ChatCell_KTimeIsShowKey;

@interface ECChatBaseCell : UITableViewCell
{
    UIMenuController*  _menuController;
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    UIMenuItem *_transmitMenuItem;
    UIMenuItem *_shareMenuItem;
    UIMenuItem *_revokeMenuItem;
}

@property (nonatomic, strong) UIView *bgContentView;
@property (nonatomic, strong) UIImageView *bgContenImgV;

@property (nonatomic, strong) ECMessage *message;
- (void)updateChildUI;

@end

