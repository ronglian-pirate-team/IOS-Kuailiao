//
//  ECFriendNoticeMsg+ECUtil.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/2.
//
//

#import "ECFriendNoticeMsg+ECUtil.h"
#import <objc/runtime.h>

@implementation ECFriendNoticeMsg (ECUtil)

const char ec_friend_nickName;

- (void)setNickName:(NSString *)nickName {
    objc_setAssociatedObject(self, &ec_friend_nickName, nickName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)nickName {
    NSString *nickN = objc_getAssociatedObject(self, &ec_friend_nickName);
    if (nickN.length==0)
        nickN = self.sender;
    return nickN;
}
@end
