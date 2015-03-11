//
//  WKWebViewController.h
//  iOS Portal
//
//  Created by 腹黒い茶 on 27/2/2015.
//  Copyright (c) 2015年 Haraguroicha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "EasyJSWebView.h"

@interface WKWebViewController : UIViewController

@property (strong, nonatomic) EasyJSWebView *webView;

- (void)setConfiguration:(WKWebViewConfiguration *)configuration;

@end
