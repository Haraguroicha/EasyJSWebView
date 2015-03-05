//
//  EasyJSWebView.h
//  EasyJS
//
//  Created by Lau Alex on 19/1/13.
//  Modified by 腹黒い茶 on 2/3/2015.
//  Copyright (c) 2013 Dukeland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class EasyJSWebView;

@interface WKWebView (private)

- (void)_setCustomUserAgent:(NSString *)_customUserAgent;

@end

@interface EasyJSWebView : WKWebView

- (void)addJavascriptInterfaces:(NSObject *)interface WithName:(NSString *)name;

@end
