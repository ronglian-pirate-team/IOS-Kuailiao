//
//  ECSessionFetchModel.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/10.
//

#import <Foundation/Foundation.h>
#import "ECSession.h"

typedef void(^EC_ReloadSessionBlock)(ECSession *session);

@interface ECSessionFetchModel : NSObject

+ (instancetype)sharedInstanced;

@property (nonatomic, strong) EC_ReloadSessionBlock ec_reloadSessionBlock;


@end
