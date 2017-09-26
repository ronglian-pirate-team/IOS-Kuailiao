//
//  ECWebBaseController+SnatchContent.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/24.
//

#import "ECWebBaseController.h"
#import <TFHpple/TFHpple.h>

@interface ECWebBaseController (SnatchContent)
@property (nonatomic, strong) TFHpple *doc;

- (void)ec_parseHtml:(NSString *)urlStr completion:(void (^)(NSDictionary *ec_dict))completion;
@end
