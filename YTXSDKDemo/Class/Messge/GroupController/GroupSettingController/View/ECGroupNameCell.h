//
//  ECGroupNameCell.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/27.
//
//

#import <UIKit/UIKit.h>

@interface ECGroupNameCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSString *placeholder;//默认“请输入”
@property (nonatomic, assign) BOOL secureTextEntry;//默认 NO
@property (nonatomic, assign) NSInteger maxLength;

@property (nonatomic, assign) BOOL isDiscuss;

@end
