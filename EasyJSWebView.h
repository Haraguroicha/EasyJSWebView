//
//  EasyJSWebView.h
//  EasyJS
//
//  Created by Lau Alex on 19/1/13.
//  Copyright (c) 2013 Dukeland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyJSWebViewProxyDelegate.h"

@class EasyJSWebView;

@protocol EasyJSWebViewProgressDelegate <NSObject>
@optional
- (void) webView:(EasyJSWebView*)webView didReceiveResourceNumber:(int)resourceNumber totalResources:(int)totalResources;
@end

@interface EasyJSWebView : UIWebView

// All the events will pass through this proxy delegate first
@property (nonatomic, retain) EasyJSWebViewProxyDelegate* proxyDelegate;

@property (nonatomic, assign) int resourceCount;
@property (nonatomic, assign) int resourceCompletedCount;

@property (nonatomic, assign) IBOutlet id<EasyJSWebViewProgressDelegate> progressDelegate;

- (void) initEasyJS;
- (void) addJavascriptInterfaces:(NSObject*) interface WithName:(NSString*) name;

@end
