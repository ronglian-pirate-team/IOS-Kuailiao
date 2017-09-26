//
//  ECWebBaseController.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/14.
//

#import <UIKit/UIKit.h>
#import "ECBaseContoller.h"

typedef enum : NSUInteger {
    ECWebBaseController_Type_None,
    ECWebBaseController_Type_Link,
    ECWebBaseController_Type_Share,
    ECWebBaseController_Type_ShareLink
} ECWebBaseController_Type;

typedef void(^ECWebBaseBlock)(id responseObject);

@interface ECWebBaseController : ECBaseContoller

- (instancetype)initWithUrlStr:(NSString *)urlStr andType:(ECWebBaseController_Type)type completion:(ECWebBaseBlock)completion;

@end
