//
//  EasyJSWebViewDelegate.m
//  EasyJS
//
//  Created by Lau Alex on 19/1/13.
//  Modified by 腹黒い茶 on 2/3/2015.
//  Copyright (c) 2013 Dukeland. All rights reserved.
//

#import "EasyJSWebViewProxyDelegate.h"
#import <objc/runtime.h>

@interface EasyJSWebViewProxyDelegate()

@property (nonatomic, readwrite) NSUInteger totalResources;

@end

@implementation EasyJSWebViewProxyDelegate

@synthesize javascriptInterfaces;
@synthesize INJECT_JS;
@synthesize webView;

- (instancetype)initWithWebView:(id)_webView {
    self = [super init];
    if (self) {
        self.webView = _webView;
        self.totalResources = 0;
        NSString *injectFile = [[NSBundle mainBundle] pathForResource:@"easyjs-inject"
                                                               ofType:@"js"];
        NSError *error = nil;
        self.INJECT_JS = [[NSString alloc] initWithContentsOfFile:injectFile
                                                         encoding:NSUTF8StringEncoding
                                                            error:&error];
    }
    return self;
}

- (void)addJavascriptInterfaces:(NSObject *)interface WithName:(NSString *)name{
	if (!self.javascriptInterfaces) {
		self.javascriptInterfaces = [[NSMutableDictionary alloc] init];
	}
	
	[self.javascriptInterfaces setValue:interface forKey:name];
}

- (void)webView:(WKWebView *)_webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(WKWebView *)_webView didFinishNavigation:(WKNavigation *)navigation {
	if (!self.javascriptInterfaces) {
		self.javascriptInterfaces = [[NSMutableDictionary alloc] init];
	}
	
	NSMutableString *injection = [[NSMutableString alloc] init];
	NSMutableString *initialize = [[NSMutableString alloc] init];
    
	//inject the javascript interface
	for(id key in self.javascriptInterfaces) {
		NSObject *interface = [self.javascriptInterfaces objectForKey:key];
        [initialize appendFormat:@"if (%@.initialize != undefined) { %@.initialize(); }", key, key];
        [injection appendFormat:@"EasyJS.inject(\"%@\", [", key];
		unsigned int mc = 0;
		Class cls = object_getClass(interface);
		Method *mlist = class_copyMethodList(cls, &mc);
		for (int i = 0; i < mc; i++){
			[injection appendFormat:@"\"%@\"", [NSString stringWithUTF8String:sel_getName(method_getName(mlist[i]))]];
			if (i != mc - 1){
				[injection appendString:@", "];
			}
		}
        mlist = nil;
        cls = nil;
		[injection appendString:@"]);"];
    }
	// inject the basic functions first
	[_webView evaluateJavaScript:self.INJECT_JS completionHandler:nil];
	// inject the function interface
	[_webView evaluateJavaScript:injection completionHandler:nil];
    // initialize injected code
    [_webView evaluateJavaScript:initialize completionHandler:nil];
    self.totalResources++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(WKWebView *)_webView didCommitNavigation:(WKNavigation *)navigation {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webView:(WKWebView *)_webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
