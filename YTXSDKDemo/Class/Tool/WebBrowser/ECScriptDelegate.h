//
//  ECScriptDelegate.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/8/22.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface ECScriptDelegate : NSObject<WKScriptMessageHandler>


- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end
