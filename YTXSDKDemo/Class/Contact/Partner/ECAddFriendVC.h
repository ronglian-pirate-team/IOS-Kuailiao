//
//  ECAddFriendVC.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/26.
//
//

#import "ECBaseContoller.h"

@interface ECAddFriendVC : ECBaseContoller

@property (nonatomic, assign) int isEditing;// 0 新的好友，即添加好友   1 创建群组并邀请  2 邀请加入已存在的群组  3实时对讲邀请
@property (nonatomic, copy) NSString *groupId;// 当isEditing = 2时，有值
@property (nonatomic, copy) NSString *groupDeclared;//群公告
@property (nonatomic, copy) NSString *selectProvince;//选择省份
@property (nonatomic, copy) NSString *selectCity;//选择城市
@property (nonatomic, assign) ECGroupPermMode groupMode;//群组权限
@property (nonatomic, copy) NSString *groupName;//群名称
@property (nonatomic, assign) NSInteger type;//群组类型
@property (nonatomic, strong) NSArray *firstLetters;
@property (nonatomic, strong) NSDictionary *firstLetterDic;

@property (nonatomic, assign) BOOL isDiscuss;

@end
