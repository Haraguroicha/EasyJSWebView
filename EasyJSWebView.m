//
//  EasyJSWebView.m
//  EasyJS
//
//  Created by Lau Alex on 19/1/13.
//  Copyright (c) 2013 Dukeland. All rights reserved.
//

#import "EasyJSWebView.h"

@interface UIWebView ()

-(id)webView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource;
-(void)webView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource;
-(void)webView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource;

@end

@implementation EasyJSWebView

@synthesize proxyDelegate;

@synthesize progressDelegate;
@synthesize resourceCount;
@synthesize resourceCompletedCount;

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
	self.proxyDelegate = [[EasyJSWebViewProxyDelegate alloc] init];
	self.delegate = self.proxyDelegate;
}

- (void)setDelegate:(id<UIWebViewDelegate>)delegate {
	if (delegate != self.proxyDelegate) {
		self.proxyDelegate.realDelegate = delegate;
	} else {
		[super setDelegate:delegate];
	}
}

- (void)addJavascriptInterfaces:(NSObject*)interface WithName:(NSString*)name {
	[self.proxyDelegate addJavascriptInterfaces:interface WithName:name];
}

- (id)webView:(id)view identifierForInitialRequest:(id)initialRequest fromDataSource:(id)dataSource {
    [super webView:view identifierForInitialRequest:initialRequest fromDataSource:dataSource];
    return [NSNumber numberWithInt:resourceCount++];
}

- (void)webView:(id)view resource:(id)resource didFailLoadingWithError:(id)error fromDataSource:(id)dataSource {
    [super webView:view resource:resource didFailLoadingWithError:error fromDataSource:dataSource];
    resourceCompletedCount++;
    if ([self.progressDelegate respondsToSelector:@selector(webView:didReceiveResourceNumber:totalResources:)]) {
        [self.progressDelegate webView:self didReceiveResourceNumber:resourceCompletedCount totalResources:resourceCount];
    }
}

- (void)webView:(id)view resource:(id)resource didFinishLoadingFromDataSource:(id)dataSource {
    [super webView:view resource:resource didFinishLoadingFromDataSource:dataSource];
    resourceCompletedCount++;
    if ([self.progressDelegate respondsToSelector:@selector(webView:didReceiveResourceNumber:totalResources:)]) {
        [self.progressDelegate webView:self didReceiveResourceNumber:resourceCompletedCount totalResources:resourceCount];
    }
}

@end
