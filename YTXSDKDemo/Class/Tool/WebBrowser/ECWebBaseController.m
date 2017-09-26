//
//  ECWebBaseController.m
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/14.
//

#import "ECWebBaseController.h"
#import <WebKit/WebKit.h>
#import "ECScriptDelegate.h"
#import "ECWebBaseController+SnatchContent.h"

@interface ECWebBaseController ()<ECBaseContollerDelegate,WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
@property (nonatomic, copy) NSString *urlStr;//网页地址
@property (nonatomic, strong) ECWebBaseBlock baseBlock;
@property (nonatomic, assign) ECWebBaseController_Type type;
@property (nonatomic,strong) WKWebView *wkWebView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSDictionary *dict;
@end

@implementation ECWebBaseController

- (instancetype)initWithUrlStr:(NSString *)urlStr andType:(ECWebBaseController_Type)type completion:(ECWebBaseBlock)completion {
    self = [super init];
    if (self) {
        self.urlStr = urlStr;
        self.type = type?:ECWebBaseController_Type_Link;
        self.baseBlock = completion;
    }
    return self;
}

- (void)viewDidLoad {
    self.baseDelegate = self;
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = NSLocalizedString(@"网页", nil);
}

#pragma mark - ECBaseContollerDelegate
- (ECBaseItemBlock)baseController:(ECBaseContoller *)baseVC configRightBtnItemWithStr:(NSString *__autoreleasing *)str {
    *str = self.type == ECWebBaseController_Type_ShareLink?@"发送":@"";
    return ^id {
        if (self.baseBlock && self.dict) {
            self.baseBlock(self.dict);
            [self.navigationController popViewControllerAnimated:YES];
        }
        return self.dict;
    };
}
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.progressView.progress = webView.estimatedProgress;
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView removeFromSuperview];
    _wkWebView.frame = self.view.bounds;
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    self.progressView.progress = webView.estimatedProgress;
    EC_WS(self);
    [webView evaluateJavaScript:@"document.title" completionHandler:^(NSString *title, NSError *error) {
        weakSelf.title = title.length>0?title:@"网页";
    }];
    if (self.type == ECWebBaseController_Type_ShareLink)
        [self ec_parseHtml:_urlStr completion:^(NSDictionary *ec_dict) {
            self.dict = ec_dict;
        }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    self.progressView.progress = webView.estimatedProgress;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_progressView removeFromSuperview];
        _wkWebView.frame = self.view.bounds;
    });
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [_progressView removeFromSuperview];
    _wkWebView.frame = self.view.bounds;
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
        CFDataRef exceptions = SecTrustCopyExceptions(serverTrust);
        SecTrustSetExceptions(serverTrust, exceptions);
        CFRelease(exceptions);
        
        completionHandler(NSURLSessionAuthChallengeUseCredential,
                          [NSURLCredential credentialForTrust:serverTrust]);
    }
}

#pragma mark - WKScriptMessageHandler
- (void)ec_ScriptHandleNativeMethod {
    
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"ec_ScriptHandleNativeMethod"]) {
        NSLog(@"JS 调用了 %@ 方法，传回参数 %@",message.name,message.body);
    }
}

#pragma mark - NativeHandleJS
- (void)ec_NativeHandleJSMethod {
    [self.wkWebView evaluateJavaScript:@"" completionHandler:^(id _Nullable body, NSError * _Nullable error) {
        NSLog(@"navtive 调用了 js 方法，传回结果 %@",body);
    }];
}
#pragma mark - UI创建
- (void)buildUI {
    [super buildUI];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.wkWebView];
    if (!([self.urlStr hasPrefix:@"http://"] || [self.urlStr hasPrefix:@"https://"])) {
        self.urlStr = [NSString stringWithFormat:@"http://%@",self.urlStr];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]];
    [self.wkWebView loadRequest:request];
}
#pragma mark - 懒加载
- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        WKWebViewConfiguration *wkConfig = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *userController = [[WKUserContentController alloc] init];
        [userController addScriptMessageHandler:[[ECScriptDelegate alloc] initWithDelegate:self] name:@"ec_ScriptHandleNativeMethod"];
        wkConfig.userContentController = userController;
        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_progressView.frame), self.view.frame.size.width, self.view.frame.size.height-_progressView.bounds.size.height) configuration:wkConfig];
        _wkWebView.UIDelegate = self;
        _wkWebView.navigationDelegate = self;
    }
    return _wkWebView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 2)];
        _progressView.tintColor = [UIColor greenColor];
    }
    return _progressView;
}

- (void)dealloc {
    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"ec_ScriptHandleNativeMethod"];
}
@end
