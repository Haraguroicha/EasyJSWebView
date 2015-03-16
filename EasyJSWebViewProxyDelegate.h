//
//  EasyJSWebViewDelegate.h
//  EasyJS
//
//  Created by Lau Alex on 19/1/13.
//  Modified by 腹黒い茶 on 2/3/2015.
//  Copyright (c) 2013 Dukeland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "EasyJSWebView.h"
#import "EasyJSDataFunction.h"

#define JS_HANDLER_PATH         (@"/easy-js")

@interface EasyJSWebViewProxyDelegate : NSObject<WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, retain) NSMutableDictionary* javascriptInterfaces;
@property (nonatomic, readonly) NSUInteger totalResources;
@property (nonatomic, retain) NSString *INJECT_JS;
@property (nonatomic, retain) EasyJSWebView *webView;

- (instancetype)initWithWebView:(id)_webView;
- (void)addJavascriptInterfaces:(NSObject *)interface WithName:(NSString *)name;

@end
