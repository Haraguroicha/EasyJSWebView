//
//  WKWebViewController.m
//  iOS Portal
//
//  Created by 腹黒い茶 on 27/2/2015.
//  Copyright (c) 2015年 Haraguroicha. All rights reserved.
//

#import "WKWebViewController.h"

@interface WKWebViewController ()

@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webView = [[EasyJSWebView alloc] initWithFrame:self.view.frame];
    [self setWebViewAutoresize];
}

- (void)setConfiguration:(WKWebViewConfiguration *)configuration {
    // clean up with replace old instance
    if (self.webView != nil) {
        self.webView = nil;
    }
    self.webView = [[EasyJSWebView alloc] initWithFrame:self.view.frame
                                          configuration:configuration];
    [self setWebViewAutoresize];
}

- (void)setWebViewAutoresize {
    UIViewAutoresizing resizeMask = (UIViewAutoresizing)(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    [self.webView setAutoresizingMask:resizeMask];
    self.view = self.webView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
