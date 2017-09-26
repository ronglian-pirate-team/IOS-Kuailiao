//
//  ECFriend.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/21.
//
//

#import <Foundation/Foundation.h>

@interface ECFriend : NSObject

@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *friendState;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *remarkName;
@property (nonatomic, copy) NSString *useracc;
@property (nonatomic, copy) NSString *firstLetter;
@property (nonatomic, copy) NSString *birthDay;

@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, copy) NSString *sign;
@property (nonatomic, copy) NSString *age;
@property (nonatomic, assign) NSInteger sex;

- (NSString *)displayName;

@end
