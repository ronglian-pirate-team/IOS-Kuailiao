//
//  ECFriendManager.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/21.
//
//

#import "ECFriendManager.h"
#import "SearchCoreManager.h"

@interface ECFriendManager()

@property (nonatomic, strong) NSMutableArray *allFriends;

@end

@implementation ECFriendManager

+ (instancetype)sharedInstanced{
    static ECFriendManager* friendManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        friendManager = [[ECFriendManager alloc] init];
    });
    return friendManager;
}

- (void)fetchPersonalInfoFromServer:(NSString *)friendId completion:(void (^)(ECFriend *friend))completion;{
    ECRequestPersonInfo *fr = [[ECRequestPersonInfo alloc] init];
    fr.useracc = [ECSDK_Key stringByAppendingFormat:@"#%@",[ECAppInfo sharedInstanced].persionInfo.userName];
    fr.searchContent = [ECSDK_Key stringByAppendingFormat:@"#%@", friendId];
    [[ECAFNHttpTool sharedInstanced] getPersionalInfo:fr completion:^(NSString *errCode, id responseObject) {
        if(errCode.integerValue == 0){
            ECFriend *f = [[ECFriend alloc] init];
            f.friendState = @"0";
            [f setValuesForKeysWithDictionary:responseObject];
            if(completion)
                completion(f);
        }
    }];
}

#pragma mark - 获取指定好友信息
- (void)fetchFriendInfoFromServer:(NSString *)friendId completion:(void (^)(ECFriend *friend))completion{
    ECRequestFriendInfo *fr = [[ECRequestFriendInfo alloc] init];
    fr.useracc = [ECSDK_Key stringByAppendingFormat:@"#%@",[ECAppInfo sharedInstanced].persionInfo.userName];
    fr.friendUseracc = [ECSDK_Key stringByAppendingFormat:@"#%@", friendId];
    [[ECAFNHttpTool sharedInstanced] getFriendInfo:fr completion:^(NSString *errCode, id responseObject) {
        if(errCode.integerValue == 0){
            ECFriend *friend = [[ECFriend alloc] init];
            [friend setValuesForKeysWithDictionary:responseObject];
            friend.useracc = fr.friendUseracc;
            friend.friendState = @"1";
            [[ECDBManager sharedInstanced].friendMgr insertFriend:friend];
            if(completion)
                completion(friend);
        }else{
            [ECCommonTool toast:responseObject];
        }
    }];
}

- (ECFriend *)fetchFriendFromDB:(NSString *)friendId{
    return [[ECDBManager sharedInstanced].friendMgr queryFriend:friendId];
}

#pragma mark - 获取所以好友信息
- (void)fetchFriendFromServer:(void (^)(NSMutableArray *friends))completion{
    ECRequestFriendList *fr = [[ECRequestFriendList alloc] init];
    fr.useracc = [ECSDK_Key stringByAppendingFormat:@"#%@",[ECAppInfo sharedInstanced].persionInfo.userName];
    fr.size = @"100";
    fr.timestamp = @"";
    fr.isUpdate = @"0";
    __block NSMutableArray *tmpArr;
    [[ECAFNHttpTool sharedInstanced] getFriends:fr completion:^(NSString *errCode, id responseObject) {
        if(errCode.integerValue == 0 && responseObject){
            tmpArr = [NSMutableArray array];
            for (NSDictionary *friendDic in responseObject[@"friendsList"]) {
                ECFriend *friend = [[ECFriend alloc] init];
                [friend setValuesForKeysWithDictionary:friendDic];
                friend.friendState = @"1";
                [tmpArr addObject:friend];
            }
            self.allFriends = tmpArr;
            [[ECDBManager sharedInstanced].friendMgr insertFriends:tmpArr];
        }else if (errCode.integerValue == 112219){//好友列表为空，删除数据库所以好友
            tmpArr = [NSMutableArray array];
            self.allFriends = tmpArr;
            [[ECDBManager sharedInstanced].friendMgr insertFriends:tmpArr];
        }
        if(completion)
            completion(tmpArr);
    }];
}

- (void)remarkFriend:(NSString *)friendId remarkName:(NSString *)remark completion:(void (^)())completion{
    ECRequestFriendRemark *f = [[ECRequestFriendRemark alloc] init];
    f.useracc = [ECSDK_Key stringByAppendingFormat:@"#%@",[ECAppInfo sharedInstanced].persionInfo.userName];
    f.friendUseracc = [ECSDK_Key stringByAppendingFormat:@"#%@", friendId];
    f.remarkName = remark;
    [[ECAFNHttpTool sharedInstanced] remarkFriend:f completion:^(NSString *errCode, id responseObject) {
        if(errCode.integerValue == 0){
            [[ECDBManager sharedInstanced].friendMgr updateRemark:remark inFriend:friendId];
            [ECCommonTool toast:NSLocalizedString(@"备注修改成功", nil)];
            if(completion)
                completion();
        }else{
            [ECCommonTool toast:responseObject];
        }
    }];
}

- (void)addFriendWithAccount:(NSString *)account{
    EC_ShowHUD_OnView(@"", [AppDelegate sharedInstanced].currentVC.view);
    ECRequestFriendAdd *friendAdd = [[ECRequestFriendAdd alloc] init];
    friendAdd.useracc = [ECSDK_Key stringByAppendingFormat:@"#%@",[ECAppInfo sharedInstanced].persionInfo.userName];
    friendAdd.message = @"message";
    friendAdd.friendUseracc = [ECSDK_Key stringByAppendingFormat:@"#%@", [account stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    friendAdd.source = @"1";
    [[ECAFNHttpTool sharedInstanced] requestAddFriend:friendAdd completion:^(NSString *errCode, id responseObject) {
        EC_HideHUD_OnView([AppDelegate sharedInstanced].currentVC.view)
        if (errCode.integerValue == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:EC_DEMO_kNotification_RealoadAddFriendSigleRow object:account];
            [ECCommonTool toast:NSLocalizedString(@"请求已发送", nil)];
        } else{
            if(!EC_ISNullStr(responseObject))
                [ECCommonTool toast:responseObject];
        }
    }];
}

- (void)agreeFrendAddRequest:(NSString *)useracc  completion:(void (^)(NSString *errCode, id responseObject))completion{
    ECRequestFriendAddAgree *fr = [[ECRequestFriendAddAgree alloc] init];
    fr.useracc = [ECSDK_Key stringByAppendingFormat:@"#%@",[ECAppInfo sharedInstanced].persionInfo.userName];
    fr.friendUseracc = useracc;
    EC_ShowHUD_OnView(@"", [AppDelegate sharedInstanced].currentVC.view);
    [[ECAFNHttpTool sharedInstanced] agreeFriendAddRequest:fr completion:^(NSString *errCode, id responseObject) {
        EC_HideHUD_OnView([AppDelegate sharedInstanced].currentVC.view)
        if(errCode.integerValue == 0 || errCode.integerValue == 112195){
            [ECCommonTool toast:NSLocalizedString(@"已同意对方请求", nil)];
            if(completion)
                completion(errCode, responseObject);
        }else{
            [ECCommonTool toast:NSLocalizedString(@"操作失败", nil)];
        }
    }];
}

- (void)deleteFriend:(NSString *)friendId{
    [[ECDBManager sharedInstanced].friendMgr deleteFriend:friendId];
}

- (void)uploadImage:(UIImage *)image completion:(void (^)(NSString *errCode))completion{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    [[ECAFNHttpTool sharedInstanced] uploadUserAcatar:imageData completion:^(NSString *errCode, id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(errCode.integerValue == 0)
                [ECDevicePersonInfo sharedInstanced].avatar = responseObject[@"avatar"];
            if(completion)
                completion(errCode);
        });
    }];
}

- (void)fetchUserVerifyCompletion:(void (^)(NSString *errCode, id responseObject))completion{
    [[ECAFNHttpTool sharedInstanced] fetchUserVerifyCompletion:^(NSString *errCode, id responseObject) {
        if(errCode.integerValue == 0){
            [ECDevicePersonInfo sharedInstanced].isNeedConfirm = [responseObject[@"addVerify"] boolValue];
            EC_Demo_AppLog(@"%@", responseObject);
        }
    }];
}

- (NSMutableArray *)fetchFriendFromDB{
    NSMutableArray *tmpArr = [[ECFriendDB sharedInstanced] queryAllFriend];
    self.allFriends = tmpArr;
    return tmpArr;
}

- (NSDictionary *)firstLetterFriend:(NSArray *)friendArr{
    NSMutableDictionary *contactDic = [NSMutableDictionary dictionary];
    for (ECFriend *f in friendArr) {
        NSMutableArray *subArray = [contactDic objectForKey:f.firstLetter];
        if (!subArray) {
            subArray = [NSMutableArray array];
            NSLog(@"%@", f.firstLetter);
            [contactDic setObject:subArray forKey:f.firstLetter];
        }
        [subArray addObject:f];
    }
    return contactDic;
}

- (NSArray *)firstLetters:(NSDictionary *)firstLetterDic{
    return [firstLetterDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *letter1 = obj1;
        NSString *letter2 = obj2;
//        if(letter2.length==0)
//            return NSOrderedDescending;
        if ([letter1 characterAtIndex:0] < [letter2 characterAtIndex:0]) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
}

- (void)setAllFriends:(NSMutableArray *)allFriends{
    _allFriends = allFriends;
    [self configSearchManager];
}

- (void)configSearchManager{
    [[SearchCoreManager share] Reset];
    for (int i = 0; i < self.allFriends.count; i++) {
        ECFriend *friend = self.allFriends[i];
        if(![friend isKindOfClass:[ECFriend class]])
            continue;
        [[SearchCoreManager share] AddContact:@(i) name:friend.nickName phone:@[friend.useracc]];
    }
}

- (NSMutableArray *)searchContacts:(NSString *)text{
    NSMutableArray *searchArr = [NSMutableArray array];
    NSMutableArray *nameArr = [NSMutableArray array];
    NSMutableArray *useraccArr = [NSMutableArray array];
    [[SearchCoreManager share] SearchWithFunc:@"22233344455566677778889999" searchText:text searchArray:nil nameMatch:nameArr phoneMatch:useraccArr];
    if (nameArr.count>0) {
        for (NSNumber *index in nameArr) {
            [searchArr addObject:self.allFriends[index.integerValue]];
        }
    } else if (useraccArr.count>0) {
        for (NSNumber *index in useraccArr) {
            [searchArr addObject:self.allFriends[index.integerValue]];
        }
    }
    return searchArr;
}

@end
