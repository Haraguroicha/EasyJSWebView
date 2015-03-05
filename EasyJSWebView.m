//
//  EasyJSWebView.m
//  EasyJS
//
//  Created by Lau Alex on 19/1/13.
//  Modified by 腹黒い茶 on 2/3/2015.
//  Copyright (c) 2013 Dukeland. All rights reserved.
//

#import "EasyJSWebView.h"
#import "EasyJSWebViewProxyDelegate.h"

@interface WKWebView ()

- (id)webView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource;
- (void)webView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource;
- (void)webView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource;

@end

@implementation EasyJSWebView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (id)init {
	self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self){
	}
	return self;
}

- (void)addJavascriptInterfaces:(NSObject *)interface WithName:(NSString *)name {
    id<WKNavigationDelegate> delegate = self.navigationDelegate;
    NSLog(@"%@, %d", [delegate class], [delegate isKindOfClass:[EasyJSWebViewProxyDelegate class]]);
    if (delegate != nil && [delegate isKindOfClass:[EasyJSWebViewProxyDelegate class]]) {
        EasyJSWebViewProxyDelegate *proxyDelegate = (EasyJSWebViewProxyDelegate *)delegate;
        [proxyDelegate addJavascriptInterfaces:interface WithName:name];
    }
}

@end
