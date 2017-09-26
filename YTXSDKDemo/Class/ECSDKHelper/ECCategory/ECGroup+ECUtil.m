//
//  ECGroup+ECUtil.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/7.
//

#import "ECGroup+ECUtil.h"
#import <objc/runtime.h>

const char ec_group_kselfrole;

@implementation ECGroup (ECUtil)

- (void)setSelfRole:(ECMemberRole)selfRole {
    objc_setAssociatedObject(self, &ec_group_kselfrole, @(selfRole), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ECMemberRole)selfRole {
    ECMemberRole role = (ECMemberRole)[objc_getAssociatedObject(self, &ec_group_kselfrole) integerValue];
    if ([self.owner isEqualToString:[ECDevicePersonInfo sharedInstanced].userName])
        role = ECMemberRole_Creator;
    return role?role:ECMemberRole_Member;
}
@end
