//
//  EasyJSDataFunction.m
//  EasyJSWebViewSample
//
//  Created by Alex Lau on 21/1/13.
//  Modified by 腹黒い茶 on 2/3/2015.
//  Copyright (c) 2013 Dukeland. All rights reserved.
//

#import "EasyJSDataFunction.h"

@implementation EasyJSDataFunction

@synthesize funcID;
@synthesize webView;
@synthesize removeAfterExecute;

- (id)initWithWebView:(EasyJSWebView *)_webView{
	self = [super init];
    if (self) {
		self.webView = _webView;
    }
    return self;
}

- (NSString *)execute {
	return [self executeWithParams:nil];
}

- (NSString *)executeWithParam:(NSString *)param {
	NSMutableArray *params = [[NSMutableArray alloc] initWithObjects:param, nil];
	return [self executeWithParams:params];
}

- (NSString *)executeWithParams:(NSArray *)params {
	NSMutableString *injection = [[NSMutableString alloc] init];
	
	[injection appendFormat:@"EasyJS.invokeCallback(\"%@\", %@", self.funcID, self.removeAfterExecute ? @"true" : @"false"];
	
	if (params) {
        NSString *args = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params
                                                                                        options:NSJSONWritingPrettyPrinted
                                                                                          error:nil]
                                               encoding:NSUTF8StringEncoding];
        [injection appendFormat:@", JSON.stringify(%@)", args];
	}
	
	[injection appendString:@");"];

    __block id returnObject = nil;
	if (self.webView) {
        __block BOOL returned = NO;
        [self.webView evaluateJavaScript:injection completionHandler:^(id obj, NSError *error) {
            returned = YES;
            returnObject = obj;
        }];
        while (!returned) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
        }
	}
    if (self.callbackAfterExecuteAction != nil) {
        [self callbackAfterExecuteAction];
    }
    return returnObject;
}

@end
