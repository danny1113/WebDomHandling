//
//  WebDomService.m
//  
//
//  Created by Danny on 2022/2/28.
//

#import "WebDomService.h"


@interface WebDomService ()

@property (nonatomic, copy) WKWebView *webView; // redefined as readwrite

@property (nonatomic) BOOL shouldReload;

@end


@implementation WebDomService

@synthesize webView;
@synthesize script;
@synthesize shouldReload;


- (instancetype)init {
    self = [super init];
    if (self) {
        shouldReload = NO;
        [self setupWebView];
    }
    
    return self;
}

- (instancetype)initWithResource:(NSString *)resource {
    self = [self init];
    if (self) {
        [self loadJavaScriptStringForResource:resource];
    }
    
    return self;
}


- (void)setupWebView {
    webView = [[WKWebView alloc] init];
    webView.navigationDelegate = self;
    webView.customUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.2 Safari/605.1.15";
}

- (void)loadJavaScriptStringForResource:(NSString *)resource {
    NSURL *url = [[NSBundle mainBundle] URLForResource:resource withExtension:@"js"];
    if (url == nil)
        return;
    
    NSError *e;
    script = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&e];
    if (e)
        return;
    
    if (shouldReload) {
        [webView evaluateJavaScript:script
                  completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            [self evaluateCompletionHandler:result error:error];
        }];
    }
    
}

- (void)load:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [webView loadRequest:request];
    });
}

- (void)loadHTMLString:(NSString *)htmlString baseURL:(NSURL *)base {
    [webView loadHTMLString:htmlString baseURL:base];
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (script == nil || [script isEqualToString:@""]) {
        shouldReload = YES;
        NSError *e = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"No JavaScript code provided for evaluate."}];
        [self.delegate webView:webView didFailEvaluateJavaScript:e];
        return;
    }
    
    [webView evaluateJavaScript:script
              completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        [self evaluateCompletionHandler:result error:error];
    }];
}

- (void)evaluateCompletionHandler:(id)result error:(NSError *)error {
    if (shouldReload)
        shouldReload = NO;
    
    if (error) {
        [self.delegate webView:webView didFailEvaluateJavaScript:error];
        return;
    }
    if (result && [result isKindOfClass:[NSString class]]) {
        [self.delegate webView:webView didFinishEvaluateJavaScript:result];
    } else {
        NSError *e = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Can't convert to NSString.\nIf you are returning a JSON from JavaScript, please use JSON.stringify() before data return to Objective-C."}];
        [self.delegate webView:webView didFailEvaluateJavaScript:e];
    }
}

@end
