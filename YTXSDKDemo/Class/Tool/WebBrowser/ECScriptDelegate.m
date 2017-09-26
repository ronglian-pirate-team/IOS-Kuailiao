//
//  ECScriptDelegate.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/22.
//

#import "ECScriptDelegate.h"

@interface ECScriptDelegate ()
@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;
@end

@implementation ECScriptDelegate
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [_scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}
@end
