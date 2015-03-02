//
//  EasyJSWebViewDelegate.m
//  EasyJS
//
//  Created by Lau Alex on 19/1/13.
//  Modified by 腹黒い茶 on 2/3/2015.
//  Copyright (c) 2013 Dukeland. All rights reserved.
//

#import "EasyJSWebViewProxyDelegate.h"
#import "EasyJSDataFunction.h"
#import <objc/runtime.h>
#import "haraguroichaAppDelegate.h"

@interface EasyJSWebViewProxyDelegate()

@property (strong, nonatomic) NSString *INJECT_JS;
@property (strong, nonatomic) EasyJSWebView *webView;
@property (readwrite, nonatomic) NSUInteger totalResources;

@end

@implementation EasyJSWebViewProxyDelegate

@synthesize realDelegate;
@synthesize javascriptInterfaces;

- (instancetype)initWithWebView:(id)webView {
    self = [super init];
    if (self) {
        self.webView = webView;
        self.totalResources = 0;
        NSString *injectFile = [[NSBundle mainBundle] pathForResource:@"easyjs-inject"
                                                               ofType:@"js"];
        NSError *error = nil;
        self.INJECT_JS = [[NSString alloc] initWithContentsOfFile:injectFile
                                                         encoding:NSUTF8StringEncoding
                                                            error:&error];
        haraguroichaAppDelegate *appDelegate = (haraguroichaAppDelegate *)[[UIApplication sharedApplication] delegate];
        GCDWebServer *localServer = [appDelegate localServer];
        if ([localServer isRunning]) {
            [localServer stop];
        }
        [localServer addHandlerForMethod:@"OPTIONS"
                                    path:JS_HANDLER_PATH
                            requestClass:[GCDWebServerRequest class]
                       asyncProcessBlock:^(GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
                           NSString *origin = [[request headers] objectForKey:@"Origin"];
                           NSString *allowHeaders = @"X-Method-Info, Content-Type";
                           GCDWebServerResponse *response = [GCDWebServerResponse response];
                           [response setValue:origin forAdditionalHeader:@"Access-Control-Allow-Origin"];
                           [response setValue:allowHeaders forAdditionalHeader:@"Access-Control-Allow-Headers"];
                           completionBlock(response);
                       }];
        [localServer addHandlerForMethod:@"POST"
                                    path:JS_HANDLER_PATH
                            requestClass:[GCDWebServerRequest class]
                       asyncProcessBlock:^(GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
                           NSString *methodInfo = [[request headers] objectForKey:@"X-Method-Info"];
                           __block NSString *returnResource = @"";
                           dispatch_sync(dispatch_get_main_queue(), ^{
                               /*
                                A sample URL structure:
                                X-Method-Info: MyJSTest:test
                                X-Method-Info: MyJSTest:testWithParam%3A:haha
                                */
                               NSArray *components = [methodInfo componentsSeparatedByString:@":"];
                               //NSLog(@"req: %@", requestString);

                               NSString *obj = (NSString *)[components objectAtIndex:0];
                               NSString *method = [(NSString *)[components objectAtIndex:1]
                                                   stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

                               NSObject *interface = [self.javascriptInterfaces objectForKey:obj];

                               // execute the interfacing method
                               SEL selector = NSSelectorFromString(method);
                               NSMethodSignature *sig = [[interface class] instanceMethodSignatureForSelector:selector];
                               NSInvocation *invoker = [NSInvocation invocationWithMethodSignature:sig];
                               invoker.selector = selector;
                               invoker.target = interface;

                               NSMutableArray *args = [[NSMutableArray alloc] init];

                               if ([components count] >= 3){
                                   NSString *argsAsString = [(NSString*)[components objectAtIndex:2]
                                                             stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

                                   NSArray *formattedArgs = [argsAsString componentsSeparatedByString:@":"];
                                   for (long i = 0, j = 0, l = [formattedArgs count]; i < l; i += 2, j++){
                                       NSString *type = ((NSString *)[formattedArgs objectAtIndex:i]);
                                       NSString *argStr = ((NSString *)[formattedArgs objectAtIndex:i + 1]);

                                       if ([@"f" isEqualToString:type]) {
                                           EasyJSDataFunction *func = [[EasyJSDataFunction alloc] initWithWebView:self.webView];
                                           [func setFuncID:argStr];
                                           [args addObject:func];
                                           [invoker setArgument:&func atIndex:(j + 2)];
                                       } else if ([@"s" isEqualToString:type]) {
                                           NSString *arg = [argStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                           [args addObject:arg];
                                           [invoker setArgument:&arg atIndex:(j + 2)];
                                       }
                                   }
                               }
                               [invoker invoke];
                               if ([sig methodReturnLength] > 0){
                                   const char *retValue;
                                   [invoker getReturnValue:&retValue];
                                   if (!(retValue == NULL || retValue == nil)) {
                                       returnResource = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)[[NSString alloc] initWithUTF8String:retValue], NULL, CFSTR("\':/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8));
                                   }
                               }
                               NSLog(@"Return result for '%@' => %@", methodInfo, returnResource);
                           });
                           NSString *origin = [[request headers] objectForKey:@"Origin"];
                           NSString *allowHeaders = @"X-Method-Info, Content-Type";
                           GCDWebServerDataResponse *response = [GCDWebServerDataResponse responseWithText:returnResource];
                           [response setValue:origin forAdditionalHeader:@"Access-Control-Allow-Origin"];
                           [response setValue:allowHeaders forAdditionalHeader:@"Access-Control-Allow-Headers"];
                           completionBlock(response);
                       }];
        [appDelegate startLocalServer];
    }
    return self;
}

- (void)addJavascriptInterfaces:(NSObject *)interface WithName:(NSString *)name{
	if (!self.javascriptInterfaces) {
		self.javascriptInterfaces = [[NSMutableDictionary alloc] init];
	}
	
	[self.javascriptInterfaces setValue:interface forKey:name];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.realDelegate webView:webView didFailNavigation:navigation withError:error];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
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
    // set native url host
    [webView evaluateJavaScript:[NSString stringWithFormat:@"window.__nativeURL = '%@';", LOCAL_HTML_BASE]
              completionHandler:nil];
	// inject the basic functions first
	[webView evaluateJavaScript:self.INJECT_JS completionHandler:nil];
	// inject the function interface
	[webView evaluateJavaScript:injection completionHandler:nil];
    // initialize injected code
    [webView evaluateJavaScript:initialize completionHandler:nil];
    self.totalResources++;
    [self.realDelegate webView:webView didFinishNavigation:navigation];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    [self.realDelegate webView:webView didCommitNavigation:navigation];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (self.realDelegate != nil) {
        [self.realDelegate webView:webView
   decidePolicyForNavigationAction:navigationAction
                   decisionHandler:decisionHandler];
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

@end
