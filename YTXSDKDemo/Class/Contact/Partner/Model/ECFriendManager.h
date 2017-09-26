//
//  ECFriendManager.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/21.
//
//

#import <Foundation/Foundation.h>

@interface ECFriendManager : NSObject

+ (instancetype)sharedInstanced;

#pragma mark - 获取个人信息
- (void)fetchPersonalInfoFromServer:(NSString *)friendId completion:(void (^)(ECFriend *friend))completion;;

#pragma mark - 获取指定好友信息
- (void)fetchFriendInfoFromServer:(NSString *)friendId completion:(void (^)(ECFriend *friend))completion;
- (ECFriend *)fetchFriendFromDB:(NSString *)friendId;

#pragma mark - 添加好友
- (void)addFriendWithAccount:(NSString *)account;

#pragma mark - 同意好友添加请求
- (void)agreeFrendAddRequest:(NSString *)useracc  completion:(void (^)(NSString *errCode, id responseObject))completion;

- (void)fetchFriendFromServer:(void (^)(NSMutableArray *friends))completion;
- (NSMutableArray *)fetchFriendFromDB;

#pragma mark - 修改好友备注
- (void)remarkFriend:(NSString *)friendId remarkName:(NSString *)remark completion:(void (^)())completion;

#pragma mark - 删除好友
- (void)deleteFriend:(NSString *)friendId;

#pragma mark - 上传头像
- (void)uploadImage:(UIImage *)image completion:(void (^)(NSString *errCode))completion;

#pragma mark - 获取用户隐私状态
- (void)fetchUserVerifyCompletion:(void (^)(NSString *errCode, id responseObject))completion;

- (NSDictionary *)firstLetterFriend:(NSArray *)friendArr;

- (NSArray *)firstLetters:(NSDictionary *)firstLetterDic;

- (NSMutableArray *)searchContacts:(NSString *)text;

@end
