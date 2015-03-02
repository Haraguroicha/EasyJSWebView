//
//  EasyJSWebView.m
//  EasyJS
//
//  Created by Lau Alex on 19/1/13.
//  Modified by 腹黒い茶 on 2/3/2015.
//  Copyright (c) 2013 Dukeland. All rights reserved.
//

#import "EasyJSWebView.h"

@interface WKWebView ()

- (id)webView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource;
- (void)webView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource;
- (void)webView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource;

@end

@implementation EasyJSWebView

@synthesize proxyDelegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self initEasyJS];
    }
    return self;
}

- (id)init {
	self = [super init];
    if (self) {
		[self initEasyJS];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self){
		[self initEasyJS];
	}
	return self;
}

- (void)initEasyJS {
	self.proxyDelegate = [[EasyJSWebViewProxyDelegate alloc] initWithWebView:self];
	self.navigationDelegate = self.proxyDelegate;
}

- (void)setDelegate:(EasyJSWebViewProxyDelegate *)delegate {
    [self.proxyDelegate setRealDelegate:delegate];
}

- (void)addJavascriptInterfaces:(NSObject *)interface WithName:(NSString *)name {
	[self.proxyDelegate addJavascriptInterfaces:interface WithName:name];
}

@end
