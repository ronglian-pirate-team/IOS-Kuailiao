//
//  ECSession.m
//  CCPiPhoneSDK
//
//  Created by wang ming on 14-12-10.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "ECSession.h"
#import "SDImageCache.h"

@interface ECSession ()
@end

@implementation ECSession

- (instancetype)initWithSessionId:(NSString *)sessionId {
    self = [super init];
    if (self) {
        self.sessionId = sessionId;
        self.type = EC_Session_Type_None;
        self.msgType = 0;
        self.text = @"";
        self.unreadCount = 0;
        self.sumCount = 0;
        self.isAt = NO;
        self.isTop = NO;
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp = [date timeIntervalSince1970]*1000;
        self.dateTime = (long long)tmp;
    }
    return self;
}

- (BOOL)isGroup {
    return [self.sessionId hasPrefix:@"g"];
}

- (NSInteger)memberCount {
    NSInteger count = 0;
    NSInteger count1 = [[[ECGroupMemberDB sharedInstanced] queryMembers:[ECSessionManger sharedInstanced].session.sessionId] count];
    NSInteger count2 = [[[ECGroupInfoDB sharedInstanced] selectGroupOfGroupId:[ECSessionManger sharedInstanced].session.sessionId] memberCount];
    count = MAX(_memberCount, MAX(count1, count2)) - 1;
    return count;
}

- (NSString *)avatar{
    ECFriend *friend = [[ECDBManager sharedInstanced].friendMgr queryFriend:self.sessionId];
    if(friend && EC_ValidateNullStr(friend.avatar))
        return friend.avatar;
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    if(friend.remarkName && friend.remarkName != nil && friend.remarkName.length > 0){
        UIImage *img = [UIImage ec_circleImageWithColor:EC_Color_App_Main withSize:CGSizeMake(40, 40) withName:friend.remarkName];
        NSString *path = [cachePath stringByAppendingFormat:@"/%@/%@/image.data", self.sessionId, [NSString MD5:friend.remarkName]];
        [[SDImageCache sharedImageCache] storeImage:img forKey:path completion:nil];
        return path;
    }
    if(friend.nickName && friend.nickName != nil && friend.nickName.length > 0){
        UIImage *img = [UIImage ec_circleImageWithColor:EC_Color_App_Main withSize:CGSizeMake(40, 40) withName:friend.nickName];
        NSString *path = [cachePath stringByAppendingFormat:@"/%@/%@/image.data", self.sessionId, [NSString MD5:friend.nickName]];
        [[SDImageCache sharedImageCache] storeImage:img forKey:path completion:nil];
        return path;
    }
    if(self.sessionId && self.sessionId != nil && self.sessionId.length > 0){
        UIImage *img = [UIImage ec_circleImageWithColor:EC_Color_App_Main withSize:CGSizeMake(40, 40) withName:self.sessionId];
        NSString *path = [cachePath stringByAppendingFormat:@"/%@/%@/image.data", self.sessionId, self.sessionId];
        [[SDImageCache sharedImageCache] storeImage:img forKey:path completion:nil];
        return path;
    }
    return @"";
}

@end
