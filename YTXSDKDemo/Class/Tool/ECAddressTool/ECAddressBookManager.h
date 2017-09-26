//
//  ECAddressBookManager.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/26.
//
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "ECAddressBook.h"

@interface ECAddressBookManager : NSObject

+(ECAddressBookManager *)sharedInstance;

/**
 @brief 获取通讯录中的所有联系人
 @return 联系人数组 addressBook
 */
- (NSArray *)allContacts;


/**
 @brief 联系人首字母获取，相同首字母的联系人存入同一数组

 @return 首字母对应联系人
 */
- (NSDictionary *)firstLetterContacts:(NSArray *)contacts;


/**
 @brief 新的好友中被推荐的人，随机12个

 @return 被推荐人数组
 */
- (NSArray *)recommendContacts;


/**
 @brief 搜索联系人

 @param text 搜索时输入文字
 @return 搜索结果
 */
- (NSArray *)searchContacts:(NSString *)text;

@end
