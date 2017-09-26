//
//  ECSessionManger.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/9/1.
//
//

#import <Foundation/Foundation.h>


@class ECSession;

typedef void(^EC_ReloadSingleSessionBlock)(ECSession *session);
typedef void(^EC_ReloadSessionBlock)(NSMutableArray *sessionArray, NSString *badgeValue);

@interface ECSessionManger : NSObject

+ (instancetype)sharedInstanced;

@property (nonatomic, strong) ECSession *session;
@property (nonatomic, strong) EC_ReloadSingleSessionBlock ec_reloadSingleSessionBlock;
@property (nonatomic, strong) EC_ReloadSessionBlock ec_reloadSessionBlock;

- (void)ec_setSessionTop:(BOOL)isTop completion:(void(^)(ECError *error, NSString *seesionId))completion;
@end
