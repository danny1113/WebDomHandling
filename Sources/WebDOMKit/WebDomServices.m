//
//  WebDomServices.m
//  
//
//  Created by Danny on 2022/2/28.
//

#import "WebDomServices.h"


@interface WebDomServices ()

@property (nonatomic, copy) WKWebView *webView; //redefined as readwrite

@property (nonatomic) BOOL shouldReload;

@end


@implementation WebDomServices

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

- (instancetype)initWithResource:(NSString *)resource url:(NSString *)url {
    self = [self initWithResource:resource];
    if (self) {
        [self loadURLString:url];
    }
    
    return self;
}

- (instancetype)initWithJavaScriptString:(NSString *)script url:(NSString *)url {
    self = [self init];
    if (self) {
        self.script = script;
        [self loadURLString:url];
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

- (void)loadURLString:(NSString *)urlString {
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
    if ([script isEqualToString:@""]) {
        shouldReload = YES;
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
    // An error occured.
    if (error) {
        NSLog(@"%@", error);
        [self.delegate webView:webView didFailEvaluateJavaScript:error];
        return;
    }
    // result can be typecast as String
    NSString *str = result;
    if (str == nil) {
        NSError *e = [NSError errorWithDomain:NSCocoaErrorDomain code:-1 userInfo:nil];
        [self.delegate webView:webView didFailEvaluateJavaScript:e];
        return;
    }
    // did finished evaluate JavaScript code.
    [self.delegate webView:webView didFinishEvaluateJavaScript:str];
}

@end
