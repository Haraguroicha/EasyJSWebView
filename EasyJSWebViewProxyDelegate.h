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

#define JS_HANDLER_PATH         (@"/easy-js")

@interface EasyJSWebViewProxyDelegate : NSObject<WKNavigationDelegate>

@property (nonatomic, retain) NSMutableDictionary* javascriptInterfaces;
@property (nonatomic, retain) id<WKNavigationDelegate> realDelegate;
@property (readonly, nonatomic) NSUInteger totalResources;

- (instancetype)initWithWebView:(id)webView;
- (void)addJavascriptInterfaces:(NSObject *)interface WithName:(NSString *)name;

@end
